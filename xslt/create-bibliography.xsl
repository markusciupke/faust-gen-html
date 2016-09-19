<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:import href="faust-metadata.xsl"/>
	<xsl:import href="utils.xsl"/>
	
	<xsl:param name="headerAdditions">
		<style type="text/css">
			.bibliography dt .hover-link {
				color: gray;
				font-weight: normal;
				padding-left: 0.25em;
				visibility: hidden;				
			}
			.bibliography dt:hover .hover-link {
				visibility: visible;
			}
			.bib-backrefs a {
				white-space: nowrap;
			}
		</style>
	</xsl:param>
	
	<xsl:template match="/">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="title" tunnel="yes">Bibliographie</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:variable name="entries" as="element()*">
					<xsl:for-each-group select="//f:citation" group-by=".">
						<xsl:variable name="citation" select="f:cite(current-grouping-key(), 'dd')"/>
						<xsl:variable name="backrefs" as="element()*">
							<xsl:for-each select="current-group()[@from]">							
								<xsl:sequence select="f:resolve-faust-doc(@from, $transcript-list)"/>
							</xsl:for-each>
						</xsl:variable>
						<xsl:variable name="backref-part">
							<xsl:for-each-group select="$backrefs" group-by=".">
								<xsl:sort select="f:splitSigil(.)[1]" stable="yes"/>
								<xsl:sort select="f:splitSigil(.)[2]" data-type="number"/>
								<xsl:sort select="f:splitSigil(.)[3]"/>								                    
								
								<xsl:copy-of select="current-group()[1]"/>
								<xsl:if test="position() != last()">, </xsl:if>
							</xsl:for-each-group>
						</xsl:variable>
						<xsl:for-each select="$citation">
							<xsl:copy>
								<xsl:copy-of select="@*"/>
								<xsl:copy-of select="node()"/>
								<xsl:if test="$backrefs">
									<xsl:text> </xsl:text>								
									<small class="bib-backrefs">
										<xsl:copy-of select="$backref-part"/>
									</small>
								</xsl:if>
							</xsl:copy>
						</xsl:for-each>
					</xsl:for-each-group>
				</xsl:variable>
				<main>
					<div class="main-content-container" style="margin-bottom:0em;">
						<div id="main-content" class="main-content">
							<div style="display: block;" class="archive-content view-content"
								id="archive-content">
								
								<section class="center pure-g-r">
									<article class="pure-u-1">
										
										<dl class="bibliography">
											<xsl:for-each select="$entries">
												<xsl:sort select="lower-case(replace(@data-citation, '(\D+)(\d*)(\D*)(\d*)', '$1'))"/>
												<xsl:sort select="    number(replace(@data-citation, '(\D+)(\d*)(\D*)(\d*)', '$2'))"/>
												<xsl:sort select="lower-case(replace(@data-citation, '(\D+)(\d*)(\D*)(\d*)', '$3'))"/>
												<xsl:sort select="    number(replace(@data-citation, '(\D+)(\d*)(\D*)(\d*)', '$4'))"/>
												<xsl:variable name="id"
													select="replace(@data-bib-uri, '^faust://bibliography/', '')"/>
												<dt id="{$id}">
													<xsl:value-of select="@data-citation"/>
													<a href="#{$id}" class="hover-link">¶</a>
												</dt>
												<xsl:sequence select="."/>
											</xsl:for-each>
										</dl>
										
									</article>
								</section>
							</div>
						</div>
					</div>
				</main>
				
				<script type="text/javascript">
					// set breadcrumbs
					document.getElementById("breadcrumbs").appendChild(Faust.createBreadcrumbs([{caption: "Archiv"}]));
				</script>
				
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
</xsl:stylesheet>
