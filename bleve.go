package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"net/url"
	"os"
	"sync"
	"time"

	"github.com/blevesearch/bleve"
	_ "github.com/blevesearch/bleve/config"
	bleveHttp "github.com/blevesearch/bleve/http"
	"github.com/gorilla/mux"
)

const indexDir = "indexes"
const gitBaseUrl = "http://188.212.37.221:3000/api/v1/repos/%s?access_token=a6ddbb24ea29bee69670815cd4aca6b6703940cc"
const indexBaseUrl = "http://localhost:7007/api/index/%s/%s"

var (
	once      sync.Once
	netClient *http.Client
)

type gitJson struct {
	Content string `json:"content"`
	Message string `json:"message"`
	Branch  string `json:"branch"`
	Sha     string `json:"sha"`
}

func init() {

	mainRouter := mux.NewRouter().StrictSlash(true).UseEncodedPath()

	apiRouter := mainRouter.PathPrefix("/api").Subrouter()

	searchHandler := bleveHttp.NewSearchHandler("")
	searchHandler.IndexNameLookup = indexNameLookup

	docIndexHandler := bleveHttp.NewDocIndexHandler("")
	docIndexHandler.IndexNameLookup = indexNameLookup
	docIndexHandler.DocIDLookup = docIDLookup

	docDeleteHandler := bleveHttp.NewDocDeleteHandler("")
	docDeleteHandler.IndexNameLookup = indexNameLookup
	docDeleteHandler.DocIDLookup = docIDLookup

	apiRouter.Handle("/index/{indexName}/{docID}", docIndexHandler).Methods("PUT")
	apiRouter.Handle("/index/{indexName}/{docID}", docDeleteHandler).Methods("DELETE")
	apiRouter.Handle("/search/{indexName}", searchHandler).Methods("POST")
	apiRouter.HandleFunc("/data/{filePath}", getDataHandler).Methods("GET")
	apiRouter.HandleFunc("/data/{filePath}", postDataHandler).Methods("POST")
	apiRouter.HandleFunc("/data/{filePath}", putDataHandler).Methods("PUT")
	apiRouter.HandleFunc("/data/{filePath}", deleteDataHandler).Methods("DELETE")

	mainRouter.PathPrefix("/").Handler(http.FileServer(http.Dir("./static/")))

	mainRouter.PathPrefix("/").HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "static/index.html")
	})

	http.Handle("/", mainRouter)

	log.Printf("opening indexes")
	// walk the data dir and register index names
	dirEntries, err := ioutil.ReadDir(indexDir)
	if err != nil {
		log.Printf("error reading data dir: %v", err)
		return
	}

	for _, dirInfo := range dirEntries {
		indexPath := indexDir + string(os.PathSeparator) + dirInfo.Name()

		if !dirInfo.IsDir() {
			log.Printf("see file %s, this is not supported in the appengine environment", dirInfo.Name())
		} else {
			i, err := bleve.OpenUsing(indexPath, map[string]interface{}{
				"read_only": false,
			})
			if err != nil {
				log.Printf("error opening index %s: %v", indexPath, err)
			} else {
				log.Printf("registered index: %s", dirInfo.Name())
				bleveHttp.RegisterIndexName(dirInfo.Name(), i)
			}
		}
	}
}

func muxVariableLookup(req *http.Request, name string) string {
	return mux.Vars(req)[name]
}

func indexNameLookup(req *http.Request) string {
	return muxVariableLookup(req, "indexName")
}

func docIDLookup(req *http.Request) string {
	return muxVariableLookup(req, "docID")
}

func getDataHandler(responseWriter http.ResponseWriter, request *http.Request) {
	gitUrl := getFilePath(request)

	gitResponse := getGitResource(gitUrl)

	decodedContent, err := base64.StdEncoding.DecodeString(gitResponse.Content)
	if err != nil {
		fmt.Println("error:", err)
		return
	}

	responseWriter.Write(decodedContent)
	responseWriter.WriteHeader(200)
}

func postDataHandler(responseWriter http.ResponseWriter, request *http.Request) {
	gitUrl := getFilePath(request)
	sha := ""

	body, err := ioutil.ReadAll(request.Body)
	check(err)
	content := base64.StdEncoding.EncodeToString(body)

	currentDateTime := time.Now()
	username := request.Header.Get("X-Username")
	message := currentDateTime.Format("2006-01-02T15:04:05") + " " + username

	gitData := gitJson{Content: content, Message: message, Branch: "master", Sha: sha}
	gitJsonData, err := json.Marshal(gitData)
	check(err)

	postOrPutOrDeleteGitResource(gitUrl, "POST", gitJsonData)

	responseWriter.WriteHeader(200)
}

func putDataHandler(responseWriter http.ResponseWriter, request *http.Request) {
	gitUrl := getFilePath(request)
	gitResponse := getGitResource(gitUrl)
	sha := gitResponse.Sha

	body, err := ioutil.ReadAll(request.Body)
	check(err)
	content := base64.StdEncoding.EncodeToString(body)

	username := request.Header.Get("X-Username")
	currentDateTime := time.Now()
	message := currentDateTime.Format("2006-01-02T15:04:05") + " " + username

	gitData := gitJson{Content: content, Message: message, Branch: "master", Sha: sha}
	gitJsonData, err := json.Marshal(gitData)
	check(err)

	postOrPutOrDeleteGitResource(gitUrl, "PUT", gitJsonData)

	responseWriter.WriteHeader(200)
}

func deleteDataHandler(responseWriter http.ResponseWriter, request *http.Request) {
	gitUrl := getFilePath(request)
	gitResponse := getGitResource(gitUrl)
	sha := gitResponse.Sha

	username := request.Header.Get("X-Username")
	currentDateTime := time.Now()
	message := currentDateTime.Format("2006-01-02T15:04:05") + " " + username

	content := ""
	gitData := gitJson{Content: content, Message: message, Branch: "master", Sha: sha}
	gitJsonData, err := json.Marshal(gitData)
	check(err)

	postOrPutOrDeleteGitResource(gitUrl, "DELETE", gitJsonData)

	responseWriter.WriteHeader(200)
}

func getFilePath(request *http.Request) (gitUrl string) {
	filePath := muxVariableLookup(request, "filePath")
	decodedFilePath, err := url.QueryUnescape(filePath)
	if err != nil {
		log.Fatal(err)
	}

	gitUrl = fmt.Sprintf(gitBaseUrl, decodedFilePath)

	return
}

func getGitResource(gitUrl string) (gitResponse gitJson) {
	clientRequest, err := http.NewRequest("GET", gitUrl, nil)
	check(err)

	response, err := newNetClient().Do(clientRequest)
	check(err)

	defer response.Body.Close()

	body, err := ioutil.ReadAll(response.Body)
	check(err)

	jsonErr := json.Unmarshal(body, &gitResponse)
	check(jsonErr)

	return
}

func postOrPutOrDeleteGitResource(gitUrl string, httpMethod string, data []byte) {
	clientRequest, err := http.NewRequest(httpMethod, gitUrl, bytes.NewBuffer(data))
	check(err)
	clientRequest.Header.Set("Content-Type", "application/json")

	response, getErr := newNetClient().Do(clientRequest)
	check(getErr)

	defer response.Body.Close()
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}

func newNetClient() *http.Client {
	once.Do(func() {
		var netTransport = &http.Transport{
			Dial: (&net.Dialer{
				Timeout: 2 * time.Second,
			}).Dial,
			TLSHandshakeTimeout: 2 * time.Second,
		}
		netClient = &http.Client{
			Timeout:   time.Second * 108,
			Transport: netTransport,
		}
	})

	return netClient
}

// curl localhost:7007/api/search/bflr -d '{"size": 2000, "from": 0, "query": {"query": "title:etno*"}, "fields": ["collection", "title", "filePath"]}'
//
// curl -X GET localhost:7007/api/data/solirom%2Fbflr-data%2Fcontents%2FA105157.xml
// curl -X POST -H 'X-Username: claudius.teodorescu@gmail.com' -H 'Content-Type: text/plain;charset=UTF-8' localhost:7007/api/data/solirom%2Fbflr-data%2Fcontents%2Fa.xml -d '<test />'
// curl -X DELETE -H 'X-Username: claudius.teodorescu@gmail.com' localhost:7007/api/data/solirom%2Fbflr-data%2Fcontents%2FA969416.xml
//
// curl -X PUT -H 'Content-Type: text/plain;charset=UTF-8' localhost:7007/api/index/bflr/a -d '{"collection":"CLRE","title":"Dicionariu%20rom%C3%A2no-frances"}'
// curl -X DELETE localhost:7007/api/index/bflr/a
//
// curl http://localhost:3000/api/v1/repos/solirom/bflr-data/contents/A105157.xml?access_token=a6ddbb24ea29bee69670815cd4aca6b6703940cc
