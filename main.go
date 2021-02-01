package main

import (
	"flag"
	"log"
	"net/http"
)

var bindAddr = flag.String("addr", ":7007", "http listen address")

func main() {
	flag.Parse()

	log.Printf("Listening on %v", *bindAddr)
	log.Fatal(http.ListenAndServe(*bindAddr, nil))
}
