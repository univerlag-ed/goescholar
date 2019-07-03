<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering specific to the item display page.

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:output indent="yes"/>

    <xsl:variable name="doi-resolver"><xsl:text>http://doi.org</xsl:text></xsl:variable>
    <xsl:variable name="handle"><xsl:value-of select="//dri:metadata[@element='request' and @qualifier='URI'] "/></xsl:variable> 
    <xsl:variable name="servername"><xsl:value-of select="//dri:metadata[@element='request' and @qualifier='serverName']"/></xsl:variable>
    <xsl:variable name="uri"><xsl:value-of select="//dri:metadata[@element='request'][@qualifier='URI']"/></xsl:variable>
    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
        mode="itemSummaryView-DIM"/>

	<!--<xsl:if test="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@qualifier='eusponsor']">
		<div class="row" >
			<xsl:for-each select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@qualifier='eusponsor']" >
			<xsl:variable name="info"><xsl:value-of select="substring-after(., 'EC/')" /></xsl:variable>
			<xsl:variable name="framework">
			<xsl:choose>
				<xsl:when test="contains(., '/FP7/')">
					<xsl:text>FP7</xsl:text>
				</xsl:when>
                                <xsl:when test="contains(., '/H2020/')">
					<xsl:text>H2020</xsl:text>
                                </xsl:when>
			</xsl:choose>
			</xsl:variable>
				<div class="col-sm-3 col-xs-12">
                                         <a href="#">
                                                        <img class="img-responsive" src="" />
                                                </a>
                                        </div>
                                        <div class="col-sm-8">
                                                <span><i18n:text>xmlui.Mirage2.DIM-Project-ref</i18n:text><xsl:value-of select="substring-before(substring-after($info, $framework), '/EU') " /></span>
                                                <span><i18n:text>xmlui.Mirage2.DIM-Project-name</i18n:text><xsl:value-of select="substring-after($info,'EU/') " /></span>
                                        </div>

			</xsl:for-each>
		</div>
	</xsl:if> -->
        <xsl:copy-of select="$SFXLink" />

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
            <div class="license-info table">
                <p>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.license-text</i18n:text>
                </p>
                <ul class="list-unstyled">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="simple"/>
                </ul>
            </div>
        </xsl:if>
	<xsl:if test="not(//dim:field[@element='rights'][@qualifier='uri'])">
		<i18n:text>xmlui.dri2xhtml.METS-1.0.standard-license-text</i18n:text>
	</xsl:if>


    </xsl:template>

    <!-- An item rendered in the detailView pattern, the "full item record" view of a DSpace item in Manakin. -->
    <xsl:template name="itemDetailView-DIM">
        <!-- Output all of the metadata about the item from the metadata section -->
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemDetailView-DIM"/>

        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3>
                <div class="file-list">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE' or @USE='CC-LICENSE']">
                        <xsl:with-param name="context" select="."/>
                        <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemDetailView-DIM" />
            </xsl:when>
            <xsl:otherwise>
                <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <div class="item-summary-view-metadata">
            <xsl:call-template name="itemSummaryView-DIM-title"/>
	    <xsl:call-template name="itemSummaryView-DIM-MyAuthors"/>
 	    <xsl:call-template name="itemSummaryView-DIM-URI"/> 
            <div class="row">
                <div class="col-sm-6 files">
                    <div class="row">
                       <!--  <div class="col-xs-6 col-sm-12">
                            <xsl:call-template name="itemSummaryView-DIM-thumbnail"/>
                        </div> -->
                        <div class="col-xs-6 col-sm-12">
			    <xsl:variable name="version"><xsl:value-of select="//mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='type' and @qualifier='version']" /></xsl:variable>
			    <xsl:variable name="type">
				<xsl:choose>
                                <xsl:when test="//dim:field[@element='type' and @qualifier='subtype'] and (//dim:field[@element='type' and @qualifier='subtype'] != //dim:field[@element='type' and not(@qualifier)])">
                                        <xsl:value-of select="//dim:field[@element='type' and @qualifier='subtype']" />
                                </xsl:when>
                                <xsl:otherwise>
                                        <xsl:value-of select="//dim:field[@element='type' and not(@qualifier)]"/>
                                </xsl:otherwise>
                        	</xsl:choose>
			    </xsl:variable>

			    <h5>
			    <xsl:if test="//mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='description' and @qualifier='status'] = 'peerReviewed'">
                                <!-- <i title="peer reviewed" class="fa fa-star" aria-hidden="true"></i> -->
                            </xsl:if>
			    <i18n:text><xsl:value-of select="concat('xmlui.Mirage2.DIM-type-', $type)" /></i18n:text>
		            <!--<xsl:choose>
                	        <xsl:when test="$type = 'journal article'">
                        	        <i18n:text>xmlui.Mirage2.DIM-journal-article</i18n:text>
	                        </xsl:when>
        	                <xsl:when test="$type = 'anthology article'">
                	                <i18n:text>xmlui.Mirage2.DIM-anthology-article</i18n:text>
	                        </xsl:when>
        	                <xsl:when test="$type = 'anthology'">
					<i18n:text>xmlui.Mirage2.DIM-anthology</i18n:text>
	                       	</xsl:when>
        	                <xsl:when test="$type = 'monograph'">
                	                <i18n:text>xmlui.Mirage2.DIM-monograph</i18n:text>
                        	</xsl:when>
	                        <xsl:when test="$type = 'workingPaper'">
        	                        <i18n:text>xmlui.Mirage2.DIM-working-paper</i18n:text>
                	        </xsl:when>
				<xsl:when test="$type = 'review'">
                                        <i18n:text>xmlui.Mirage2.DIM-review</i18n:text>
                                </xsl:when>
		            </xsl:choose> -->
			    <xsl:if test="string-length($version) &gt; 1">
				    <i18n:text><xsl:value-of select="concat('xmlui.Mirage2.DIM-version-', $version)" /></i18n:text>
			    </xsl:if>
                            <!-- <xsl:choose>
                                <xsl:when test="$version = 'publishedVersion'">
                                        <i18n:text>xmlui.Mirage2.DIM-published-version</i18n:text>
                                </xsl:when>
                                <xsl:when test="$type = 'submittedVersion'">
                                        <i18n:text>xmlui.Mirage2.DIM-submitted-version</i18n:text>
                                </xsl:when>
                                <xsl:when test="$type = 'acceptedVersion'">
                                        <i18n:text>xmlui.Mirage2.DIM-accepted-version</i18n:text>
                                </xsl:when>
                            </xsl:choose> -->
			    </h5>		 
                            <xsl:call-template name="itemSummaryView-DIM-file-section"/>
                        </div>
                    </div>
                    <xsl:if test="$ds_item_view_toggle_url != ''">
                        <xsl:call-template name="itemSummaryView-show-full"/>
                    </xsl:if>
                </div>
                <div class="col-sm-6 metadata">
		    <xsl:call-template name="itemSummaryView-DIM-biblio"/>
                    <xsl:call-template name="itemSummaryView-DIM-citations"/>
                </div>
            </div>
	    <xsl:call-template name="itemSummaryView-DIM-abstract"/>
	    <xsl:call-template name="itemSummaryView-DIM-toc"/>
	    <!-- <xsl:call-template name="itemSummaryView-DIM-notes"/> -->
            <xsl:call-template name="itemSummaryView-DIM-Sponsorship" />
	    <xsl:call-template name="itemSummaryView-DIM-notes"/>
	<!-- <xsl:call-template name="itemSummaryView-collections"/> -->
	    <xsl:if test="not(contains($uri, 'submit'))">
		    <xsl:call-template name="itemSummaryView-services" />
	    </xsl:if>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-title">
        <xsl:choose>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                <h2 class="first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
                <div class="simple-item-view-other">
                    <p class="lead">
                        <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                            <xsl:if test="not(position() = 1)">
                                <xsl:value-of select="./node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                    <xsl:text>; </xsl:text>
                                    <br/>
                                </xsl:if>
                            </xsl:if>

                        </xsl:for-each>
                        <xsl:for-each select="dim:field[@element='title'][@qualifier='alternative']">
                                <xsl:value-of select="." />
                                <xsl:if test="position() != last()">
                                        <xsl:text>; </xsl:text>
                                </xsl:if>
                         </xsl:for-each>
                    </p>
                </div>
            </xsl:when>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                <h2 class="first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
		<div class="simple-item-view-other">
                    <p class="lead">
                    <xsl:for-each select="dim:field[@element='title'][@qualifier='alternative']">
                    	<xsl:value-of select="." />
	                    <xsl:if test="position() != last()">
        		            <xsl:text>; </xsl:text>
	                    </xsl:if>
                    </xsl:for-each>
                    </p>
		    <xsl:for-each select="dim:field[@element='title'][@qualifier='translated']">
			<p class="lead">
				<xsl:value-of select="." />
			</p>
		    </xsl:for-each>
                </div>
		

            </xsl:when>
            <xsl:otherwise>
                <h2 class="first-page-header">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                </h2>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-thumbnail">
        <div class="thumbnail">
            <xsl:choose>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                    <xsl:variable name="src">
                        <xsl:choose>
                            <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]">
                                <xsl:value-of
                                        select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <img alt="Thumbnail">
                        <xsl:attribute name="src">
                            <xsl:value-of select="$src"/>
                        </xsl:attribute>
                    </img>
                </xsl:when>
                <xsl:otherwise>
                    <img alt="Thumbnail">
                        <xsl:attribute name="data-src">
                            <xsl:text></xsl:text>
                            <xsl:value-of select="$thumbnail.maxheight"/>
                            <xsl:text>No Thumbnail</xsl:text>
                        </xsl:attribute>
                    </img>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-abstract">
        <xsl:if test="dim:field[@element='description' and @qualifier='abstract']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5 class="visible-xs"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-toc">
        <xsl:if test="dim:field[@element='description' and @qualifier='tableofcontents']">
            <div class="simple-item-view-toc item-page-field-wrapper table">
                <h4><i18n:text>xmlui.dri2xhtml.METS-1.0.item-toc</i18n:text></h4>
                <div>
                    <xsl:for-each select="dim:field[@element='description' and @qualifier='tableofcontents']">
                        <xsl:choose>
                            <xsl:when test="node()">
				<xsl:value-of select="." disable-output-escaping="yes" /> 
                                <!-- <xsl:copy-of select="node()"/>  -->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-notes">
	<xsl:for-each select="//dim:field[@element='notes' and not(@qualifier='intern')]">
		<div class="alert alert-info" role="alert">
			<xsl:value-of select="."/>
		</div>
	</xsl:for-each>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-MyAuthors">
	<h3 class="page-header authors">
	<xsl:if test="dim:field[@element='contributor'][@qualifier='author' and descendant::text()]">
		<xsl:for-each select="dim:field[@element='contributor'][@qualifier='author'][position() &lt; 9]">
			<a>
			    <xsl:attribute name="href"><xsl:value-of select="concat('/browse?type=author&amp;value=', substring-before(., ','), '%2C', translate(substring-after(., ','), ' ', '+'))" /></xsl:attribute>
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
			</a>
			    <xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
               </xsl:for-each>
		<xsl:if test="count(//dim:field[@element='contributor'][@qualifier='author' and descendant::text()]) &gt; 8">
			<a href="#" data-toggle="collapse" data-target="#ffauthor"> et al.</a>
			
			<div id="ffauthor" class="collapse">
				<xsl:for-each select="dim:field[@element='contributor'][@qualifier='author'][position() &gt; 8]">
                        <a>
                            <xsl:attribute name="href"><xsl:value-of select="concat('/browse?type=author&amp;value=', substring-before(., ','), '%2C', translate(substring-after(., ','), ' ', '+'))" /></xsl:attribute>
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </a>
                            <xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
               </xsl:for-each>
			</div>
		</xsl:if>
	</xsl:if>
	<xsl:if test="dim:field[@element='contributor'][@qualifier='editor' and descendant::text()]">
                <xsl:for-each select="dim:field[@element='contributor'][@qualifier='editor']">
			<a>
                            <xsl:attribute name="href"><xsl:value-of select="concat('/browse?type=author&amp;value=', substring-before(., ','), '%2C', translate(substring-after(., ','), ' ', '+'))" /></xsl:attribute>
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </a>
			    <xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
               </xsl:for-each>
		<xsl:text> (Eds.) </xsl:text>
        </xsl:if>
        </h3>
	<xsl:if test="//dim:field[@element='relation'][@qualifier='reviewing' and descendant::text()]">
	<div>
		<i18n:text>xmlui.Mirage2.DIM-reviewing</i18n:text>
		<xsl:for-each select="//dim:field[@element='relation'][@qualifier='reviewing' and descendant::text()]">
			<p class="reviewing">
				<xsl:value-of select="." />
			</p>
		</xsl:for-each>
	</div>
	</xsl:if>
	<xsl:for-each select="//dim:field[@element='relation'][contains(@qualifier,'errata') and descendant::text()]">
	<div class="relations">
		<xsl:choose>
			<xsl:when test="@qualifier = 'haserrata'">
				<a>
					<xsl:attribute name="href"><xsl:value-of select="." /></xsl:attribute>
					 <i18n:text>xmlui.Mirage2.DIM-has-erratum</i18n:text>
				</a>
			</xsl:when>
			<xsl:when test="@qualifier = 'iserrataof'">
				<a>
                                        <xsl:attribute name="href"><xsl:value-of select="." /></xsl:attribute>
                                         <i18n:text>xmlui.Mirage2.DIM-is-erratumof</i18n:text>
                                </a>
			</xsl:when>
		</xsl:choose>
	</div>
	</xsl:for-each>
	<xsl:for-each select="//dim:field[@element='relation'][contains(@qualifier,'data') and descendant::text()]">
        <div class="relations">
                <xsl:choose>
                        <xsl:when test="@qualifier = 'hasdata'">
				<a>
                                        <xsl:attribute name="href"><xsl:value-of select="." /></xsl:attribute>
                                         <i18n:text>xmlui.Mirage2.DIM-has-data</i18n:text>
                                </a>
                        </xsl:when>
                        <xsl:when test="@qualifier = 'isdataof'">
				<a>
                                        <xsl:attribute name="href"><xsl:value-of select="." /></xsl:attribute>
                                         <i18n:text>xmlui.Mirage2.DIM-is-dataof</i18n:text>
                                </a>

                        </xsl:when>
                </xsl:choose>
        </div>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='author' and descendant::text()] or dim:field[@element='creator' and descendant::text()] or dim:field[@element='contributor' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table">
                <h5 class="authors"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text></h5>
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='creator']">
                        <xsl:for-each select="dim:field[@element='creator']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='contributor']">
                        <xsl:for-each select="dim:field[@element='contributor']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors-entry">
            <!-- <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
            </xsl:if> -->
            <xsl:copy-of select="node()"/>
	    <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-citations">
	    <xsl:variable name="title" select="//dim:field[@element='title' and not(@qualifier)]"/>
	    <xsl:variable name="doi" select="//dim:field[@element='identifier' and @qualifier='doi']"/>
	    <!-- Do not show on submission page -->
	    <xsl:if test="not(contains($uri, 'submit'))">
	    	<div class="gs visible-lg visible-md">
			<a target='_blank'>
				<xsl:attribute name="href"><xsl:value-of select="concat('//scholar.google.de/scholar?q=&#034;', $title, '&#034;')" /></xsl:attribute>
				<i18n:text>googlescholar</i18n:text> <i class="fa fa-external-link" aria-hidden="true"></i>
			</a>
	    	</div>
                <xsl:if test="string-length($doi) &gt; 0 ">
                        <div class="altmetric-embed" data-badge-type="default" data-hide-no-mentions="true" data-badge-details="right">
                                <xsl:attribute name="data-doi"><xsl:value-of select="$doi" /></xsl:attribute>
                                        &#160;
                       </div>
	        </xsl:if>
	     </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-URI">
        <div class="uri"><!-- <i class="fa fa-clipboard" aria-hidden="true"></i> --><strong><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text></strong>
                
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
			<span class="bookmark">
                        <!-- <a>
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute> -->
                            <xsl:copy-of select="./node()"/>
                        <!-- </a> -->
			</span>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-biblio">
	<!-- <xsl:if test="(//dim:field[@element='type' and not(@qualifier)] != 'preprint') and (//dim:field[@element='type' and not(@qualifier)] != 'lecture')"> -->
		<h5>
			<i18n:text>xmlui.Mirage2.DIM-firstpublished</i18n:text>
			<xsl:if test="not(//dim:field[@element='type' and @qualifier='version'])"> 
				<i18n:text>xmlui.Mirage2.DIM-firstpublished-goescholar</i18n:text>
				<xsl:value-of select="concat(' ', substring(//dim:field[@element='date' and @qualifier='issued'],1,4))"/>
			</xsl:if>
			<xsl:if test="//mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='description' and @qualifier='status'] = 'peerReviewed'">
                                <!-- <i title="peer reviewed" class="fa fa-star" aria-hidden="true"></i> -->
				<!-- <img class="ginkigo" alt="gingko" i18n:attr="title"  title="xmlui.Mirae2.publ-status" src="{concat($theme-path,'/images/goescholar.png')}"></img> -->
				<xsl:text> (</xsl:text><i18n:text>xmlui.Mirae2.publ-status</i18n:text><xsl:text>)</xsl:text>
                            </xsl:if>
		</h5>
	<!-- </xsl:if>  -->
	<xsl:if test="//dim:field[@element='identifier' and @qualifier='doi']">
		<div>
			<xsl:text>DOI: </xsl:text>
			<a target="_blank">
			<xsl:attribute name="href">
				<xsl:value-of select="concat($doi-resolver, '/', //dim:field[@element='identifier' and @qualifier='doi'])"/>
			</xsl:attribute>
			<xsl:value-of select="//dim:field[@element='identifier' and @qualifier='doi']"/> <i class="fa fa-external-link" aria-hidden="true"></i>
			</a>
		</div>
	</xsl:if>
	<div class="publisher">
	    <xsl:for-each select="//dim:field[@element='relation' and @qualifier='ispartofseries']">
                        <xsl:value-of select='.'/>
                        <xsl:if test="//dim:field[@element='bibliographicCitation' and @qualifier='volume']">
                        <xsl:value-of select="concat('; ', //dim:field[@element='bibliographicCitation' and @qualifier='volume'])" />
                        </xsl:if>
                </xsl:for-each>
	    <xsl:choose>
		<xsl:when test="//dim:field[@element='identifier'][@qualifier='bibliographicCitation']">
                                <xsl:value-of select="//dim:field[@element='identifier'][@qualifier='bibliographicCitation']"/>
                        </xsl:when>	
		<!-- <xsl:when test="dim:field[@element='type' and @qualifier='subtype'] = 'journal article'"> -->
		<xsl:when test="//dim:field[@element='bibliographicCitation' and @qualifier='journal']">
			<xsl:value-of select="//dim:field[@element='bibliographicCitation' and @qualifier='journal']" />
			<xsl:if test="//dim:field[@qualifier='volume']">
                                <xsl:value-of select="concat(' ', substring(//dim:field[@element='date' and @qualifier='issued'],1,4), '; ')" />
                                <xsl:value-of select="//dim:field[@qualifier='volume']" />
                        </xsl:if>
                        <xsl:if test="//dim:field[@qualifier='issue']">
                                <xsl:value-of select="concat('(', //dim:field[@qualifier='issue'], ')')" />
                        </xsl:if>
                        <xsl:if test="//dim:field[@qualifier='firstPage'] and //dim:field[@qualifier='lastPage']">
                                <xsl:value-of select="concat('  p.', //dim:field[@qualifier='firstPage'], '-', //dim:field[@qualifier='lastPage'])" />
                        </xsl:if>
                        <xsl:if test="//dim:field[@qualifier='articlenumber']">
                                <xsl:value-of select="concat(': Art. ', //dim:field[@qualifier='articlenumber'])" />
                        </xsl:if>
			<xsl:if test="//dim:field[@element='publisher']">
				<div><xsl:value-of select="//dim:field[@element='publisher']" /></div>	
			</xsl:if>	
		</xsl:when>
		<xsl:when test="//dim:field[@qualifier='event']">
			<xsl:value-of select="//dim:field[@qualifier='event']" />
			<xsl:if test="//dim:field[@qualifier='eventDate']">
                                <xsl:value-of select="concat(', ', //dim:field[@qualifier='eventDate'])" />
                        </xsl:if>
 			<xsl:if test="//dim:field[@qualifier='eventLocation']">
                                <xsl:value-of select="concat(', ', //dim:field[@qualifier='eventLocation'])" />
                        </xsl:if>
		</xsl:when>
		<xsl:when test="//dim:field[@element='publisher']">
		<div>
                                <xsl:value-of select="//dim:field[@element='publisher']" />
				<xsl:text>, </xsl:text>
                                <xsl:value-of select="substring(//dim:field[@element='date' and @qualifier='issued'],1,4)" />
		</div>
               </xsl:when>
	     </xsl:choose>
		
	   </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-date">
        <xsl:if test="dim:field[@element='date' and @qualifier='issued' and descendant::text()]">
            <div class="simple-item-view-date word-break item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
                    <xsl:copy-of select="substring(./node(),1,10)"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-services">
	<!-- <div class="btn-group">
		<a class="btn btn-default statistics" data-toggle="modal" data-target="#stats" role="button">
		<xsl:attribute name="data-remote"><xsl:value-of select="concat('/',  $handle, '/statistics')" /></xsl:attribute>
		<span class="bootstrap-dialog-button-icon glyphicon glyphicon-stats"></span>Nutzungsstatistik</a>
	</div>
	<div class="btn-group">
		<button type="button" class="btn btn-default" role="button"><span class="bootstrap-dialog-button-icon glyphicon glyphicon-link"></span><a href="{concat('http://scholar.google.de/scholar?hl=de&amp;q=', dim:field[@element='title'])}">GoogleScholar</a></button>
	</div>-->
	<xsl:if test="not(//dim:field[@qualifier='iserrataof'])">
        <div class="btn-group">
		<button type="button" class="btn btn-default" data-toggle="modal" data-target="#export"><span class="bootstrap-dialog-button-icon glyphicon glyphicon-export"></span>Export</button>
	</div>
	</xsl:if>
        <div class="btn-group">
		<button type="button" class="btn btn-default" data-toggle="modal" data-target="#share"><span class="bootstrap-dialog-button-icon glyphicon glyphicon-share"></span>Teilen</button>
		
	</div>
	<!-- <div class="btn-group">
                <a class="btn btn-default statistics" role="button">
                <xsl:attribute name="href"><xsl:value-of select="concat('/',  $handle, '/statistics')" /></xsl:attribute>
                <span class="bootstrap-dialog-button-icon glyphicon glyphicon-stats"></span>Nutzungsstatistik</a>
        </div>
	<div class="modal" id="stats" tabindex="-1" role="dialog">
	   <div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">x</span></button>
                                <h4 class="modal-title" id="myModalLabel">Nutzungsstatistik</h4>
                        </div>
                        <div class="modal-body">
			</div>
			<div class="modal-footer">
                                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                        </div>
		</div>
	   </div>
	</div> -->
	<div class="modal" id="export" tabindex="-1" role="dialog" ria-labelledby="myModalLabel">
	  <form method="get" class="form-horizontal" role="form">
	   <xsl:attribute name="action"><xsl:value-of select="concat('/mdexport/handle', substring-after($handle, 'handle'))" /></xsl:attribute>
		<div class="modal-dialog" role="dialog">
			<div class="modal-content">
			      <div class="modal-header">
			        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">x</span></button>
			        <h4 class="modal-title" id="myModalLabel">Metadaten-Export</h4>
			      </div>
			      <div class="modal-body">
								
								<div class="radio">
									<label><input type="radio" name="format" value="ris" checked="" ></input>refMan</label>
								</div>
								<div class="radio">
									<label><input type="radio" name="format" value="ris" >Citavi</input></label>
								</div>
								<div class="radio">
									<label><input type="radio" name="format" value="endnote" ></input>Endnote</label>
								</div>
								<div class="radio">
									<label><input type="radio" name="format" value="bibtex" ></input>BibTeX</label>
								</div>
							
			     </div>
			     <div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				<button type="submit" class="btn btn-primary">Download</button>
			     </div>
    			</div>
		</div>
	   </form>
	</div>
	<div class="modal" id="share" tabindex="-1" role="dialog" ria-labelledby="myModalLabel">
                <div class="modal-dialog" role="document">
                        <div class="modal-content">
                              <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">x</span></button>
                                <h4 class="modal-title" id="myModalLabel">Teilen</h4>
                              </div>
                              <div class="modal-body">
				<ul>
				   <li>
					<a target="_blank"> 
					<xsl:attribute name="href"><xsl:value-of select="concat('//www.mendeley.com/import/?url=', //dim:field[@element='identifier'][@qualifier='uri']) "/></xsl:attribute>
					<img title="Mendeley" src="{concat($theme-path,'/images/mendeley-16.png')}"></img></a>
				    </li>
				    <li>	
					<a target="_blank">
                                        <xsl:attribute name="href"><xsl:value-of select="concat('http://www.linkedin.com/shareArticle?url=', //dim:field[@element='identifier'][@qualifier='uri'], '&amp;title=', //dim:field[@element='title' and not(@qualifier)]) "/></xsl:attribute>
                                <img src="{concat($theme-path,'/images/linkedin-16.png')}" title="LinkedIn"> </img>
                                </a>
				    </li>
				    <li>
				<a target="_blank">
				
				
                                        <xsl:attribute name="href"><xsl:value-of select="concat('http://www.bibsonomy.org/ShowBookmarkEntry?&amp;c=b&amp;jump=yes&amp;url=', //dim:field[@element='identifier'][@qualifier='uri'], '&amp;description=', //dim:field[@element='title' and not(@qualifier)]) "/></xsl:attribute>
                                <img src="{concat($theme-path,'/images/bibsonomy-16.png')}" title="Bibsonomy"> </img>
                                </a>
				     </li>
				     <li>
                                <a target="_blank">
				<xsl:attribute name="href"><xsl:value-of select="concat('http://twitter.com/intent/tweet?text=', //dim:field[@element='title' and not(@qualifier)], '&amp;url=', //dim:field[@element='identifier' and @qualifier='uri']) "/></xsl:attribute>
                                <img src="{concat($theme-path,'/images/twitter-16.png')}" title="Twitter"> </img>
                                </a>
				    </li>
				</ul>
                             </div>
                             <div class="modal-footer">
                                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                             </div>
                        </div>
                </div>
        </div>
<!--	<ul class="nav nav-tabs" role="tablist">
	  <li role="presentation"><a href="#">Statistik</a></li>
	  <li role="presentation"><a href="#">Export</a></li>
	  <li role="presentation"><a href="#">Teilen</a></li>
	</ul> -->

	<div class="simple-item-services word-break item-page-field-wrapper table hide-sm hide-xs">
<!--                <h5>
                </h5>
		<div>
		<a>		
			<xsl:attribute name="href"><xsl:value-of select="concat('http://scholar.google.de/scholar?hl=de&amp;q=', dim:field[@element='title'])" /></xsl:attribute>
			GoogleScholar
		</a>
		</div>
		<div>
			<a>
			<xsl:attribute name="href"><xsl:value-of select="concat('/', $handle, '/statistics')" /></xsl:attribute>
                        Nutzungsstatistik
                </a>

		</div> -->
        </div> 

    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-Sponsorship">
        <xsl:if test="dim:field[@element='relation' and not(@qualifier) and descendant::text()]">
            <div class="simple-item-view-date word-break item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.Mirage2.DIM-sponsorship</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='relation' and not(@qualifier)]">
		<xsl:if test="contains(., 'FP7') or contains(., 'H2020')">
		<div>
			<xsl:variable name="info"><xsl:value-of select="substring-after(., 'EC/')" /></xsl:variable>
                        <xsl:variable name="framework">
                        <xsl:choose>
                                <xsl:when test="contains(., '/FP7/')">
                                        <xsl:text>FP7</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(., '/H2020/')">
                                        <xsl:text>H2020</xsl:text>
                                </xsl:when>
                        </xsl:choose>
                        </xsl:variable>
				<img class="sponsor-img" src="{concat($theme-path, '/images/', $framework, '.jpg')}" />
				<span><i18n:text>xmlui.Mirage2.DIM-Project-name</i18n:text>
					<xsl:if test="not(contains($info, '//'))">
						<xsl:value-of select="substring-before(substring-after($info,'EU/'), '/') " />
						<xsl:text> (</xsl:text><xsl:value-of select="substring-after(substring-after($info,'EU/'), '/') " /><xsl:text>)</xsl:text>
					</xsl:if>
				<!-- <i18n:text>xmlui.Mirage2.DIM-Project-ref</i18n:text>
				<xsl:value-of select="substring-before(substring-after($info, $framework), '/EU') " />-->
					<xsl:value-of select="substring-after($info, '//') " />
				</span>
		</div>	
		</xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
	<xsl:if test="dim:field[@element='description' and @qualifier='sponsorship' and descendant::text()]">
		<div class="simple-item-view-date word-break item-page-field-wrapper table">
                <h5>
                    <xsl:text>Sponsor:</xsl:text>
                </h5>
                <xsl:for-each select="dim:field[@element='description' and @qualifier='sponsorship']">
		<div>
			<xsl:value-of select="."/>
		</div>	
		</xsl:for-each>
		</div>
	</xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-show-full">
	<!-- Do not show on submission page -->
        <xsl:if test="not(contains($uri, 'submit'))">
        <div class="simple-item-view-show-full item-page-field-wrapper table">
            <!-- <h5>
                <i18n:text>xmlui.mirage2.itemSummaryView.MetaData</i18n:text>
            </h5>-->
            <a>
                <xsl:attribute name="href"><xsl:value-of select="$ds_item_view_toggle_url"/></xsl:attribute>
                <!-- <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text> -->
		&#160;&#160;
            </a>
        </div>
	</xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-collections">
        <xsl:if test="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']">
            <div class="simple-item-view-collections item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.mirage2.itemSummaryView.Collections</i18n:text>
                </h5>
                <xsl:apply-templates select="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']/dri:reference"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section">
        <xsl:choose>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <div class="item-page-field-wrapper table word-break">
                    <!-- <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                    </h5> -->

                    <xsl:variable name="label-1">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.1')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.1')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>label</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="label-2">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.2')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.2')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>title</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                        <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                            <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                            <xsl:with-param name="mimetype" select="@MIMETYPE" />
                            <xsl:with-param name="label-1" select="$label-1" />
                            <xsl:with-param name="label-2" select="$label-2" />
                            <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                            <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" />
                            <xsl:with-param name="size" select="@SIZE" />
                        </xsl:call-template>
                    </xsl:for-each>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemSummaryView-DIM" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section-entry">
        <xsl:param name="href" />
        <xsl:param name="mimetype" />
        <xsl:param name="label-1" />
        <xsl:param name="label-2" />
        <xsl:param name="title" />
        <xsl:param name="label" />
        <xsl:param name="size" />
	<div>
	<xsl:if test="contains($href, '.mp4')">
		<video controls="yes" width="320" height="240">
			<xsl:attribute name="src"><xsl:value-of select="$href"/></xsl:attribute>
		    <div class="video-fallback">
		        <br />Sie benoetigen einen Browser, der HTML5 unterstuetzt.
		    </div>
		</video>
		<br />
	</xsl:if>
	<xsl:if test="contains($href, '.mp3')">
		<audio controls="">
			<xsl:attribute name="src"><xsl:value-of select="$href"/></xsl:attribute>
		 </audio>
                <br />
        </xsl:if>
        <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:call-template name="getFileIcon">
                    <xsl:with-param name="mimetype">
                        <xsl:value-of select="substring-before($mimetype,'/')"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="contains($label-1, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-1, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before($mimetype,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains($mimetype,';')">
                                        <xsl:value-of select="substring-before(substring-after($mimetype,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <xsl:when test="$size &lt; 1024">
                        <xsl:value-of select="$size"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024">
                        <xsl:value-of select="substring(string($size div 1024),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024 * 1024">
                        <xsl:value-of select="substring(string($size div (1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string($size div (1024 * 1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </a>
        </div>
    </xsl:template>

    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <xsl:call-template name="itemSummaryView-DIM-title"/>
        <div class="ds-table-responsive">
            <table class="ds-includeSet-table detailtable table table-striped table-hover">
                <xsl:apply-templates mode="itemDetailView-DIM"/>
            </table>
        </div>

        <span class="Z3988">
            <xsl:attribute name="title">
                 <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <xsl:template match="dim:field" mode="itemDetailView-DIM">
            <tr>
                <xsl:attribute name="class">
                    <xsl:text>ds-table-row </xsl:text>
                    <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                    <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
                </xsl:attribute>
                <td class="label-cell">
                    <xsl:value-of select="./@mdschema"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@element"/>
                    <xsl:if test="./@qualifier">
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="./@qualifier"/>
                    </xsl:if>
                </td>
            <td class="word-break">
              <xsl:copy-of select="./node()"/>
            </td>
                <td><xsl:value-of select="./@language"/></td>
            </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:choose>
                <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
                <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- Otherwise, iterate over and display all of them -->
                <xsl:otherwise>
                    <xsl:apply-templates select="mets:file">
                     	<!--Do not sort any more bitstream order can be changed-->
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='LICENSE']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:apply-templates select="mets:file">
                        <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <div class="file-wrapper row">
            <div class="col-xs-6 col-sm-3">
                <div class="thumbnail">
                    <a class="image-link">
                        <xsl:attribute name="href">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                                <img alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:otherwise>
                                <img alt="Thumbnail">
                                    <xsl:attribute name="data-src">
                                        <xsl:text>holder.js/100%x</xsl:text>
                                        <xsl:value-of select="$thumbnail.maxheight"/>
                                        <xsl:text>/text:No Thumbnail</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </div>
            </div>

            <div class="col-xs-6 col-sm-7">
                <dl class="file-metadata dl-horizontal">
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                    </dd>
                <!-- File size always comes in bytes and thus needs conversion -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                <!-- Lookup File Type description in local messages.xml based on MIME Type.
         In the original DSpace, this would get resolved to an application via
         the Bitstream Registry, but we are constrained by the capabilities of METS
         and can't really pass that info through. -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains(@MIMETYPE,';')">
                                <xsl:value-of select="substring-before(substring-after(@MIMETYPE,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:with-param>
                        </xsl:call-template>
                    </dd>
                <!-- Display the contents of 'Description' only if bitstream contains a description -->
                <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/>
                        </dd>
                </xsl:if>
                </dl>
            </div>

            <div class="file-link col-xs-6 col-xs-offset-6 col-sm-2 col-sm-offset-0">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

</xsl:template>

    <xsl:template name="view-open">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            </xsl:attribute>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:for-each select="$rights_declaration/*">
                <xsl:value-of select="rights:UserName"/>
                <xsl:choose>
                    <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                       <xsl:text> (group)</xsl:text>
                    </xsl:when>
                    <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                       <xsl:text> (individual)</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}" title="Read access available for {$users}"/>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getFileIcon">
        <xsl:param name="mimetype"/>
		
                <xsl:choose>
                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                        <i aria-hidden="true" class="glyphicon glyphicon-lock"></i>
                    </xsl:when>
                    <xsl:otherwise>
			
			<xsl:variable name="filetype">
	                	<xsl:value-of select="substring-after($mimetype, '/')"/>
        		</xsl:variable>
	        	<xsl:choose>
        	        	<xsl:when test="$filetype = 'pdf'">
	                	    <i class="fa fa-file-pdf-o" aria-hidden="true"></i>
		                </xsl:when>
        		        <xsl:when test="$filetype = 'msword'">
                		    <i class="fa fa-file-word-o" aria-hidden="true"></i>
		                </xsl:when>
        		        <xsl:when test="$filetype = 'plain'">
                		    <i class="fa fa-file-text-o" aria-hidden="true"></i>
	                	</xsl:when>
	        	        <xsl:when test="$filetype = 'vnd.ms-excel'">
        	        	    <i class="fa fa-file-excel-o" aria-hidden="true"></i>
	        	        </xsl:when>
        	        	<xsl:when test="$filetype = 'vnd.ms-powerpoint'">
	                	    <i class="fa fa-file-powerpoint-o" aria-hidden="true"></i>
		                </xsl:when>
        		        <xsl:when test="$filetype = 'zip'">
                		    <i class="fa fa-file-zip-o" aria-hidden="true"></i>
		                </xsl:when>
				<xsl:when test="$filetype = 'mp4'">
                                    <span class="glyphicon glyphicon-film"></span>
                                </xsl:when>
				<xsl:when test="contains($mimetype, 'audio')">
                                    <span class="glyphicon glyphicon-volume-up"></span>
                                </xsl:when>

        		        <xsl:otherwise>
                		        <i class="fa fa-file" aria-hidden="true"></i>
	                	</xsl:otherwise>
	        	    </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
	    <!-- <img src="/themes/Mirage2/images/pdf.png" /> -->
        <xsl:text> </xsl:text>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='CC-LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license_text']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_cc</i18n:text></a></li>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license.txt']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_original_license</i18n:text></a></li>
    </xsl:template>

    <!--
    File Type Mapping template

    This maps format MIME Types to human friendly File Type descriptions.
    Essentially, it looks for a corresponding 'key' in your messages.xml of this
    format: xmlui.dri2xhtml.mimetype.{MIME Type}

    (e.g.) <message key="xmlui.dri2xhtml.mimetype.application/pdf">PDF</message>

    If a key is found, the translated value is displayed as the File Type (e.g. PDF)
    If a key is NOT found, the MIME Type is displayed by default (e.g. application/pdf)
    -->
    <xsl:template name="getFileTypeDesc">
        <xsl:param name="mimetype"/>

        <!--Build full key name for MIME type (format: xmlui.dri2xhtml.mimetype.{MIME type})-->
        <xsl:variable name="mimetype-key">xmlui.dri2xhtml.mimetype.<xsl:value-of select='$mimetype'/></xsl:variable>

        <!--Lookup the MIME Type's key in messages.xml language file.  If not found, just display MIME Type-->
        <i18n:text i18n:key="{$mimetype-key}"><xsl:value-of select="$mimetype"/></i18n:text>
    </xsl:template>


   <xsl:template name="cc-uri">
        <xsl:variable name="ccLicenseName" select="//dim:field[@element='rights']"/>
        <xsl:variable name="ccLicenseUri" select="//dim:field[@element='rights'][@qualifier='uri']"/>
        <xsl:variable name="handleUri">
            <xsl:for-each select="//dim:field[@element='identifier' and @qualifier='uri']">
                <a>
                    <xsl:attribute name="href">
                        <xsl:copy-of select="./node()"/>
                    </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                </a>
                <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="$ccLicenseName and $ccLicenseUri and contains($ccLicenseUri, 'creativecommons')">
            <div about="{$handleUri}" class="row">
            <div class="col-sm-3 col-xs-12">
                <a rel="license"
                   href="{$ccLicenseUri}"
                   alt="{$ccLicenseName}"
                   title="{$ccLicenseName}"
                        >
                    <xsl:call-template name="cc-logo">
                        <xsl:with-param name="ccLicenseName" select="$ccLicenseName"/>
                        <xsl:with-param name="ccLicenseUri" select="$ccLicenseUri"/>
                    </xsl:call-template>
                </a>
            </div> <div class="col-sm-8">
                <span>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.cc-license-text</i18n:text>
                    <!-- <xsl:value-of select="$ccLicenseName"/> -->
                </span>
            </div>
            </div>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
