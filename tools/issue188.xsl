<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.w3.org/TR/xhtml" xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions" xmlns:svg="http://www.w3.org/2000/svg"
	version="2.0">

	<xsl:param name="path"/>
	<xsl:param name="pattern">*.xml</xsl:param>

	<xsl:output method="xhtml" indent="yes" include-content-type="yes"/>

	<xsl:param name="coll" select="collection(concat(resolve-uri($path), '?select=', $pattern))"/>
	<xsl:template name="start">

		<html>
			<head>
				<title>Suchergebnisse</title>
				<meta charset="utf-8"/>
				
				<style>
					tr { background: #eeeeee; }
					tr:hover { background: white; }					
					.case1 { background: #fee; }
					.case2 { background: #efe; }
					.case3 { background: #ffe; }
				</style>
			</head>


			<body>			
				<xsl:call-template name="find-rewrites"/>
			</body>
			
			<xsl:call-template name="findSt"/>
			<xsl:call-template name="find-ge-used"/>
			<xsl:call-template name="find-grline"/>

		</html>

	</xsl:template>
	
	
	<xsl:template name="findSt">
	
		<h2>f:st[@rend='vertical'], also Streichung durch senkrechte Linie</h2>

		<table>
			<tr>
				<th>Dokument</th>
				<th>Text (f:st)</th>
				<th>Anzahl |</th>
				<th>Hand |</th>
				<th>Kontext (Zeile)</th>
			</tr>
			<xsl:for-each select="$coll//f:st[@rend = 'vertical']//text()">
				<xsl:sort select="document-uri(/)"/>
				<tr>			
					<td class="doc">
						<xsl:value-of select="replace(document-uri(/), '.*/(.*)\.xml$', '$1')"/>
					</td>
					<td class="text">
						<xsl:value-of select="."/>
					</td>
					<td>
						<xsl:value-of select="count(ancestor-or-self::f:st[@rend='vertical'])"/>
					</td>
					<td>
						<xsl:value-of select="string-join(ancestor-or-self::f:st[@rend='vertical']/@hand, ' ')"/>
					</td>
					<td class="context">
						<xsl:apply-templates select="ancestor::ge:line">
							<xsl:with-param name="highlight" select="ancestor-or-self::f:st[@rend='vertical'][1]" as="element()?" tunnel="yes"/>
						</xsl:apply-templates>
					</td>			
				</tr>				
			</xsl:for-each>
		</table>
	</xsl:template>
	
	<xsl:template name="find-ge-used">
		
		<h2>ge:used</h2>
		
		<table>
			<tr>
				<th>Dokument</th>
				<th>Text</th>
			</tr>
			<xsl:for-each select="$coll//ge:used">
				<xsl:sort select="document-uri(/)"/>
				<tr>			
					<td class="doc">
						<xsl:value-of select="replace(document-uri(/), '.*/(.*)\.xml$', '$1')"/>
					</td>
					<td class="text">
						<xsl:variable name="text" select="string-join(following::* except document(@spanTo)/following::*, '')" as="xs:string"/>
						<xsl:value-of select="concat(substring($text, 1, 15), ' […] ' (:, substring($text, string-length($text) - 15):))"/>
					</td>
				</tr>				
			</xsl:for-each>
		</table>
	</xsl:template>
	
	<xsl:template name="find-grline">
		<h2>f:grLine – sonstige Linien</h2>
		
		<table>
			<tr>
				<th>Document</th>
				<th>Attribute</th>				
			</tr>
			
			<xsl:for-each select="$coll//f:grLine">
				<xsl:sort select="document-uri(/)"/>
				<tr>
					<td class="doc">
						<xsl:value-of select="replace(document-uri(/), '.*/(.*)\.xml$', '$1')"/>
					</td>
					<td>
						<xsl:for-each select="@*">
							<xsl:value-of select="concat(name(), '=', ., ' ')"/>
						</xsl:for-each>
					</td>					
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>
	
	

	<xsl:template match="*">
		<xsl:param name="highlight" tunnel="yes" as="element()?"/>		
		<xsl:choose>
			<xsl:when test=". is $highlight">
				<mark><xsl:apply-templates/></mark>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates>
					<xsl:with-param name="highlight" select="$highlight" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	
	
	<xsl:template name="find-rewrites">
		<h3>spezielle Rewrites, siehe <a href="https://github.com/faustedition/faust-gen-html/issues/188">#188</a></h3>
		<table>
			<tr>
				<th>Fall</th>
				<th>Seite</th>
				<th>Text</th>
				<th>hand</th>
				<th>rewrite</th>
			</tr>

			<xsl:for-each select="$coll">
				<xsl:sort select="document-uri(/)"/>
				<xsl:message select="document-uri(/)"/>

				<xsl:for-each
					select='//text()[preceding::tei:handShift[1][@new = "#g_bl"] and ancestor::ge:rewrite[@hand[contains(., "#g_t")]]][not(ancestor::rdg)]'>
					<xsl:call-template name="match">
						<xsl:with-param name="case">1</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>

				<xsl:for-each
					select='//text()[preceding::tei:handShift[1][@new = "#g_bl"] and ancestor::ge:rewrite[not(@hand[contains(., "#g_")])]][not(ancestor::rdg)]'>
					<xsl:call-template name="match">
						<xsl:with-param name="case">2</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>

				<xsl:for-each
					select="//ge:rewrite[contains(@hand, '#g_t')]//text()[preceding::tei:handShift[1][contains(@new, '_bl') and not(contains(@new, '#g_'))]][not(ancestor::rdg)]">
					<xsl:call-template name="match">
						<xsl:with-param name="case">3</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>

			</xsl:for-each>
		</table>
	</xsl:template>
	
	<xsl:template name="match">
		<xsl:param name="case">?</xsl:param>
		<tr class="case{$case}">
			<td class="case"><xsl:value-of select="$case"/></td>
			<td class="doc">
				<xsl:value-of select="replace(document-uri(/), '.*/(.*)\.xml$', '$1')"/>
			</td>
			<td class="text">
				<xsl:value-of select="."/>
			</td>
			<td><xsl:value-of select="preceding::handShift[1]/@new"/></td>
			<td><xsl:value-of select="ancestor::ge:rewrite/@hand"/></td>
			<td>
				<xsl:apply-templates select="ancestor::ge:line">
					<xsl:with-param name="highlight" select="ancestor-or-self::ge:rewrite[1]" tunnel="yes"/>
				</xsl:apply-templates>
			</td>
		</tr>
	</xsl:template>


</xsl:stylesheet>