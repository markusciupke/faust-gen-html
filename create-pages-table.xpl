<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:j="http://www.ibm.com/xmlns/prod/2009/jsonx"
  xmlns:l="http://xproc.org/library" version="1.0" name="main" type="f:generate-pages-table">
  <p:input port="source"/>	
  <p:input port="parameters" kind="parameter"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="apply-edits.xpl"/>
  
  <!-- Parameter laden -->
  <p:parameters name="config">
    <p:input port="parameters">
      <p:document href="config.xml"/>
      <p:pipe port="parameters" step="main"></p:pipe>
    </p:input>
  </p:parameters>
  
  <p:identity><p:input port="source"><p:pipe port="source" step="main"/></p:input></p:identity>
  
  <p:group>
    <p:variable name="html" select="//c:param[@name='html']/@value"><p:pipe port="result" step="config"></p:pipe></p:variable>
    <p:variable name="builddir" select="resolve-uri(//c:param[@name='builddir']/@value)"><p:pipe port="result" step="config"/></p:variable>
    
    
    <cx:message log="info">
      <p:with-option name="message" select="'Reading transcript files to generate page/section mapping ...'"/>
    </cx:message>
    
    <!-- 
    Wir iterieren über die Transkripteliste, die vom Skript in collect-metadata.xpl generiert wird.
    Für die Variantengenerierung berücksichtigen wir dabei jedes dort verzeichnete Transkript.
  -->
    <p:for-each>
      <p:iteration-source select="//f:textTranscript"/>
      <p:variable name="transcriptFile" select="/f:textTranscript/@href"/>
      <p:variable name="transcriptURI" select="/f:textTranscript/@uri"/>
      <p:variable name="documentURI" select="/f:textTranscript/@document"/>
      <p:variable name="type" select="/f:textTranscript/@type"/>
      <p:variable name="sigil" select="/f:textTranscript/f:idno[1]/text()"/>
      <p:variable name="sigil-type" select="/f:textTranscript/f:idno[1]/@type"/>
      <p:variable name="annotated-version" select="resolve-uri($documentURI, resolve-uri('search/textTranscript/', $builddir))"/>
      
      
<!--      <cx:message>
        <p:with-option name="message" select="concat('Extracting paralipomena from ', $sigil, ' (', $emended-version, ')')"/>
      </cx:message>
-->    
      
      <!-- Das Transkript wird geladen ... -->
      <p:load>
        <p:with-option name="href" select="$annotated-version"/>
      </p:load>
      
    </p:for-each>
      
    <p:xslt template-name="collection">
      <p:input port="stylesheet"><p:document href="xslt/pagelist.xsl"/></p:input>
      <p:input port="parameters"><p:empty/></p:input>
    </p:xslt>
    
    <p:store method="text">
      <p:with-option name="href" select="resolve-uri('pages.json', resolve-uri($html))"/>
    </p:store>    
  </p:group>
  
</p:declare-step>