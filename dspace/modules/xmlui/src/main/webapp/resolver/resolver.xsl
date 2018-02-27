<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.1">

	<xsl:param name="purl"/>
	<xsl:param name="query"/>
	<xsl:variable name="baseURL">http://goescholar.goedoc.uni-goettingen.de</xsl:variable>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="resolvedLPIs">
		<resolvedLPIs>
			<LPI>
				<requestedLPI>
                                                <xsl:value-of select="concat($baseURL, '/resolvexml?', $query)"/>
                                </requestedLPI>
                                <service>Goescholar: Publcation Server Uni Göttingen</service>
                                <servicehome><xsl:value-of select="$baseURL"/></servicehome>

		<xsl:choose>
			<!-- resolve only requests which are in the purl-mapping or starts with 'univerlag-' -->
			<xsl:when test="starts-with($query, 'purl=goescholar')">
				<xsl:variable name="lpi"><xsl:value-of select="substring-after($query, 'goescholar/')" /></xsl:variable>
				<url>
						<xsl:value-of select="concat($baseURL, '/handle/','1/', $lpi)" />

				</url>
				<mime>text/html</mime>
				<version>1.0</version>
                                <access>free</access>
			</xsl:when>
			<xsl:when test="starts-with($query, 'purl=gs-1')">
				<xsl:variable name="lpi"><xsl:value-of select="substring-after($query, 'gs-')" /></xsl:variable>
				<url>
						<xsl:value-of select="concat($baseURL, '/handle/', $lpi)" />

				</url>
				<mime>text/html</mime>
                                <version>1.0</version>
                                <access>free</access>
			</xsl:when>
			<xsl:otherwise>
				<URL />
			</xsl:otherwise>
		</xsl:choose>

		
                 <xsl:apply-templates select="@*|node()"/> 
                          </LPI>
		</resolvedLPIs>
        </xsl:template>


</xsl:stylesheet>
	



