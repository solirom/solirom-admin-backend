<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0" exclude-result-prefixes="tei">
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="true"/>
    <xsl:param name="numberOfEntries"/>
    <xsl:param name="redactorId"/>
    <xsl:param name="inputCollection"/>
    
    <xsl:variable name="entries" select="collection(concat($inputCollection, '?select=*.xml'))"/>
    <xsl:variable name="selected-entries" select="$entries/tei:entryFree[tei:editor[@role = 'redactor'] = '']"/>
    <xsl:template match="/">
        <xsl:for-each select="$selected-entries[position() =  (1 to $numberOfEntries)]">
            <xsl:variable name="uuid" select="@xml:id"/>
            <xsl:result-document href="{concat($uuid, '.xml')}">
                <entryFree xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$uuid}">
                    <xsl:copy-of select="tei:revisionDesc"/>
                    <editor role="redactor"><xsl:value-of select="$redactorId" /></editor>
                    <xsl:copy-of select="tei:orth"/>
                    <xsl:copy-of select="tei:gramGrp"/>
                    <xsl:copy-of select="tei:quote"/>
                    <xsl:copy-of select="tei:bibl"/>
                    <xsl:copy-of select="tei:re"/>
                    <xsl:copy-of select="tei:note"/>
                </entryFree>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
