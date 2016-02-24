<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:foxml="info:fedora/fedora-system:def/foxml#"
    xmlns:cmd="http://www.clarin.eu/cmd/" xmlns:lat="http://lat.mpi.nl/" version="2.0">
    
    <xsl:template match="cmd:CMD" mode="dc">
		<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
			xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
			<xsl:variable name="dc">
				<xsl:apply-templates select="cmd:Components/*/cmd:Name" mode="#current"/>
				<xsl:apply-templates select="cmd:Components/*/cmd:Title" mode="#current"/>
				<xsl:apply-templates
					select="
						cmd:Components/*/cmd:*[not(local-name() = ('Title',
						'Name'))]"
					mode="#current"/>
				<xsl:apply-templates select="cmd:Components/*/cmd:MDGroup/cmd:Location/cmd:*"
					mode="#current"/>
				<xsl:apply-templates select="cmd:Components/*/cmd:Project/cmd:*" mode="#current"/>
				<xsl:apply-templates select="cmd:Components/*/cmd:Project/cmd:Contact/cmd:*"
					mode="#current"/>
				<xsl:apply-templates select="cmd:Components/*/cmd:Content/cmd:*" mode="#current"/>
				<xsl:apply-templates select="cmd:Components/*/cmd:Content/cmd:Languages/cmd:*"
					mode="#current"/>
				<xsl:apply-templates select="cmd:Components/*/cmd:Actors/cmd:*" mode="#current"/>
				<xsl:apply-templates select="cmd:Components/*/cmd:Resources/cmd:MediaFile/cmd:*"
					mode="#current"/>
				<xsl:apply-templates
					select="cmd:Components/*/cmd:Resources/cmd:WrittenResource/cmd:*"
					mode="#current"/>
				<xsl:apply-templates select="cmd:Components/*/cmd:Resources/cmd:Source/cmd:*"
					mode="#current"/>
				<xsl:apply-templates select="cmd:Components/*/cmd:References/cmd:*" mode="#current"
				/>
			</xsl:variable>
			<!-- hard coded some fallbacks (created using the VLO-based mapping tool created for DASISH ;-) for non-IMDI-based CMDI profiles
				TODO: make this more generic -->
			<xsl:if test="empty($dc/dc:title[normalize-space() != ''])">
				<xsl:variable name="title"
					select="
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1328259700928')]/cmd:Components/cmd:Soundbites-recording/cmd:SESSION/cmd:Name/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1328259700928')]/cmd:Components/cmd:Soundbites-recording/cmd:SESSION/cmd:SessionResources/cmd:WrittenResources/cmd:WrittenResource/cmd:Name/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1328259700937')]/cmd:Components/cmd:Soundbites/cmd:Collection/cmd:GeneralInfo/cmd:Name/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1328259700937')]/cmd:Components/cmd:Soundbites/cmd:Collection/cmd:GeneralInfo/cmd:Title/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1331113992512')]/cmd:Components/cmd:SL-IPROSLA/cmd:SL-Session/cmd:ResourceShortName/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1345561703620')]/cmd:Components/cmd:collection/cmd:CollectionInfo/cmd:Name/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1345561703620')]/cmd:Components/cmd:collection/cmd:CollectionInfo/cmd:Title/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1361876010653')]/cmd:Components/cmd:DiscAn_TextCorpus/cmd:GeneralInfo/cmd:ResourceName/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1361876010653')]/cmd:Components/cmd:DiscAn_TextCorpus/cmd:GeneralInfo/cmd:ResourceTitle/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1361876010653')]/cmd:Components/cmd:DiscAn_TextCorpus/cmd:Publications/cmd:Publication/cmd:PublicationTitle/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1366895758243')]/cmd:Components/cmd:DiscAn_Case/cmd:TextTitle/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1375880372947')]/cmd:Components/cmd:LESLLA/cmd:Session/cmd:Name/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1375880372947')]/cmd:Components/cmd:LESLLA/cmd:Session/cmd:Title/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1375880372947')]/cmd:Components/cmd:LESLLA/cmd:Session/cmd:Utterances/cmd:Utterance/cmd:Resources/cmd:MediaFile/cmd:ResourceID/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1375880372947')]/cmd:Components/cmd:LESLLA/cmd:Session/cmd:Utterances/cmd:Utterance/cmd:Resources/cmd:WrittenResource/cmd:ResourceId/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1396012485083')]/cmd:Components/cmd:VALID/cmd:Session/cmd:Name/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1396012485083')]/cmd:Components/cmd:VALID/cmd:Session/cmd:Title/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1396012485083')]/cmd:Components/cmd:VALID/cmd:Session/cmd:Resources/cmd:MediaFile/cmd:ResourceID/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1396012485083')]/cmd:Components/cmd:VALID/cmd:Session/cmd:Resources/cmd:WrittenResource/cmd:ResourceId/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1396012485083')]/cmd:Components/cmd:VALID/cmd:Session/cmd:Resources/cmd:TestScores/cmd:ResourceID/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1361876010525')]/cmd:Components/cmd:DiscAn_Project/cmd:Project/cmd:ProjectName/text(),
						/cmd:CMD[contains(cmd:Header/cmd:MdProfile, 'clarin.eu:cr1:p_1361876010525')]/cmd:Components/cmd:DiscAn_Project/cmd:Project/cmd:ProjectTitle/text()" />
				<xsl:if test="exists($title[normalize-space() != ''][1])">
					<dc:title>
						<xsl:value-of select="$title[normalize-space() != ''][1]"/>
					</dc:title>
				</xsl:if>
			</xsl:if>
			<xsl:if test="empty($dc/dc:description[normalize-space() != ''])">
				<xsl:variable name="descr"
					select="
						string-join(distinct-values(/cmd:CMD[exists(cmd:Header/cmd:MdProfile[contains(., 'clarin.eu:cr1:p_1328259700928')])]/cmd:Components/(cmd:Soundbites-recording/cmd:SESSION/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:Description/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:Actors/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:Actors/cmd:Description/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:Actors/cmd:Actor/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:Actors/cmd:Actor/cmd:Description/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:Actors/cmd:Actor/cmd:ActorLanguages/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:Actors/cmd:Actor/cmd:ActorLanguages/cmd:Description/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:Actors/cmd:Actor/cmd:ActorLanguages/cmd:ActorLanguage/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:Actors/cmd:Actor/cmd:ActorLanguages/cmd:ActorLanguage/cmd:Description/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:SubjectLanguages/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:SubjectLanguages/cmd:Description/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:SubjectLanguages/cmd:SubjectLanguage/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:SubjectLanguages/cmd:SubjectLanguage/cmd:Description/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:Content/cmd:Modality/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:Content/cmd:Modality/cmd:Description/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:Content/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:Content/cmd:Description/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:SessionResources/cmd:MediaFile/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:SessionResources/cmd:MediaFile/cmd:Description/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:SessionResources/cmd:WrittenResources/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:SessionResources/cmd:WrittenResources/cmd:Description/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:SessionResources/cmd:WrittenResources/cmd:WrittenResource/cmd:AnnotationType/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:SessionResources/cmd:WrittenResources/cmd:WrittenResource/cmd:AnnotationType/cmd:Description/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:SessionResources/cmd:WrittenResources/cmd:WrittenResource/cmd:Description/text(),
						cmd:Soundbites-recording/cmd:SESSION/cmd:SessionResources/cmd:WrittenResources/cmd:WrittenResource/cmd:Description/cmd:Description/text())), ';'),
						string-join(distinct-values(/cmd:CMD[exists(cmd:Header/cmd:MdProfile[contains(., 'clarin.eu:cr1:p_1328259700937')])]/cmd:Components/(cmd:Soundbites/cmd:Description/cmd:Description/text(),
						cmd:Soundbites/cmd:Collection/cmd:GeneralInfo/cmd:Description/text(),
						cmd:Soundbites/cmd:Collection/cmd:GeneralInfo/cmd:Description/cmd:Description/text(),
						cmd:Soundbites/cmd:Collection/cmd:Project/cmd:Description/text(),
						cmd:Soundbites/cmd:Collection/cmd:Project/cmd:Description/cmd:Description/text(),
						cmd:Soundbites/cmd:Collection/cmd:Creators/cmd:Description/text(),
						cmd:Soundbites/cmd:Collection/cmd:Creators/cmd:Description/cmd:Description/text(),
						cmd:Soundbites/cmd:Collection/cmd:DocumentationLanguages/cmd:Description/text(),
						cmd:Soundbites/cmd:Collection/cmd:DocumentationLanguages/cmd:Description/cmd:Description/text())), ';'),
						string-join(distinct-values(/cmd:CMD[exists(cmd:Header/cmd:MdProfile[contains(., 'clarin.eu:cr1:p_1331113992512')])]/cmd:Components/(cmd:SL-IPROSLA/cmd:SL-Session/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-Session/cmd:Description/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:Project/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:Project/cmd:Description/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-Content/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-Content/cmd:Description/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-ActorSigner-ChildLanguage/cmd:ActorLanguages/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-ActorSigner-ChildLanguage/cmd:ActorLanguages/cmd:Description/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-ActorSigner-ChildLanguage/cmd:ActorLanguages/cmd:ActorLanguage/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-ActorSigner-ChildLanguage/cmd:ActorLanguages/cmd:ActorLanguage/cmd:Description/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-ActorResearcher/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-ActorResearcher/cmd:Description/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-ActorResearcher/cmd:ActorLanguages/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-ActorResearcher/cmd:ActorLanguages/cmd:Description/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-ActorResearcher/cmd:ActorLanguages/cmd:ActorLanguage/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-ActorResearcher/cmd:ActorLanguages/cmd:ActorLanguage/cmd:Description/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-Resources/cmd:SL-MediaFile/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-Resources/cmd:SL-MediaFile/cmd:Description/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-Resources/cmd:SL-AnnotationDocument/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-Resources/cmd:SL-AnnotationDocument/cmd:Description/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-Resources/cmd:SL-SourceVideo/cmd:Description/text(),
						cmd:SL-IPROSLA/cmd:SL-Resources/cmd:SL-SourceVideo/cmd:Description/cmd:Description/text())), ';'),
						string-join(distinct-values(/cmd:CMD[exists(cmd:Header/cmd:MdProfile[contains(., 'clarin.eu:cr1:p_1337778924955')])]/cmd:Components/(cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:languages/cmd:language/cmd:language-usage/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:languages/cmd:language/cmd:language-usage/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:languages/cmd:language/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:languages/cmd:language/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:languages/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:languages/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:lucea-affiliation/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:lucea-affiliation/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:lucea-questionnaire/cmd:lucea-questionnaire-english/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:lucea-questionnaire/cmd:lucea-questionnaire-english/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:lucea-questionnaire/cmd:lucea-questionnaire-musicality/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:lucea-questionnaire/cmd:lucea-questionnaire-musicality/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:lucea-questionnaire/cmd:lucea-questionnaire-languages/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:lucea-questionnaire/cmd:lucea-questionnaire-languages/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:lucea-questionnaire/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:lucea-questionnaire/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:physiology/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:physiology/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:audiometry/cmd:audiometryMeasurement/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:audiometry/cmd:audiometryMeasurement/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:audiometry/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:facilitator/cmd:audiometry/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:languages/cmd:language/cmd:language-usage/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:languages/cmd:language/cmd:language-usage/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:languages/cmd:language/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:languages/cmd:language/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:languages/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:languages/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:physiology/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:physiology/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:audiometry/cmd:audiometryMeasurement/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:audiometry/cmd:audiometryMeasurement/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:audiometry/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:audiometry/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:lucea-curriculum/cmd:exchange/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:lucea-curriculum/cmd:exchange/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:lucea-curriculum/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:lucea-curriculum/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:lucea-questionnaire/cmd:lucea-questionnaire-english/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:lucea-questionnaire/cmd:lucea-questionnaire-english/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:lucea-questionnaire/cmd:lucea-questionnaire-musicality/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:lucea-questionnaire/cmd:lucea-questionnaire-musicality/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:lucea-questionnaire/cmd:lucea-questionnaire-languages/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:lucea-questionnaire/cmd:lucea-questionnaire-languages/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:lucea-questionnaire/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:lucea-questionnaire/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:speaker/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:Description/text(),
						cmd:lucea/cmd:lucea-actors/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-recording/cmd:MediaFile/cmd:Description/text(),
						cmd:lucea/cmd:lucea-recording/cmd:MediaFile/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-recording/cmd:Description/text(),
						cmd:lucea/cmd:lucea-recording/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-recording/cmd:lucea-tasks/cmd:lucea-task/cmd:Content/cmd:Modality/cmd:Description/text(),
						cmd:lucea/cmd:lucea-recording/cmd:lucea-tasks/cmd:lucea-task/cmd:Content/cmd:Modality/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-recording/cmd:lucea-tasks/cmd:lucea-task/cmd:Content/cmd:Description/text(),
						cmd:lucea/cmd:lucea-recording/cmd:lucea-tasks/cmd:lucea-task/cmd:Content/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:lucea-recording/cmd:lucea-tasks/cmd:lucea-task/cmd:Description/text(),
						cmd:lucea/cmd:lucea-recording/cmd:lucea-tasks/cmd:lucea-task/cmd:Description/cmd:Description/text(),
						cmd:lucea/cmd:Description/text(),
						cmd:lucea/cmd:Description/cmd:Description/text())), ';'),
						string-join(distinct-values(/cmd:CMD[exists(cmd:Header/cmd:MdProfile[contains(., 'clarin.eu:cr1:p_1345561703620')])]/cmd:Components/(cmd:collection/cmd:CollectionInfo/cmd:Modality/cmd:Description/text(),
						cmd:collection/cmd:CollectionInfo/cmd:Modality/cmd:Description/cmd:Description/text(),
						cmd:collection/cmd:CollectionInfo/cmd:Description/text(),
						cmd:collection/cmd:CollectionInfo/cmd:Description/cmd:Description/text(),
						cmd:collection/cmd:WebReference/cmd:Description/text())), ';'),
						string-join(distinct-values(/cmd:CMD[exists(cmd:Header/cmd:MdProfile[contains(., 'clarin.eu:cr1:p_1361876010525')])]/cmd:Components/(cmd:DiscAn_Project/cmd:Project/cmd:Institution/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Project/cmd:Institution/cmd:Contact/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Project/cmd:Cooperations/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Project/cmd:Cooperations/cmd:Cooperation/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Project/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Project/cmd:Contact/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Access/cmd:DeploymentToolInfo/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Access/cmd:Contact/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Access/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Annotation/cmd:SegmentationUnits/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Annotation/cmd:AnnotationTypes/cmd:AnnotationType/cmd:TagsetInfo/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Annotation/cmd:AnnotationTypes/cmd:AnnotationType/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Annotation/cmd:AnnotationTypes/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Annotation/cmd:AnnotationToolInfo/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Annotation/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Documentations/cmd:Documentation/cmd:DocumentationLanguages/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Documentations/cmd:Documentation/cmd:DocumentationLanguages/cmd:DocumentationLanguage/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Documentations/cmd:Documentation/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Project/cmd:Documentations/cmd:Descriptions/cmd:Description/text())), ';'),
						string-join(distinct-values(/cmd:CMD[exists(cmd:Header/cmd:MdProfile[contains(., 'clarin.eu:cr1:p_1361876010653')])]/cmd:Components/(cmd:DiscAn_TextCorpus/cmd:GeneralInfo/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Project/cmd:Institution/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Project/cmd:Institution/cmd:Contact/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Project/cmd:Cooperations/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Project/cmd:Cooperations/cmd:Cooperation/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Project/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Project/cmd:Contact/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Publications/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Publications/cmd:Publication/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Documentations/cmd:Documentation/cmd:DocumentationLanguages/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Documentations/cmd:Documentation/cmd:DocumentationLanguages/cmd:DocumentationLanguage/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Documentations/cmd:Documentation/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Documentations/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:CorpusContext/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Creators/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Creators/cmd:Creator/cmd:Contact/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:CreationToolInfo/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Annotation/cmd:SegmentationUnits/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Annotation/cmd:AnnotationTypes/cmd:AnnotationType/cmd:TagsetInfo/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Annotation/cmd:AnnotationTypes/cmd:AnnotationType/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Annotation/cmd:AnnotationTypes/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Annotation/cmd:AnnotationToolInfo/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Annotation/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Source/cmd:MediaFiles/cmd:MediaFile/cmd:Access/cmd:DeploymentToolInfo/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Source/cmd:MediaFiles/cmd:MediaFile/cmd:Access/cmd:Contact/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Source/cmd:MediaFiles/cmd:MediaFile/cmd:Access/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Source/cmd:MediaFiles/cmd:MediaFile/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Source/cmd:MediaFiles/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Source/cmd:Derivation/cmd:DerivationToolInfo/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Source/cmd:Derivation/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Source/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Creation/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Access/cmd:DeploymentToolInfo/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Access/cmd:Contact/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:Access/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:SubjectLanguages/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:SubjectLanguages/cmd:SubjectLanguage/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:DocumentationLanguages/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:DocumentationLanguages/cmd:DocumentationLanguage/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:SizeInfo/cmd:TotalSize/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:SizeInfo/cmd:SizePerLanguage/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:ModalityInfo/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:ValidationGrp/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:TextTechnical/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_TextCorpus/cmd:TextTechnical/cmd:LanguageScripts/cmd:Descriptions/cmd:Description/text())), ';'),
						string-join(distinct-values(/cmd:CMD[exists(cmd:Header/cmd:MdProfile[contains(., 'clarin.eu:cr1:p_1366895758243')])]/cmd:Components/(cmd:DiscAn_Case/cmd:Annotationtypes-DiscAn/cmd:Annotation/cmd:SegmentationUnits/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Case/cmd:Annotationtypes-DiscAn/cmd:Annotation/cmd:AnnotationTypes/cmd:AnnotationType/cmd:TagsetInfo/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Case/cmd:Annotationtypes-DiscAn/cmd:Annotation/cmd:AnnotationTypes/cmd:AnnotationType/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Case/cmd:Annotationtypes-DiscAn/cmd:Annotation/cmd:AnnotationTypes/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Case/cmd:Annotationtypes-DiscAn/cmd:Annotation/cmd:AnnotationToolInfo/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Case/cmd:Annotationtypes-DiscAn/cmd:Annotation/cmd:Descriptions/cmd:Description/text(),
						cmd:DiscAn_Case/cmd:ModalityInfo/cmd:Descriptions/cmd:Description/text())), ';'),
						string-join(distinct-values(/cmd:CMD[exists(cmd:Header/cmd:MdProfile[contains(., 'clarin.eu:cr1:p_1375880372947')])]/cmd:Components/(cmd:LESLLA/cmd:Description/text(),
						cmd:LESLLA/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Project/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Project/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Content/cmd:Languages/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Content/cmd:Languages/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Content/cmd:Languages/cmd:Language/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Content/cmd:Languages/cmd:Language/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Content/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Content/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:MotherTongue/cmd:Language/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:MotherTongue/cmd:Language/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:MotherTongue/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:MotherTongue/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:PrimaryLanguage/cmd:Language/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:PrimaryLanguage/cmd:Language/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:PrimaryLanguage/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:PrimaryLanguage/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:SecondaryLanguage/cmd:Language/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:SecondaryLanguage/cmd:Language/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:SecondaryLanguage/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:SecondaryLanguage/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage/cmd:Language/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage/cmd:Language/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage2/cmd:Language/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage2/cmd:Language/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage2/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage2/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Utterances/cmd:Utterance/cmd:Resources/cmd:MediaFile/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Utterances/cmd:Utterance/cmd:Resources/cmd:MediaFile/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Utterances/cmd:Utterance/cmd:Resources/cmd:MediaFile/cmd:Access/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Utterances/cmd:Utterance/cmd:Resources/cmd:MediaFile/cmd:Access/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Utterances/cmd:Utterance/cmd:Resources/cmd:WrittenResource/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Utterances/cmd:Utterance/cmd:Resources/cmd:WrittenResource/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Utterances/cmd:Utterance/cmd:Resources/cmd:WrittenResource/cmd:Validation/cmd:descriptions/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Utterances/cmd:Utterance/cmd:Resources/cmd:WrittenResource/cmd:Access/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Utterances/cmd:Utterance/cmd:Resources/cmd:WrittenResource/cmd:Access/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Anonyms/cmd:Access/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:Anonyms/cmd:Access/cmd:Description/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:References/cmd:Description/text(),
						cmd:LESLLA/cmd:Session/cmd:References/cmd:Description/cmd:Description/text())), ';'),
						string-join(distinct-values(/cmd:CMD[exists(cmd:Header/cmd:MdProfile[contains(., 'clarin.eu:cr1:p_1396012485083')])]/cmd:Components/(cmd:VALID/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Project/cmd:Descriptions/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Content/cmd:Languages/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Content/cmd:Languages/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Content/cmd:Languages/cmd:Language/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Content/cmd:Languages/cmd:Language/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Content/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Content/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:OtherDetails/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:ActorCharacteristics/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:MotherTongue/cmd:Language/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:MotherTongue/cmd:Language/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:MotherTongue/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:MotherTongue/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:PrimaryLanguage/cmd:Language/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:PrimaryLanguage/cmd:Language/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:PrimaryLanguage/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:PrimaryLanguage/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:SecondaryLanguage/cmd:Language/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:SecondaryLanguage/cmd:Language/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:SecondaryLanguage/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:SecondaryLanguage/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage/cmd:Language/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage/cmd:Language/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage2/cmd:Language/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage2/cmd:Language/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage2/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:HomeLanguage2/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Languages/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Actors/cmd:Actor/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Resources/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Resources/cmd:MediaFile/cmd:Descriptions/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Resources/cmd:MediaFile/cmd:Access/cmd:Descriptions/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Resources/cmd:WrittenResource/cmd:Validation/cmd:descriptions/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Resources/cmd:WrittenResource/cmd:Access/cmd:Descriptions/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Resources/cmd:WrittenResource/cmd:Descriptions/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Resources/cmd:TestScores/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Resources/cmd:TestScores/cmd:Access/cmd:Descriptions/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Anonyms/cmd:Access/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:Anonyms/cmd:Access/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:References/cmd:Description/text(),
						cmd:VALID/cmd:Session/cmd:References/cmd:Description/cmd:Description/text(),
						cmd:VALID/cmd:Documentation/cmd:DocumentationLanguages/cmd:Descriptions/cmd:Description/text(),
						cmd:VALID/cmd:Documentation/cmd:DocumentationLanguages/cmd:DocumentationLanguage/cmd:Descriptions/cmd:Description/text(),
						cmd:VALID/cmd:Documentation/cmd:Descriptions/cmd:Description/text(),
						cmd:VALID/cmd:References/cmd:Descriptions/cmd:Description/text())), ';')"/>
				<xsl:if test="exists($descr[normalize-space() != ''][1])">
					<dc:description>
						<xsl:value-of select="$descr[normalize-space() != ''][1]"/>
					</dc:description>
				</xsl:if>
			</xsl:if>
			<xsl:copy-of select="$dc"/>
			<!--<xsl:comment>extra dc:description to enable full text search of the CMD record</xsl:comment>
			<dc:description>
				<xsl:value-of select="string-join((cmd:Header,cmd:Components)/tokenize(.,'\s+')[normalize-space(.)!=''],' ')"/>
			</dc:description>-->
		</oai_dc:dc>
	</xsl:template>

	<xsl:template match="text()" mode="dc"/>

	<!-- Session|Corpus.Name -->
	<xsl:template match="cmd:Components/*/cmd:Name" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:title</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session|Corpus.Title -->
	<xsl:template match="cmd:Components/*/cmd:Title" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:title</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Date -->
	<xsl:template match="cmd:Components/*/cmd:Date" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:date</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Location.Country -->
	<xsl:template match="cmd:Components/*/cmd:Location/cmd:Country" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:coverage</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Project.Title -->
	<xsl:template match="cmd:Components/*/cmd:Project/cmd:Title" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:title</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Project.Id -->
	<xsl:template match="cmd:Components/*/cmd:Project/cmd:Id" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:identifier</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Project.Contact.Name -->
	<xsl:template match="cmd:Components/*/cmd:Contact/cmd:Name" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:publisher</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Project.Contact.Organisation -->
	<xsl:template match="cmd:Components/*/cmd:Project/cmd:Contact/cmd:Organisation" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:publisher</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Content.Genre -->
	<xsl:template match="cmd:Components/*/cmd:Content/cmd:Genre" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:subject</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Content.SubGenre -->
	<xsl:template match="cmd:Components/*/cmd:Content/cmd:SubGenre" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:subject</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Content.Languages.Language.* -->
	<xsl:template match="cmd:Components/*/cmd:Content/cmd:Content_Languages/cmd:Content_Language"
		mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:subject</xsl:with-param>
			<xsl:with-param name="value-node" select="cmd:Name"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Actors.Actor -->
	<xsl:template match="cmd:Components/*/cmd:Actors/cmd:Actor" mode="dc">
		<xsl:apply-templates select="cmd:Name" mode="#current"/>
		<xsl:apply-templates select="cmd:Description" mode="#current"/>
	</xsl:template>
	<!-- Session.Actors.Actor.Role -->
	<xsl:template match="cmd:Components/*/cmd:Actors/cmd:Actor/cmd:Name" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:contributor</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Resources.MediaFile.Type -->
	<xsl:template match="cmd:Components/*/cmd:Resources/cmd:MediaFile/cmd:Type" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:type</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Resources.MediaFile.Format -->
	<xsl:template match="cmd:Components/*/cmd:Resources/cmd:MediaFile/cmd:Format" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:format</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Resources.WrittenResource.Format -->
	<xsl:template match="cmd:Components/*/cmd:Resources/cmd:WrittenResource/cmd:Format" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:format</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Resources.WrittenResource.ContentEncoding -->
	<xsl:template match="cmd:Components/*/cmd:Resources/cmd:WrittenResource/cmd:ContentEncoding"
		mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:format</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Resources.WrittenResource.CharacterEncoding -->
	<xsl:template match="cmd:Components/*/cmd:Resources/cmd:WrittenResource/cmd:CharacterEncoding"
		mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:format</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- Session.Resources.Source.Format -->
	<xsl:template match="cmd:Components/*/cmd:Resources/cmd:Source/cmd:Format" mode="dc">
		<xsl:call-template name="create-dc-element">
			<xsl:with-param name="dc-name">dc:format</xsl:with-param>
			<xsl:with-param name="value-node" select="."/>
		</xsl:call-template>
	</xsl:template>

	<!-- Description (sub) -->
	<xsl:template match="cmd:Description" mode="dc">
		<xsl:if test="not(normalize-space(.) = '')">
			<dc:description xmlns:dc="http://purl.org/dc/elements/1.1/">
				<xsl:copy-of select="@xml:lang"/>
				<xsl:value-of select="text()"/>
				<xsl:if test="not(@Link = '')">
					<xsl:value-of select="@Link"/>
				</xsl:if>
			</dc:description>
		</xsl:if>
	</xsl:template>

	<!-- create dublin core element -->
	<xsl:template name="create-dc-element">
		<xsl:param name="dc-name"/>
		<xsl:param name="value-node"/>
		<xsl:if
			test="not(normalize-space($value-node) = '') and (normalize-space($value-node) != 'Unspecified')">
			<xsl:element name="{$dc-name}" xmlns:dc="http://purl.org/dc/elements/1.1/"
				xmlns:dcterms="http://purl.org/dc/terms/">
				<xsl:value-of select="normalize-space($value-node)"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>