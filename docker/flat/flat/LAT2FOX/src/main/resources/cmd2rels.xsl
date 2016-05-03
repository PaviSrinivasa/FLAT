<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:cmd="http://www.clarin.eu/cmd/"
	xmlns:lat="http://lat.mpi.nl/"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:param name="dir" select="'./'"/>
        <xsl:param name="ext" select="'cmdi'"/>
	
	<xsl:template name="main">
		<relations>
			<xsl:for-each select="collection(concat($dir,concat('?select=*.',$ext,';recurse=yes;on-error=warning')))">
				<xsl:variable name="rec" select="current()"/>
				<xsl:variable name="src" select="base-uri($rec)"/>
				<xsl:variable name="frm">
					<xsl:choose>
						<xsl:when test="normalize-space($rec/cmd:CMD/cmd:Header/cmd:MdSelfLink)=''">
							<xsl:message>ERR: CMD record[<xsl:value-of select="$src"/>] has no or empty MdSelfLink!</xsl:message>
							<xsl:message>WRN: using base URI instead.</xsl:message>
							<xsl:sequence select="$src"/>
						</xsl:when>
						<xsl:when test="starts-with($rec/cmd:CMD/cmd:Header/cmd:MdSelfLink,'hdl:') or starts-with($rec/cmd:CMD/cmd:Header/cmd:MdSelfLink,'http://hdl.handle.net/')">
							<xsl:sequence select="replace(replace($rec/cmd:CMD/cmd:Header/cmd:MdSelfLink,'http://hdl.handle.net/','hdl:'),'@format=.+','')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="normalize-space($rec/cmd:CMD/cmd:Header/cmd:MdSelfLink)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:for-each select="$rec/cmd:CMD/cmd:Resources/cmd:ResourceProxyList/cmd:ResourceProxy">
					<relation>
						<src>
							<xsl:value-of select="$src"/>
						</src>
						<from>
							<xsl:value-of select="$frm"/>
						</from>
						<to>
							<xsl:choose>
								<xsl:when test="starts-with(cmd:ResourceRef,'hdl:') or starts-with(cmd:ResourceRef,'http://hdl.handle.net/')">
									<xsl:value-of select="replace(replace(cmd:ResourceRef,'http://hdl.handle.net/','hdl:'),'@format=.+','')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="resolve-uri(cmd:ResourceRef,$src)"/>
								</xsl:otherwise>
							</xsl:choose>
						</to>
						<dst>
							<xsl:choose>
								<xsl:when test="normalize-space(cmd:ResourceRef/@lat:localURI)=''">
									<xsl:if test="cmd:ResourceType=('Metadata','Resource')">
										<xsl:message>WRN: no local URI for ResourceRef[<xsl:value-of select="cmd:ResourceRef"/>] in CMD record[<xsl:value-of select="$src"/>], using ResourceRef instead.</xsl:message>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="starts-with(cmd:ResourceRef,'hdl:') or starts-with(cmd:ResourceRef,'http://hdl.handle.net/')">
											<xsl:value-of select="replace(replace(cmd:ResourceRef,'http://hdl.handle.net/','hdl:'),'@format=.+','')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="resolve-uri(cmd:ResourceRef,$src)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="starts-with(cmd:ResourceRef/@lat:localURI,'hdl:')">
									<xsl:value-of select="cmd:ResourceRef/@lat:localURI"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="resolve-uri(cmd:ResourceRef/@lat:localURI,$src)"/>
								</xsl:otherwise>
							</xsl:choose>
						</dst>
						<type>
							<xsl:value-of select="cmd:ResourceType"/>
						</type>
					</relation>
				</xsl:for-each>
			</xsl:for-each>
		</relations>
	</xsl:template>
	
	<xsl:template match="/">
		<xsl:call-template name="main"/>
	</xsl:template>
</xsl:stylesheet>