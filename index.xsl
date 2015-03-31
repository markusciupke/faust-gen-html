<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"	
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:variable name="transcripts" select="collection()[2]"/>
	<xsl:param name="title">Lesetexte</xsl:param>
	<xsl:output method="xhtml"/>

        <xsl:include href="utils.xsl"/>
	
	
	<xsl:template match="/">
		<html>
			<xsl:call-template name="html-head">
				<xsl:with-param name="title" select="$title"/>
			</xsl:call-template>
			<body>
				<xsl:call-template name="header"/>

        <main>
          <div class="main-content-container">
            <div id="main-content" class="main-content">
              <div id="main" class="print">
                <div class="print-side-column"/> <!-- 1. Spalte (1/5) bleibt erstmal frei -->
                <div class="print-center-column">  <!-- 2. Spalte (3/5) für den Inhalt -->

                  <h2>Lesetexte</h2>
                  <nav>
                  <ul>
                    <li><a href="faust1.html">Faust I</a></li>
                    <li><a href="faust2.html">Faust II</a></li>
                  </ul>
                  </nav>
                  
                  <h2>Drucke</h2>
                  
                  <nav>
                  <ul>
                    <xsl:for-each select="//f:textTranscript[@type='print']">
                      <xsl:sort select="f:idno[1]"/>
                      <xsl:variable name="filename" select="replace(@href, '^.*/([^/]+)', '$1')"/>
                      <xsl:variable name="htmlname" select="replace($filename, '\.xml$', '')"/>
                      <li><a href="{$htmlname}.html" title="{f:sigil-label(f:idno[1]/@type)}">
                        <xsl:value-of select="f:idno[1]"/>
                      </a></li>
                    </xsl:for-each>
                  </ul>
                  </nav>
                </div>
              </div>
            </div>
          </div>
        </main>

				<xsl:call-template name="footer"/>
			</body>
		</html>
		
	</xsl:template>
	
	
	<xsl:template name="html-head">
		<xsl:param name="title" select="$title"/>
    <head>
      <meta charset='utf-8'/>

      <script type="text/javascript" src="../js/faust_common.js"/>
      <script src="../js/faust_print_view.js"/>
      <link href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css" rel="stylesheet"/>
      <link rel="stylesheet" href="../css/document-text.css"/>
      <link rel="stylesheet" href="../css/document-transcript.css"/>
      <link rel="stylesheet" href="../css/document-transcript-highlight-hands.css"/>
      <link rel="stylesheet" href="../css/document-transcript-interaction.css"/>
      <link rel="stylesheet" href="../css/pure-custom.css"/>
      <link rel="stylesheet" href="../css/basic_layout.css"/>
    </head>
	</xsl:template>

	<xsl:template name="header">
    <header>
      <div class="header-content">
        <a class="faustedition-logo" title="Faustedition" href="../index.php">
          <img class="faustedition-logo-svg" src="../img/faustlogo.svg" alt="Faustedition logo"/>
        </a>
        <nav class="header-navigation pure-menu">
          <a href="../archives.php">Archiv</a>
          <xsl:text> </xsl:text>
          <a href="../chessboard_overview.php">Genese</a>
          <xsl:text> </xsl:text>
          <a href="../lesetext_demo/index.html">Text</a>
          <xsl:text> </xsl:text>
          <input autocomplete="off" id="quick-search" placeholder="Search" type="text"/>
        </nav>
      </div>
    </header>
	</xsl:template>
	
  <xsl:template name="footer">
    <footer>
      <div id='footer-content' class='footer-content'>
        <b>Digitale Faust-Edition</b> • Copyright (c) 2009-2015 • Freies Deutsches Hochstift Frankfurt • Klassik Stiftung Weimar • Universität Würzburg
      </div>
      <div id="footer-navigation" class="footer-navigation">
        <a href="../K_Hilfe.php">Hilfe</a>
        <xsl:text> </xsl:text>
        <a href="../K_Kontakt.php">Kontakt</a>
        <xsl:text> </xsl:text>
        <a href="../K_Impressum.php">Impressum</a>
        <xsl:text> </xsl:text>
        <a href="../Startseite.php">Projekt</a>
      </div>
    </footer>
  </xsl:template>
	
</xsl:stylesheet>
