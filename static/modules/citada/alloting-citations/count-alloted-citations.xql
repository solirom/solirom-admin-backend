xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $entries := collection('/data/dlr/quotations')/tei:entryFree[tei:editor/@xml:id = "emoketimar"]

return count($entries[./tei:revisionDesc/@status = 'corrected'])
