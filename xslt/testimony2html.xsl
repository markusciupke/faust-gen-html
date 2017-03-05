<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	version="2.0">
		
	<xsl:import href="html-common.xsl"/>
	<xsl:import href="html-frame.xsl"/>
	
	<xsl:template match="/TEI">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="content">
				
					<xsl:apply-templates select="text"/>					
				
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<xsl:template name="html-frame">
		<xsl:param name="content"><xsl:apply-templates/></xsl:param>
		<xsl:param name="sidebar"/>
		<html>
			<xsl:call-template name="html-head"/>
			<body>
				<xsl:call-template name="header">
					<xsl:with-param name="breadcrumbs" tunnel="yes">
						<xsl:call-template name="breadcrumbs"/>
					</xsl:with-param>
				</xsl:call-template>
				
				<main class="nofooter">
					<div  class="print">
						<div class="print-side-column"/> <!-- 1. Spalte (1/5) bleibt erstmal frei -->
						<div class="print-center-column">  <!-- 2. Spalte (3/5) für den Inhalt -->
							<xsl:sequence select="$content"/>
						</div>
						<div class="print-side-column">  <!-- 3. Spalte (1/5) für die lokale Navigation  -->
							<xsl:sequence select="$sidebar"/>
						</div>
					</div>
				</main>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>
	
	
	<xsl:template match="rs">
		<mark class="{string-join(f:generic-classes(.), ' ')}">
			<xsl:apply-templates/>
		</mark>
	</xsl:template>
	
	<xsl:variable name="taxonomies">
		<f:taxonomies>
			<f:taxonomy xml:id='graef'>Gräf-Nr.</f:taxonomy>
			<f:taxonomy xml:id='pniower'>Pnioer-Nr.</f:taxonomy>
			<f:taxonomy xml:id='quz'>QuZ</f:taxonomy>
			<f:taxonomy xml:id='bie3'>Biedermann-Herwig-Nr.</f:taxonomy>			
		</f:taxonomies>
	</xsl:variable>
	
	<xsl:template match="milestone[@unit='testimony']">
		<xsl:variable name="id_parts" select="tokenize(@xml:id, '_')"/>
		<xsl:choose>
			<xsl:when test="count($id_parts) = 2">
				<xsl:variable name="taxlabel" select="id($id_parts[1], $taxonomies)/text()"/>
				<xsl:if test="not($taxlabel) or $id_parts[2] = ''">
					<xsl:message select="concat('WARNING: Invalid testimony id ', @xml:id, ' in ', document-uri(/))"/>
				</xsl:if>
				<a id="{@xml:id}" href="#{@xml:id}" class="testimony"><xsl:value-of select="concat($taxlabel, ' ', $id_parts[2])"/></a>
				<xsl:message select="concat($taxlabel, @xml:id)"/>
			</xsl:when>
			<xsl:otherwise><xsl:message select="concat('INFO: Skipping three-part testimony id ', @xml:id, ' in ', document-uri(/))"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>