<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:foxml="info:fedora/fedora-system:def/foxml#" xmlns:cmd="http://www.clarin.eu/cmd/" xmlns:lat="http://lat.mpi.nl/" xmlns:sx="java:nl.mpi.tla.saxon" exclude-result-prefixes="xs sx lat" version="3.0">

	<xsl:param name="debug" select="false()" static="yes"/>

	<xsl:variable name="rec" select="/"/>

	<xsl:param name="rels-uri" select="'./relations.xml'"/>
	<xsl:param name="rels-doc" select="document($rels-uri)"/>
	<xsl:key name="rels-from" match="relation" use="src | from"/>
	<xsl:key name="rels-to" match="relation" use="dst | to"/>
	
	<xsl:key name="rp" match="cmd:ResourceProxy" use="cmd:ResourceRef | cmd:ResourceRef/@lat:localURI"/>

	<xsl:param name="conversion-base" select="()"/>
	<xsl:param name="import-base" select="()"/>
	<xsl:param name="fox-base" select="'./fox'"/>
	<xsl:param name="lax-resource-check" select="false()"/>

	<xsl:param name="repository" select="'http://flat.example.com/'"/>

	<xsl:param name="collections-map">
		<map/>
	</xsl:param>
	
	<xsl:param name="oai-include-eval" select="'true()'"/>
	
	<xsl:param name="policies-dir" select="()" as="xs:string*"/>
	
	<xsl:param name="fits-dir" select="()" as="xs:string?"/>

	<xsl:param name="always-collection-eval" select="'false()'"/>
	
	<xsl:param name="always-compound-eval" select="'false()'"/>
	
	<xsl:param name="owner" select="'admin'"/>
	
	<xsl:variable name="namespaces">
		<ns/>
	</xsl:variable>
	<xsl:variable name="NS" select="$namespaces/descendant-or-self::ns"/>
	
	<xsl:param name="icon-base" select="'/app/flat/icons'"/>
	
	<xsl:param name="license-uri"/>

	<xsl:function name="cmd:hdl">
		<xsl:param name="pid"/>
		<xsl:sequence select="replace(replace($pid, '^http(s?)://hdl.handle.net/', 'hdl:'), '@format=[a-z]+', '')"/>
	</xsl:function>

	<xsl:function name="cmd:lat">
		<xsl:param name="prefix"/>
		<xsl:param name="pid"/>
		<xsl:choose>
			<xsl:when test="starts-with($pid,$prefix)">
				<!-- it's already a lat identifier -->
				<xsl:sequence select="$pid"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="suffix" select="replace(replace(cmd:hdl($pid), '[^a-zA-Z0-9]', '_'), '^hdl_', '')"/>
				<xsl:variable name="length" select="
					min((string-length($suffix),
					(64 - string-length($prefix))))"/>
				<xsl:sequence select="concat($prefix, substring($suffix, string-length($suffix) - $length + 1))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="cmd:pid">
		<xsl:param name="locs"/>
		<xsl:param name="lvl"/>
		<xsl:param name="def"/>
		<xsl:choose>
			<xsl:when test="empty($rels-doc/relations/relation)">
				<xsl:sequence select="cmd:hdl($locs[1])"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="to" select="
					$rels-doc/key('rels-to', for $l in $locs
					return
					cmd:hdl($l))"/>
				<xsl:variable name="from" select="
					$rels-doc/key('rels-from', for $l in $locs
					return
					cmd:hdl($l))"/>
				<xsl:variable name="refs" select="
					distinct-values(($from/src,
					$from/from,
					$to/dst,
					$to/to))[normalize-space(.) != '']"/>
				<xsl:variable name="hdl" select="$refs[starts-with(cmd:hdl(.), 'hdl:')]"/>
				<xsl:choose>
					<xsl:when test="count($hdl) eq 0">
						<xsl:message>
							<xsl:value-of select="$lvl"/>
							<xsl:text>: the handle for resource[</xsl:text>
							<xsl:value-of select="
								string-join(distinct-values(for $l in $locs
								return
								cmd:hdl($l)), ', ')"/>
							<xsl:text>][</xsl:text>
							<xsl:value-of select="string-join($refs, ', ')"/>
							<xsl:text>] can't be determined!</xsl:text>
						</xsl:message>
						<xsl:sequence select="$def"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="count($hdl) gt 1">
							<xsl:message>
								<xsl:text>ERR: there are multiple handles[</xsl:text>
								<xsl:value-of select="string-join($hdl, ', ')"/>
								<xsl:text>] for resource[</xsl:text>
								<xsl:value-of select="
									string-join(distinct-values(for $l in $locs
									return
									cmd:hdl($l)), ', ')"/>
								<xsl:text>][</xsl:text>
								<xsl:value-of select="string-join($refs, ', ')"/>
								<xsl:text>]! Using the first one ...</xsl:text>
							</xsl:message>
						</xsl:if>
						<xsl:sequence select="cmd:hdl(($hdl)[1])"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="cmd:pid">
		<xsl:param name="locs"/>
		<xsl:param name="lvl"/>
		<xsl:sequence select="cmd:pid($locs, $lvl,())"/>
	</xsl:function>

	<xsl:function name="cmd:pid">
		<xsl:param name="locs"/>
		<xsl:sequence select="cmd:pid($locs, 'ERR',())"/>
	</xsl:function>
	
	<xsl:function name="cmd:escFile" as="xs:anyURI">
		<xsl:param name="uri" as="xs:anyURI"/>
		<xsl:choose>
			<xsl:when test="starts-with($uri,'file:') and not(contains($uri,'%'))">
				<xsl:variable name="paths" as="xs:string*">
					<xsl:for-each select="tokenize(replace($uri,'file:',''),'/')">
						<xsl:sequence select="encode-for-uri(.)"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:sequence select="concat('file:',string-join($paths,'/')) cast as xs:anyURI"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$uri"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="cmd:firstFile" as="xs:anyURI?">
		<xsl:param name="paths" as="xs:string*"/>
		<xsl:param name="files" as="xs:string*"/>
		<xsl:param name="base"  as="xs:anyURI"/>
		<xsl:message use-when="$debug">DBG: firstFile(paths[<xsl:value-of select="string-join($paths,',')"/>],files[<xsl:value-of select="string-join($files,',')"/>],base[<xsl:value-of select="$base"/>])</xsl:message>
		<xsl:variable name="res" as="xs:anyURI*">
			<xsl:for-each select="$files[normalize-space(.)!='']">
				<xsl:variable name="file" select="."/>
				<xsl:for-each select="$paths[normalize-space(.)!='']">
					<xsl:variable name="path" select="."/>
					<xsl:message use-when="$debug">DBG: firstFile(...): try[<xsl:value-of select="$path"/>][<xsl:value-of select="$file"/>]</xsl:message>
					<xsl:variable name="fp" select="sx:findFirstFile($path,$file)"/>
					<xsl:if test="exists($fp)">
						<xsl:sequence select="xs:anyURI(concat('file:',$fp))"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<xsl:sequence select="$res[1]"/>
		<xsl:message use-when="$debug">DBG: firstFile(...): result[<xsl:value-of select="$res[1]"/>]</xsl:message>
	</xsl:function>

	<xsl:function name="cmd:collections" as="node()*">
		<!--<xsl:sequence select="for $xp in $collections-map//xpath return if (sx:evaluate($rec,$xp,$collections-map/descendant-or-self::map)) then ($xp/parent::collection/@pid) else ()" as="xs:string*"/>-->
		<xsl:variable name="collections" as="node()*">
			<xsl:for-each select="$collections-map//xpath">
				<xsl:variable name="xp" select="current()"/>
				<xsl:choose>
					<xsl:when test="sx:evaluate($rec, $xp, $collections-map/descendant-or-self::map)">
						<!--<xsl:message use-when="$debug">
							<xsl:text>XPath[</xsl:text>
							<xsl:value-of select="$xp"/>
							<xsl:text>][</xsl:text>
							<xsl:value-of
								select="sx:evaluate($rec, $xp, $collections-map/descendant-or-self::map)"/>
							<xsl:text>] matches!</xsl:text>
						</xsl:message>-->
						<xsl:sequence select="$xp/parent::collection"/>
					</xsl:when>
					<xsl:otherwise>
						<!--<xsl:message use-when="$debug">
							<xsl:text>XPath[</xsl:text>
							<xsl:value-of select="$xp"/>
							<xsl:text>][</xsl:text>
							<xsl:value-of
								select="sx:evaluate($rec, $xp, $collections-map/descendant-or-self::map)"/>
							<xsl:text>] doesn't match!</xsl:text>
						</xsl:message>-->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="(count($collections) gt 1) and ($collections-map/descendant-or-self::map/@mode = 'first')">
				<xsl:sequence select="($collections)[1]"/>
			</xsl:when>
			<xsl:when test="(count($collections) eq 0) and exists($collections-map/descendant-or-self::map/default)">
				<xsl:sequence select="$collections-map/descendant-or-self::map/default"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$collections"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template match="/">
		<xsl:variable name="base" select="base-uri()"/>
		<xsl:variable name="self" select="normalize-space($rec/cmd:CMD/cmd:Header/cmd:MdSelfLink)"/>
		<xsl:variable name="pid">
			<xsl:choose>
				<xsl:when test="normalize-space($rec/cmd:CMD/cmd:Header/cmd:MdSelfLink) = ''">
					<xsl:message>
						<xsl:text>ERR: CMD record[</xsl:text>
						<xsl:value-of select="$base"/>
						<xsl:text>] has no or empty MdSelfLink!</xsl:text>
					</xsl:message>
					<xsl:variable name="hdl" select="cmd:pid($base)"/>
					<xsl:choose>
						<xsl:when test="normalize-space($hdl) != ''">
							<xsl:message>
								<xsl:text>WRN: found handle[</xsl:text>
								<xsl:value-of select="$hdl"/>
								<xsl:text>] for CMD record[</xsl:text>
								<xsl:value-of select="$base"/>
								<xsl:text>]</xsl:text>
							</xsl:message>
							<xsl:sequence select="$hdl"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>WRN: using base URI filename instead.</xsl:message>
							<xsl:sequence select="$base"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="starts-with(cmd:hdl($rec/cmd:CMD/cmd:Header/cmd:MdSelfLink), 'hdl:')">
					<xsl:sequence select="cmd:hdl($rec/cmd:CMD/cmd:Header/cmd:MdSelfLink)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="normalize-space($rec/cmd:CMD/cmd:Header/cmd:MdSelfLink)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="fid">
			<xsl:choose>
				<xsl:when test="normalize-space($rec/cmd:CMD/cmd:Header/cmd:MdSelfLink/@lat:flatURI) != ''">
					<xsl:sequence select="replace(normalize-space($rec/cmd:CMD/cmd:Header/cmd:MdSelfLink/@lat:flatURI),'#.*','')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="cmd:lat('lat:', $pid)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:message use-when="$debug">
			<xsl:text>DBG: CMDI2FOX[</xsl:text>
			<xsl:value-of select="$pid"/>
			<xsl:text>][</xsl:text>
			<xsl:value-of select="$fid"/>
			<xsl:text>][</xsl:text>
			<xsl:value-of select="$base"/>
			<xsl:text>]</xsl:text>
		</xsl:message>
		<!--<xsl:message use-when="$debug">DBG: [<xsl:value-of select="$rels-doc/key('rels-from',$pid)[1]/src"/>]!=[<xsl:value-of select="base-uri()"/>] => [<xsl:value-of select="$rels-doc/key('rels-from',$pid)[1]/src!=base-uri()"/>]</xsl:message>-->
		<xsl:if test="exists(($rels-doc/key('rels-from', $pid)[normalize-space(src)!=''])[1][src!=cmd:hdl($base)])">
			<xsl:message>
				<xsl:text>ERR: record[</xsl:text>
				<xsl:value-of select="$base"/>
				<xsl:text>] has an already used PID URI[</xsl:text>
				<xsl:value-of select="$pid"/>
				<xsl:text>][</xsl:text>
				<xsl:value-of select="($rels-doc/key('rels-from', $pid)[normalize-space(src)!=''])[1]/src"/>
				<xsl:text>]!</xsl:text>
			</xsl:message>
			<xsl:message terminate="yes">
				<xsl:text>WRN: resource FOX[</xsl:text>
				<xsl:value-of select="$fid"/>
				<xsl:text>] will not be created!</xsl:text>
			</xsl:message>
		</xsl:if>
		<xsl:variable name="dc">
			<xsl:apply-templates mode="dc"/>
		</xsl:variable>
		<xsl:variable name="collections" select="cmd:collections()"/>
		<xsl:variable name="parents" as="xs:string*">
			<xsl:message use-when="$debug">DBG: look for relations (rels-to:dst|to) of [<xsl:value-of select="$pid"/>] or [<xsl:value-of select="$base"/>] </xsl:message>
			<xsl:variable name="rels" select="distinct-values($rels-doc/key('rels-to', ($pid,cmd:hdl($base)))[type = 'Metadata']/from)"/>
			<xsl:choose>
				<xsl:when test="exists($rels)">
					<xsl:message use-when="$debug">DBG: relations.xml[<xsl:value-of select="string-join($rels,',')"/>]</xsl:message>
					<xsl:for-each select="$rels">
						<xsl:sequence select="cmd:lat('lat:',cmd:pid(current(),'WRN',current()))"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="exists($rec/cmd:CMD/cmd:Resources/cmd:IsPartOfList/cmd:IsPartOf)">
					<xsl:for-each select="$rec/cmd:CMD/cmd:Resources/cmd:IsPartOfList/cmd:IsPartOf">
						<xsl:choose>
							<xsl:when test="normalize-space(@lat:flatURI)!=''">
								<xsl:message use-when="$debug">DBG: IsPartOf.@lat:flatURI[<xsl:value-of select="@lat:flatURI"/>]</xsl:message>
								<xsl:sequence select="replace(@lat:flatURI,'#.*','')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="starts-with(.,'islandora:')">
										<xsl:message use-when="$debug">DBG: IsPartOf.islandora[<xsl:value-of select="."/>]</xsl:message>
										<xsl:sequence select="replace(.,'#.*','')"/>
									</xsl:when>
									<xsl:when test="starts-with(.,'lat:')">
										<xsl:message use-when="$debug">DBG: IsPartOf.lat[<xsl:value-of select="."/>]</xsl:message>
										<xsl:sequence select="replace(.,'#.*','')"/>
									</xsl:when>
									<xsl:when test="starts-with(.,'hdl:') or matches(.,'http(s)?://hdl.handle.net/')">
										<xsl:message use-when="$debug">DBG: IsPartOf.hdl[<xsl:value-of select="cmd:lat('lat:',cmd:hdl(.))"/>]</xsl:message>
										<xsl:sequence select="cmd:lat('lat:',cmd:hdl(.))"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="lcl" select="cmd:lat('lat:',cmd:pid(resolve-uri(.,$base),'ERR',resolve-uri(.,$base)))"/>
										<xsl:message use-when="$debug">DBG: IsPartOf.lcl[<xsl:value-of select="."/>][<xsl:value-of select="resolve-uri(.,$base)"/>][<xsl:value-of select="$lcl"/>]</xsl:message>
										<xsl:sequence select="$lcl"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="exists($collections)">
							<xsl:for-each select="$collections/@pid">
								<xsl:choose>
									<xsl:when test="starts-with(current(),'lat:')">
										<xsl:sequence select="current()"/>
									</xsl:when>
									<xsl:when test="starts-with(current(),'hdl:') or matches(current(),'http(s)?://hdl.handle.net/')">
										<xsl:sequence select="cmd:lat('lat:',cmd:hdl(current()))"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:sequence select="cmd:lat('lat:',cmd:pid(resolve-uri(current(),$base),'ERR',resolve-uri(current(),$base)))"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="'islandora:compound_collection'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:message use-when="$debug">DBG: parents[<xsl:value-of select="string-join($parents,', ')"/>]</xsl:message>
		<foxml:digitalObject VERSION="1.1" PID="{$fid}" xmlns:xsii="http://www.w3.org/2001/XMLSchema-instance" xsii:schemaLocation="info:fedora/fedora-system:def/foxml# http://www.fedora.info/definitions/1/0/foxml1-1.xsd">
			<xsl:comment>
				<xsl:text>Source: </xsl:text>
				<xsl:value-of select="base-uri()"/>
			</xsl:comment>
			<foxml:objectProperties>
				<!-- [A]ctive state -->
				<foxml:property NAME="info:fedora/fedora-system:def/model#state" VALUE="A"/>
				<!-- the owner -->
				<foxml:property NAME="info:fedora/fedora-system:def/model#ownerId" VALUE="{$owner}"/>
				<!-- take the first title found in the Dublin Core -->
				<foxml:property NAME="info:fedora/fedora-system:def/model#label">
					<xsl:variable name="label" select="($dc//dc:title[normalize-space() != ''])[1]" xmlns:dc="http://purl.org/dc/elements/1.1/"/>
					<xsl:choose>
						<xsl:when test="exists($label)">
							<xsl:attribute name="VALUE" select="substring(normalize-unicode($label), 1, 255)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="VALUE" select="$pid"/>
						</xsl:otherwise>
					</xsl:choose>
				</foxml:property>
			</foxml:objectProperties>
			<!-- Metadata: Dublin Core -->
			<foxml:datastream xmlns:foxml="info:fedora/fedora-system:def/foxml#" ID="DC" STATE="A" CONTROL_GROUP="X" VERSIONABLE="true">
				<foxml:datastreamVersion ID="DC.0" FORMAT_URI="http://www.openarchives.org/OAI/2.0/oai_dc/" MIMETYPE="text/xml" LABEL="Dublin Core Record for this object">
					<foxml:xmlContent>
						<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/">
							<dc:identifier>
								<xsl:value-of select="replace($pid, '^hdl:', 'https://hdl.handle.net/')"/>
							</dc:identifier>
							<xsl:copy-of copy-namespaces="no" select="$dc/oai_dc:dc/* except dc:identifier[@type='hdl']"/>
						</oai_dc:dc>						
					</foxml:xmlContent>
				</foxml:datastreamVersion>
			</foxml:datastream>
			<!-- Metadata: CMD -->
			<foxml:datastream xmlns:foxml="info:fedora/fedora-system:def/foxml#" ID="CMD" STATE="A" CONTROL_GROUP="X" VERSIONABLE="true">
				<foxml:datastreamVersion ID="CMD.0" FORMAT_URI="{/cmd:CMD/@xsii:schemaLocation}" MIMETYPE="application/x-cmdi+xml">
					<xsl:variable name="label" select="($dc//dc:title[normalize-space() != ''])[1]" xmlns:dc="http://purl.org/dc/elements/1.1/"/>
					<xsl:choose>
						<xsl:when test="exists($label)">
							<xsl:attribute name="LABEL" select="substring(replace(replace(normalize-unicode($label,'NFKD'),'\P{IsBasicLatin}','_'),'\s+','_'),1,255)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="LABEL" select="'CMD Record for this object'"/>
						</xsl:otherwise>
					</xsl:choose>
					<foxml:xmlContent>
						<xsl:apply-templates mode="cmd">
							<xsl:with-param name="pid" select="$pid" tunnel="yes"/>
							<xsl:with-param name="fid" select="$fid" tunnel="yes"/>
							<xsl:with-param name="base" select="$base" tunnel="yes"/>
						</xsl:apply-templates>
					</foxml:xmlContent>
				</foxml:datastreamVersion>
			</foxml:datastream>
			<!-- Metadata: other -->
			<xsl:apply-templates mode="other">
				<xsl:with-param name="pid" select="$pid" tunnel="yes"/>
				<xsl:with-param name="fid" select="$fid" tunnel="yes"/>
				<xsl:with-param name="base" select="$base" tunnel="yes"/>
			</xsl:apply-templates>
			<!-- Relations: RELS-EXT -->
			<foxml:datastream xmlns:foxml="info:fedora/fedora-system:def/foxml#" ID="RELS-EXT" STATE="A" CONTROL_GROUP="X" VERSIONABLE="true">
				<foxml:datastreamVersion ID="RELS-EXT.0" LABEL="RDF Statements about this object" MIMETYPE="text/xml">
					<foxml:xmlContent>
						<rdf:RDF xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:fedora="info:fedora/fedora-system:def/relations-external#" xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:islandora="http://islandora.ca/ontology/relsext#">
							<rdf:Description rdf:about="info:fedora/{$fid}">
								<!-- relationships to (parent) collections -->
								<xsl:for-each select="$parents">
									<fedora:isMemberOfCollection rdf:resource="info:fedora/{current()}"/>
								</xsl:for-each>
								<!-- if the CMD has references to resources it's a compound, or we always want compounds -->
								<xsl:if test="sx:evaluate($rec, $always-compound-eval, $NS) or exists(/cmd:CMD/cmd:Resources/cmd:ResourceProxyList/cmd:ResourceProxy[cmd:ResourceType = 'Resource'])">
									<fedora-model:hasModel rdf:resource="info:fedora/islandora:compoundCModel"/>
								</xsl:if>
								<!-- if the CMD has references to other metadata files it's a collection, or we always want collections -->
								<xsl:if test="sx:evaluate($rec, $always-collection-eval, $NS) or exists(/cmd:CMD/cmd:Resources/cmd:ResourceProxyList/cmd:ResourceProxy[cmd:ResourceType = 'Metadata']) or exists($rels-doc/key('rels-from', ($pid,cmd:hdl($base)))[type = 'Metadata'])">
									<fedora-model:hasModel rdf:resource="info:fedora/islandora:collectionCModel"/>
								</xsl:if>
								<!-- the CMD is part of the compound FOXML so it uses the cmdi content model -->
								<fedora-model:hasModel rdf:resource="info:fedora/islandora:sp_cmdiCModel"/>
								<!-- add POLICY RELS-EXT statements -->
								<xsl:variable name="rels">
									<xsl:for-each select="zero-or-one(cmd:firstFile($policies-dir, (concat(replace($fid, '[^a-zA-Z0-9]', '_'), '.RELS-EXT.xml'), replace(($collections/policy[@type='cmd'])[1],'.xml','.RELS-EXT.xml'),'default-cmd-policy.RELS-EXT.xml','default-policy.RELS-EXT.xml'), $base))">
										<xsl:variable name="policy-rels" select="."/>
										<xsl:message use-when="$debug">
											<xsl:text>DBG: CMD FOX[</xsl:text>
											<xsl:value-of select="$fid"/>
											<xsl:text>] will additionaly use access policy RELS-EXT statements[</xsl:text>
											<xsl:value-of select="$policy-rels"/>
											<xsl:text>]!</xsl:text>
										</xsl:message>
										<xsl:copy-of select="doc($policy-rels)/rdf:RDF/rdf:Description/*"/>
									</xsl:for-each>
								</xsl:variable>
								<xsl:copy-of copy-namespaces="no" select="$rels"/>
								<!-- OAI -->
								<xsl:if test="($rels/islandora:isViewableByRole='anonymous user' or empty(($rels/islandora:isViewableByUser,$rels/islandora:isViewableByRole))) and sx:evaluate($rec, $oai-include-eval, $NS)">
									<oai:itemID xmlns="http://www.openarchives.org/OAI/2.0/">
										<xsl:value-of select="concat('oai:', replace(replace($repository,'^http(s)?://',''),'/','.'), ':', $fid)"/>
									</oai:itemID>
								</xsl:if>
							</rdf:Description>
						</rdf:RDF>
					</foxml:xmlContent>
				</foxml:datastreamVersion>
			</foxml:datastream>
			<!-- ADD TN data stream -->
			<foxml:datastream xmlns:foxml="info:fedora/fedora-system:def/foxml#" ID="TN" STATE="A" CONTROL_GROUP="E">
				<foxml:datastreamVersion ID="TN.0" LABEL="icon.png" MIMETYPE="image/png">
					<foxml:contentLocation TYPE="URL" REF="file:{$icon-base}/folder.png"/>
				</foxml:datastreamVersion>
			</foxml:datastream>		
			<!-- add POLICY data stream -->
			<xsl:for-each select="zero-or-one(cmd:firstFile($policies-dir, (concat(replace($fid, '[^a-zA-Z0-9]', '_'), '.xml'),($collections/policy[@type='cmd'])[1],'default-cmd-policy.xml','default-policy.xml'), $base))">
				<xsl:variable name="policy" select="."/>
				<xsl:message use-when="$debug">
					<xsl:text>DBG: CMD FOX[</xsl:text>
					<xsl:value-of select="$fid"/>
					<xsl:text>] will use access policy[</xsl:text>
					<xsl:value-of select="$policy"/>
					<xsl:text>]!</xsl:text>
				</xsl:message>
				<foxml:datastream xmlns:foxml="info:fedora/fedora-system:def/foxml#" ID="POLICY" STATE="A" CONTROL_GROUP="X" VERSIONABLE="true">
					<foxml:datastreamVersion ID="POLICY.0" LABEL="Access policy for this object" MIMETYPE="text/xml">
						<foxml:xmlContent>
							<xsl:copy-of select="doc($policy)"/>
						</foxml:xmlContent>
					</foxml:datastreamVersion>
				</foxml:datastream>
			</xsl:for-each>
			<!-- Resource Proxies -->
			<!--<xsl:message use-when="$debug">DBG: resourceProxies[<xsl:value-of select="count(/cmd:CMD/cmd:Resources/cmd:ResourceProxyList/cmd:ResourceProxy[cmd:ResourceType='Resource'])"/>]</xsl:message>
			<xsl:for-each select="/cmd:CMD/cmd:Resources/cmd:ResourceProxyList/cmd:ResourceProxy[cmd:ResourceType='Resource']">
				<xsl:message use-when="$debug">DBG: resourceProxy[<xsl:value-of select="position()"/>][<xsl:value-of select="cmd:ResourceRef"/>][<xsl:value-of select="cmd:ResourceRef/@lat:localURI"/>]</xsl:message>
			</xsl:for-each>-->
			<xsl:for-each-group select="/cmd:CMD/cmd:Resources/cmd:ResourceProxyList/cmd:ResourceProxy[cmd:ResourceType = 'Resource']" group-by="cmd:ResourceRef/normalize-space(@lat:localURI)">
				<xsl:for-each select="
						if (current-grouping-key() = '') then
							(current-group())
						else
							(current-group()[1])">
					<xsl:variable name="res" select="current()"/>
					<xsl:variable name="resPID">
						<xsl:choose>
							<xsl:when test="starts-with(cmd:hdl($res/cmd:ResourceRef), 'hdl:')">
								<xsl:sequence select="cmd:hdl($res/cmd:ResourceRef)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="resolve-uri($res/cmd:ResourceRef, $base)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="resURI">
						<xsl:choose>
							<xsl:when test="normalize-space($res/cmd:ResourceRef/@lat:localURI) != ''">
								<xsl:sequence select="cmd:escFile(resolve-uri($res/cmd:ResourceRef/@lat:localURI, $base))"/>
							</xsl:when>
							<xsl:when test="normalize-space($resPID) != ''">
								<xsl:sequence select="cmd:escFile(resolve-uri($resPID, $base))"/>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="resID">
						<xsl:choose>
							<xsl:when test="normalize-space($res/cmd:ResourceRef/@lat:flatURI) != ''">
								<xsl:sequence select="replace(normalize-space($res/cmd:ResourceRef/@lat:flatURI),'#.*','')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="cmd:lat('lat:', $resPID)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!--<xsl:variable name="resFOX" select="concat($fox-base,'/',replace($resURI,'[^a-zA-Z0-9]','_'),'.xml')"/>-->
					<xsl:variable name="resFOX" select="concat($fox-base, '/', replace($resID, '[^a-zA-Z0-9]', '_'), '.xml')"/>
					<!--<xsl:message use-when="$debug">DBG: resourceProxy[<xsl:value-of select="$resURI"/>][<xsl:value-of select="$resFOX"/>][<xsl:value-of select="$resPID"/>][<xsl:value-of select="$resID"/>]</xsl:message>-->
					<!-- take the filepart of the localURI as the resource title -->
					<xsl:variable name="resTitle">
						<xsl:choose>
							<xsl:when test="normalize-space(@lat:label)!=''">
								<xsl:sequence select="normalize-space(@lat:label)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="replace($resURI, '.*/', '')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!--<xsl:message use-when="$debug">DBG: creating FOX[<xsl:value-of select="$resFOX"/>]?[<xsl:value-of select="not(doc-available($resFOX))"/>]</xsl:message>-->
					<xsl:variable name="resMIME">
						<xsl:apply-templates select="current()" mode="mime">
							<xsl:with-param name="resURI" select="$resURI"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:variable name="createFOX" as="xs:boolean">
						<xsl:choose>
							<xsl:when test="exists(($rels-doc/key('rels-to', $resPID)[normalize-space(resolve-uri(dst, src))!=''])[1][resolve-uri(dst, src)!= cmd:hdl($resURI)])">
								<xsl:message>
									<xsl:text>ERR: resource[</xsl:text>
									<xsl:value-of select="$resURI"/>
									<xsl:text>] has an already used PID URI[</xsl:text>
									<xsl:value-of select="$resPID"/>
									<xsl:text>][</xsl:text>
									<xsl:value-of select="($rels-doc/key('rels-to', $resPID)[normalize-space(resolve-uri(dst, src))!=''])[1]/resolve-uri(dst, src)"/>
									<xsl:text>]!</xsl:text>
								</xsl:message>
								<xsl:message>
									<xsl:text>WRN: resource FOX[</xsl:text>
									<xsl:value-of select="$resFOX"/>
									<xsl:text>] will not be created!</xsl:text>
								</xsl:message>
								<xsl:sequence select="false()"/>
							</xsl:when>
							<xsl:when test="exists($rels-doc/key('rels-from', $resPID)[Type = 'Resource'])">
								<xsl:message>
									<xsl:text>ERR: resource[</xsl:text>
									<xsl:value-of select="$resURI"/>
									<xsl:text>] has a PID[</xsl:text>
									<xsl:value-of select="$resPID"/>
									<xsl:text>] already used by one or more CMDI records[</xsl:text>
									<xsl:value-of select="string-join($rels-doc/key('rels-from', $resPID)[Type = 'Resource']/src, ', ')"/>
									<xsl:text>]!</xsl:text>
								</xsl:message>
								<xsl:message>
									<xsl:text>WRN: resource FOX[</xsl:text>
									<xsl:value-of select="$resFOX"/>
									<xsl:text>] will not be created!</xsl:text>
								</xsl:message>
								<xsl:sequence select="false()"/>
							</xsl:when>
							<xsl:when test="not(sx:checkURL(replace($resPID, '^hdl:', 'https://hdl.handle.net/')))">
								<xsl:message>
									<xsl:text>ERR: resource[</xsl:text>
									<xsl:value-of select="$resURI"/>
									<xsl:text>] has an invalid PID URI[</xsl:text>
									<xsl:value-of select="$resPID"/>
									<xsl:text>]!</xsl:text>
								</xsl:message>
								<xsl:message>
									<xsl:text>WRN: resource FOX[</xsl:text>
									<xsl:value-of select="$resFOX"/>
									<xsl:text>] will not be created!</xsl:text>
								</xsl:message>
								<xsl:sequence select="false()"/>
							</xsl:when>
							<xsl:when test="normalize-space($resURI) = ''">
								<xsl:message>
									<xsl:text>ERR: resource URI is empty, i.e., unknown!</xsl:text>
								</xsl:message>
								<xsl:message>
									<xsl:text>WRN: resource FOX[</xsl:text>
									<xsl:value-of select="$resFOX"/>
									<xsl:text>] will not be created!</xsl:text>
								</xsl:message>
								<xsl:sequence select="false()"/>
							</xsl:when>
							<xsl:when test="starts-with($resURI, 'file:') and exists($import-base) and sx:fileExists(replace($resURI, $conversion-base, $import-base) cast as xs:anyURI)">
								<xsl:sequence select="true()"/>
							</xsl:when>
							<xsl:when test="starts-with($resURI, 'file:') and not(sx:fileExists($resURI cast as xs:anyURI))">
								<xsl:variable name="uri">
									<xsl:choose>
										<xsl:when test="exists($import-base)">
											<xsl:sequence select="replace($resURI, $conversion-base, $import-base)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:sequence select="$resURI"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="$lax-resource-check">
										<xsl:message>
											<xsl:text>WRN: resource[</xsl:text>
											<xsl:value-of select="$uri"/>
											<xsl:text>] linked from [</xsl:text>
											<xsl:value-of select="base-uri()"/>
											<xsl:text>] doesn't exist!</xsl:text>
										</xsl:message>
										<xsl:message>
											<xsl:text>WRN: resource FOX[</xsl:text>
											<xsl:value-of select="$resFOX"/>
											<xsl:text>] will be created anyway</xsl:text>
										</xsl:message>
										<xsl:sequence select="true()"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:message>
											<xsl:text>ERR: resource[</xsl:text>
											<xsl:value-of select="$uri"/>
											<xsl:text>] linked from [</xsl:text>
											<xsl:value-of select="base-uri()"/>
											<xsl:text>] doesn't exist!</xsl:text>
										</xsl:message>
										<xsl:message>
											<xsl:text>WRN: resource FOX[</xsl:text>
											<xsl:value-of select="$resFOX"/>
											<xsl:text>] will not be created!</xsl:text>
										</xsl:message>
										<xsl:sequence select="false()"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="true()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:if test="$createFOX and not(doc-available($resFOX))">
						<xsl:message use-when="$debug">
							<xsl:text>DBG: creating resource FOX[</xsl:text>
							<xsl:value-of select="$resFOX"/>
							<xsl:text>]</xsl:text>
						</xsl:message>
						<xsl:result-document href="{$resFOX}">
							<foxml:digitalObject VERSION="1.1" PID="{$resID}" xmlns:xsii="http://www.w3.org/2001/XMLSchema-instance" xsii:schemaLocation="info:fedora/fedora-system:def/foxml# http://www.fedora.info/definitions/1/0/foxml1-1.xsd">
								<xsl:comment>
									<xsl:text>Source: </xsl:text>
									<xsl:value-of select="$resURI"/>
								</xsl:comment>
								<foxml:objectProperties>
									<!-- [A]ctive state -->
									<foxml:property NAME="info:fedora/fedora-system:def/model#state" VALUE="A"/>
									<foxml:property NAME="info:fedora/fedora-system:def/model#label" VALUE="{substring($resTitle,1,255)}"/>
								</foxml:objectProperties>
								<!-- Metadata: Dublin Core -->
								<foxml:datastream xmlns:foxml="info:fedora/fedora-system:def/foxml#" ID="DC" STATE="A" CONTROL_GROUP="X" VERSIONABLE="true">
									<foxml:datastreamVersion ID="DC.0" FORMAT_URI="http://www.openarchives.org/OAI/2.0/oai_dc/" MIMETYPE="text/xml" LABEL="Dublin Core Record for this object">
										<foxml:xmlContent>
											<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
												<dc:title>
													<xsl:value-of select="$resTitle"/>
												</dc:title>
												<dc:identifier>
													<xsl:value-of select="replace($resPID, '^hdl:', 'https://hdl.handle.net/')"/>
												</dc:identifier>
												<xsl:apply-templates select="current()" mode="checksum">
													<xsl:with-param name="resURI" select="$resURI" tunnel="yes"/>
												</xsl:apply-templates>
											</oai_dc:dc>
										</foxml:xmlContent>
									</foxml:datastreamVersion>
								</foxml:datastream>
								<!-- Relations: RELS-EXT -->
								<foxml:datastream xmlns:foxml="info:fedora/fedora-system:def/foxml#" ID="RELS-EXT" STATE="A" CONTROL_GROUP="X" VERSIONABLE="true">
									<foxml:datastreamVersion ID="RELS-EXT.0" LABEL="RDF Statements about this object" MIMETYPE="text/xml">
										<foxml:xmlContent>
											<rdf:RDF xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:fedora="info:fedora/fedora-system:def/relations-external#" xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:islandora="http://islandora.ca/ontology/relsext#">
												<rdf:Description rdf:about="info:fedora/{$resID}">
													<!-- relationships to (parent) compounds -->
													<xsl:variable name="compounds" select="distinct-values($rels-doc/key('rels-to', ($resPID,cmd:hdl($resURI)))[type = 'Resource']/from)"/>
													<xsl:choose>
														<xsl:when test="exists($compounds)">
															<xsl:for-each select="$compounds">
																<fedora:isConstituentOf rdf:resource="info:fedora/{cmd:lat('lat:',current())}"/>
															</xsl:for-each>
														</xsl:when>
														<xsl:otherwise>
															<!-- the resource should be at least a member of the compound we're creating -->
															<fedora:isConstituentOf rdf:resource="info:fedora/{$fid}"/>
														</xsl:otherwise>
													</xsl:choose>
													<!-- resource has to become a member of the collection the compound is a member of -->
													<xsl:for-each select="$parents">
														<fedora:isMemberOfCollection rdf:resource="info:fedora/{current()}"/>
													</xsl:for-each>
													<!-- content model -->
													<xsl:apply-templates select="current()" mode="cmodel">
														<xsl:with-param name="resURI" select="$resURI"/>
														<xsl:with-param name="resMIME" select="$resMIME"/>
													</xsl:apply-templates>
													<!-- add POLICY RELS-EXT statements -->
													<xsl:for-each select="zero-or-one(cmd:firstFile($policies-dir, (concat(replace($resID, '[^a-zA-Z0-9]', '_'), '.RELS-EXT.xml'), replace(($collections/policy[@type='resource'])[1],'.xml','.RELS-EXT.xml'), 'default-resource-policy.RELS-EXT.xml','default-policy.RELS-EXT.xml'), $base))">
														<xsl:variable name="policy-rels" select="."/>
														<xsl:message use-when="$debug">
															<xsl:text>DBG: FOX[</xsl:text>
															<xsl:value-of select="$fid"/>
															<xsl:text>] will additionaly use access policy RELS-EXT statements[</xsl:text>
															<xsl:value-of select="$policy-rels"/>
															<xsl:text>]!</xsl:text>
														</xsl:message>
														<xsl:copy-of select="doc($policy-rels)/rdf:RDF/rdf:Description/*"/>
													</xsl:for-each>
												</rdf:Description>
											</rdf:RDF>
										</foxml:xmlContent>
									</foxml:datastreamVersion>
								</foxml:datastream>
								<foxml:datastream xmlns:foxml="info:fedora/fedora-system:def/foxml#" ID="OBJ" STATE="A" VERSIONABLE="true">
									<!--- CHECK: CONTROL_GROUP indicates the kind of datastream, either
                                                            Externally Referenced Content (E), 
                                                            Redirected Content (R), 
                                                            Managed Content (M) or 
                                                            Inline XML (X) -->
									<xsl:choose>
										<xsl:when test="starts-with($resURI, 'file:')">
											<xsl:attribute name="CONTROL_GROUP" select="'E'"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="CONTROL_GROUP" select="'R'"/>
										</xsl:otherwise>
									</xsl:choose>
									<foxml:datastreamVersion ID="OBJ.0" LABEL="{substring($resTitle,1,255)}" MIMETYPE="{$resMIME}">
										<foxml:contentLocation TYPE="URL">
											<xsl:choose>
												<xsl:when test="starts-with($resURI, 'file:') and exists($import-base)">
													<xsl:attribute name="REF" select="replace($resURI, $conversion-base, $import-base)"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="REF" select="replace($resURI, '^hdl:', 'https://hdl.handle.net/')"/>
												</xsl:otherwise>
											</xsl:choose>
										</foxml:contentLocation>
									</foxml:datastreamVersion>
								</foxml:datastream>
								<!-- license -->
								<xsl:if test="normalize-space($license-uri)!=''">
									<foxml:datastream ID="LICENSE" STATE="A" CONTROL_GROUP="R" VERSIONABLE="false">
										<foxml:datastreamVersion ID="LICENSE.0" LABEL="license" MIMETYPE="text/html">
											<foxml:contentLocation TYPE="URL" REF="{$license-uri}"/>
										</foxml:datastreamVersion>
									</foxml:datastream>
								</xsl:if>
								<!-- add specific thumbnail icons for specific MIME types -->
								<foxml:datastream ID="TN" STATE="A" CONTROL_GROUP="E" VERSIONABLE="false">
									<foxml:datastreamVersion ID="TN.0" LABEL="icon.png" MIMETYPE="image/png">
										<xsl:apply-templates select="current()" mode="thumbnail">
											<xsl:with-param name="resURI" select="$resURI" tunnel="yes"/>
											<xsl:with-param name="resMIME" select="$resMIME" tunnel="yes"/>
										</xsl:apply-templates>
									</foxml:datastreamVersion>
								</foxml:datastream>
								<!-- add POLICY data stream -->
								<xsl:choose>
									<xsl:when test="empty($policies-dir)"/>
									<xsl:when test="exists(cmd:firstFile($policies-dir, (concat(replace($resID, '[^a-zA-Z0-9]', '_'), '.xml'), ($collections/policy[@type='resource'])[1], 'default-resource-policy.xml', 'default-policy.xml'), $base))">
										<xsl:variable name="policy" select="cmd:firstFile($policies-dir, (concat(replace($resID, '[^a-zA-Z0-9]', '_'), '.xml'), ($collections/policy[@type='resource'])[1], 'default-resource-policy.xml', 'default-policy.xml'), $base)" as="xs:anyURI"/>
										<xsl:message use-when="$debug">
											<xsl:text>DBG: resource FOX[</xsl:text>
											<xsl:value-of select="$resFOX"/>
											<xsl:text>] will use access policy[</xsl:text>
											<xsl:value-of select="$policy"/>
											<xsl:text>]!</xsl:text>
										</xsl:message>
										<foxml:datastream xmlns:foxml="info:fedora/fedora-system:def/foxml#" ID="POLICY" STATE="A" CONTROL_GROUP="X" VERSIONABLE="true">
											<foxml:datastreamVersion ID="POLICY.0" LABEL="Access policy for this object" MIMETYPE="text/xml">
												<foxml:xmlContent>
													<xsl:copy-of select="doc($policy)"/>
												</foxml:xmlContent>
											</foxml:datastreamVersion>
										</foxml:datastream>
									</xsl:when>
									<xsl:otherwise>
										<xsl:message>
											<xsl:text>WRN: resource FOX[</xsl:text>
											<xsl:value-of select="$resFOX"/>
											<xsl:text>] will be created without access policy!</xsl:text>
										</xsl:message>
									</xsl:otherwise>
								</xsl:choose>
							</foxml:digitalObject>
						</xsl:result-document>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each-group>
		</foxml:digitalObject>
	</xsl:template>
	
	<!-- MIME types -->
	<xsl:function name="cmd:getMIME" as="xs:string">
		<xsl:param name="mime"/>
		<xsl:param name="uri"/>
		<xsl:variable name="ext" select="tokenize($uri, '\.')[last()]"/>
		<xsl:choose>
			<xsl:when test="normalize-space($mime)!=''">
				<xsl:sequence select="$mime"/>
			</xsl:when>
			<xsl:when test="normalize-space($ext)!=''">
				<xsl:choose>
					<xsl:when test="$ext=('wav')">
						<xsl:sequence select="'audio/wav'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>WRN: can't determine the MIME type for extension[<xsl:value-of select="$ext"/>] of resource URI[<xsl:value-of select="$uri"/>], falling back to application/octet-stream!</xsl:message>
						<xsl:sequence select="'application/octet-stream'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>WRN: can't determine the MIME type for resource URI[<xsl:value-of select="$uri"/>], falling back to application/octet-stream!</xsl:message>
				<xsl:sequence select="'application/octet-stream'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- CMDI -->

	<!-- identity copy -->
	<xsl:template match="@* | node()" mode="cmd">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="cmd:CMD" mode="cmd">
		<cmd:CMD xmlns:cmd="http://www.clarin.eu/cmd/">
			<xsl:apply-templates select="@* | node()" mode="#current"/>
		</cmd:CMD>
	</xsl:template>

	<xsl:template match="cmd:Header" mode="cmd">
		<xsl:param name="pid" tunnel="yes"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="#current"/>
			<xsl:apply-templates select="cmd:MdCreator | cmd:MdCreationDate" mode="#current"/>
			<cmd:MdSelfLink>
				<xsl:copy-of select="cmd:MdSelfLink/(@* except (@lat:localURI,@lat:flatURI))"/>
				<xsl:choose>
					<xsl:when test="normalize-space(cmd:MdSelfLink/@lat:flatURI)!=''">
						<xsl:apply-templates select="cmd:MdSelfLink/@lat:flatURI" mode="#current"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="lat:flatURI" select="cmd:lat('lat:', $pid)"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="replace($pid,'hdl:','https://hdl.handle.net/')"/>
			</cmd:MdSelfLink>
			<xsl:apply-templates select="node() except (cmd:MdCreator | cmd:MdCreationDate | cmd:MdSelfLink)" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- skip the back links -->
	<xsl:template match="cmd:IsPartOfList" mode="cmd"/>
	
	<xsl:template match="cmd:ResourceProxyList" mode="cmd">
		<xsl:param name="fid" tunnel="yes"/>
		<xsl:param name="pid" tunnel="yes"/>
		<xsl:param name="base" tunnel="yes"/>
		<xsl:message use-when="$debug">DBG: cmd:ResourceProxyList</xsl:message>
		<xsl:copy>
			<!-- process non-Metadata or LandingPage resource proxies. Skip SearchPage because we don't have content search in FLAT (yet) -->
			<xsl:message use-when="$debug">DBG: - non metadata or landing page</xsl:message>
			<xsl:apply-templates select="cmd:ResourceProxy[not(cmd:ResourceType = ('LandingPage','Metadata','SearchPage'))]" mode="#current"/>
			<xsl:message use-when="$debug">DBG: - create landing page</xsl:message>
			<cmd:ResourceProxy id="home-{replace($fid,'lat:','')}">
				<cmd:ResourceType mimetype="text/html">LandingPage</cmd:ResourceType>
				<cmd:ResourceRef>
					<xsl:value-of select="concat($repository,'/islandora/object/',encode-for-uri($fid),'#',if ($fid eq cmd:lat('lat:', $pid)) then () else concat('?pid=',encode-for-uri($pid)))"/>
				</cmd:ResourceRef>
			</cmd:ResourceProxy>
			<!-- process Metadata resource proxies -->
			<xsl:variable name="metadata" select="cmd:ResourceProxy[cmd:ResourceType = 'Metadata']"/>
			<xsl:variable name="md">
				<xsl:for-each select="$metadata">
					<cmd:ResourceProxy>
						<xsl:copy-of select="@*"/>
						<cmd:ResourceType mimetype="application/x-cmdi+xml">Metadata</cmd:ResourceType>
						<cmd:ResourceRef>
							<xsl:if test="exists(cmd:ResourceRef/@lat:localURI)">
								<xsl:attribute name="lat:localURI" select="cmd:ResourceRef/resolve-uri(@lat:localURI,$base)"/>
							</xsl:if>
							<xsl:value-of select="resolve-uri(cmd:ResourceRef,$base)"/>
						</cmd:ResourceRef>
					</cmd:ResourceProxy>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="children" select="$rels-doc/key('rels-from', ($pid,cmd:hdl($base)))[type = 'Metadata']"/>
			<!-- legitimate children -->
			<xsl:message use-when="$debug">DBG: - legitimate children</xsl:message>
			<xsl:comment>legitimate metadata children</xsl:comment>
			<xsl:for-each select="$children">
				<xsl:variable name="ref" select="resolve-uri(cmd:ResourceRef,$base)"/>
				<xsl:variable name="lcl" select="cmd:ResourceRef/resolve-uri(@lat:localURI,$base)"/>
				<xsl:variable name="rp" select="key('rp',(to,dst),$md)"/>
				<cmd:ResourceProxy>
					<xsl:choose>
						<xsl:when test="exists($rp[normalize-space(@id)!=''])">
							<xsl:attribute name="id" select="$rp/@id"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="id" select="generate-id()"/>
						</xsl:otherwise>
					</xsl:choose>
					<cmd:ResourceType mimetype="application/x-cmdi+xml">Metadata</cmd:ResourceType>
					<xsl:variable name="ref">
						<cmd:ResourceRef lat:localURI="{dst}">
							<xsl:value-of select="replace(to,'hdl:','https://hdl.handle.net/')"/>
						</cmd:ResourceRef>
					</xsl:variable>
					<xsl:apply-templates select="$ref" mode="#current"/>
				</cmd:ResourceProxy>
			</xsl:for-each>
			<!-- illegitimate children (could be dead links) -->
			<xsl:message use-when="$debug">DBG: - illegitimate children</xsl:message>
			<xsl:comment>illegitimate metadata children (could be dead links)</xsl:comment>
			<xsl:for-each select="$md">
				<xsl:if test="empty((cmd:ResourceRef,cmd:ResourceRef/@lat:localURI)=($children/to,$children/dst))">
					<xsl:apply-templates select="." mode="#current"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="cmd:ResourceRef" mode="cmd">
		<xsl:param name="base" tunnel="yes"/>
		<xsl:variable name="pid">
			<xsl:choose>
				<xsl:when test="normalize-space(.) = ''">
					<xsl:sequence select="()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="resolve-uri(., $base)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="lcl">
			<xsl:choose>
				<xsl:when test="normalize-space(@lat:localURI) = ''">
					<xsl:sequence select="()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="resolve-uri(@lat:localURI, $base)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="lvl">
			<xsl:choose>
				<xsl:when test="
						../cmd:ResourceType = ('Metadata',
						'Resource')">
					<xsl:sequence select="'ERR'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="'WRN'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="hdl" select="cmd:pid(($pid, $lcl), $lvl)"/>
		<xsl:choose>
			<xsl:when test="starts-with($pid, 'file:') or starts-with($lcl, 'file:')">
				<xsl:choose>
					<xsl:when test="empty($hdl)">
						<xsl:copy>
							<xsl:apply-templates select="@* | node()" mode="#current"/>
						</xsl:copy>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy>
							<xsl:apply-templates select="@* except (@lat:localURI,@lat:flatURI)" mode="#current"/>
							<xsl:choose>
								<xsl:when test="normalize-space(@lat:flatURI)!=''">
									<xsl:apply-templates select="@lat:flatURI" mode="#current"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="lat:flatURI" xmlns:lat="http://lat.mpi.nl/">
										<xsl:value-of select="cmd:lat('lat:', $hdl)"/>
									</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:value-of select="replace($hdl,'hdl:','https://hdl.handle.net/')"/>
						</xsl:copy>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*" mode="#current"/>
					<xsl:choose>
						<xsl:when test="empty($hdl)">
							<xsl:apply-templates select="node()" mode="#current"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="replace($hdl,'hdl:','https://hdl.handle.net/')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- strip out @lat:localURI -->
	<xsl:template match="@lat:localURI" priority="1" mode="cmd"/>

	<!-- cleanup @lat:flatURI -->
	<xsl:template match="@lat:flatURI" priority="1" mode="cmd">
		<xsl:attribute name="lat:flatURI" xmlns:lat="http://lat.mpi.nl/">
			<xsl:value-of select="replace(.,'#.*','')"/>
		</xsl:attribute>
	</xsl:template>

	<!-- Dublin Core -->
	<xsl:template match="cmd:CMD" mode="dc">
		<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
			<xsl:comment>[CMD2DC] nothing happening here, please overwrite with your own templates!</xsl:comment>
		</oai_dc:dc>
	</xsl:template>

	<!-- other -->
	<xsl:template match="cmd:CMD" mode="other">
		<xsl:comment>[CMD2Other] nothing happening here, please overwrite with your own templates!</xsl:comment>
	</xsl:template>
	
	<!-- mime -->
	<xsl:template match="cmd:ResourceProxy" mode="mime">
		<xsl:param name="resURI"/>
		<xsl:sequence select="cmd:getMIME(cmd:ResourceType/@mimetype,$resURI)"/>
	</xsl:template>
	
	<!-- cmodel -->
	<xsl:template match="cmd:ResourceProxy" mode="cmodel" xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:islandora="http://islandora.ca/ontology/relsext#">
		<xsl:param name="resURI"/>
		<xsl:param name="resMIME"/>
		<!-- add specific content models for specific MIME types -->
		<xsl:choose>
			<xsl:when test="starts-with($resMIME,'audio/')">
				<fedora-model:hasModel rdf:resource="info:fedora/islandora:sp-audioCModel"/>
			</xsl:when>
			<xsl:when test="starts-with($resMIME,'video/')">
				<fedora-model:hasModel rdf:resource="info:fedora/islandora:sp_videoCModel"/>
			</xsl:when>
			<xsl:when test="starts-with($resMIME,'image/')">
				<fedora-model:hasModel rdf:resource="info:fedora/islandora:sp_basic_image"/>
			</xsl:when>
			<xsl:when test="starts-with($resMIME,'application/pdf')">
				<fedora-model:hasModel rdf:resource="info:fedora/islandora:sp_pdf"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- thumbnail -->
	<xsl:template match="cmd:ResourceProxy" mode="thumbnail">
		<xsl:param name="resURI" tunnel="yes"/>
		<xsl:param name="resMIME" tunnel="yes"/>
		<xsl:choose>
			<xsl:when test="starts-with($resMIME,'audio/')">
				<foxml:contentLocation TYPE="URL" REF="file:{$icon-base}/audio.png"/>
			</xsl:when>
			<xsl:when test="starts-with($resMIME,'image/')">
				<foxml:contentLocation TYPE="URL" REF="file:{$icon-base}/image.png"/>
			</xsl:when>
			<xsl:when test="starts-with($resMIME,'text/')">
				<foxml:contentLocation TYPE="URL" REF="file:{$icon-base}/text.png"/>
			</xsl:when>
			<xsl:when test="starts-with($resMIME,'video/')">
				<foxml:contentLocation TYPE="URL" REF="file:{$icon-base}/video.png"/>
			</xsl:when>
			<xsl:when test="starts-with($resMIME,'application/pdf')">
				<foxml:contentLocation TYPE="URL" REF="file:{$icon-base}/pdf.png"/>
			</xsl:when>
			<xsl:when test="starts-with($resMIME,'application/zip')">
				<foxml:contentLocation TYPE="URL" REF="file:{$icon-base}/zip.png"/>
			</xsl:when>
			<xsl:when test="starts-with($resMIME,'application/x-gzip')">
				<foxml:contentLocation TYPE="URL" REF="file:{$icon-base}/zip.png"/>
			</xsl:when>
			<xsl:otherwise>
				<foxml:contentLocation TYPE="URL" REF="file:{$icon-base}/other.png"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- checksum -->
	<xsl:template match="cmd:ResourceProxy" mode="checksum">
		<xsl:param name="base" select="base-uri()" tunnel="yes"/>
		<xsl:param name="resURI" tunnel="yes"/>
		<xsl:message>DBG: determine default checksum for resource[<xsl:value-of select="$resURI"/>]</xsl:message>
		<xsl:variable name="res" select="current()"/>
		<xsl:choose xmlns:dc="http://purl.org/dc/elements/1.1/">
			<xsl:when test="exists($fits-dir)" xmlns:fits="http://hul.harvard.edu/ois/xml/ns/fits/fits_output">
				<xsl:variable name="fits" select="cmd:firstFile($fits-dir,concat($res/@id,'.FITS.xml'),$base)" as="xs:anyURI?"/>
				<xsl:choose>
					<xsl:when test="exists($fits)">
						<dc:identifier>
							<xsl:text>md5:</xsl:text>
							<xsl:value-of select="doc($fits)//fits:md5checksum"/>
						</dc:identifier>
						<xsl:message>DBG: FITS checksum[<xsl:value-of select="doc($fits)//fits:md5checksum"/>] for resource[<xsl:value-of select="$resURI"/>]</xsl:message>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>ERR: lookup FITS checksum failed for resource[<xsl:value-of select="$resURI"/>]!</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="starts-with($resURI,'file:')">
				<xsl:choose>
					<xsl:when test="sx:fileExists($resURI cast as xs:anyURI)">
						<xsl:variable name="md5" select="sx:md5($resURI cast as xs:anyURI)"/>
						<dc:identifier>
							<xsl:text>md5:</xsl:text>
							<xsl:value-of select="$md5"/>
						</dc:identifier>
						<xsl:message>DBG: calculated checksum[<xsl:value-of select="$md5"/>] for resource[<xsl:value-of select="$resURI"/>]</xsl:message>
					</xsl:when>
					<xsl:when test="$lax-resource-check">
						<xsl:message>WRN: can't compute a MD5 checksum as the Resource[<xsl:value-of select="$resURI"/>] doesn't exist!</xsl:message>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>ERR: can't compute a MD5 checksum as the Resource[<xsl:value-of select="$resURI"/>] doesn't exist!</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>DBG: skipped checksum for resource[<xsl:value-of select="$resURI"/>]</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
</xsl:stylesheet>
