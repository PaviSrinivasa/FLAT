<?php

/**
 * Created by PhpStorm.
 * User: danrhe
 * Date: 09/06/16
 * Time: 12:24
 */


require_once (drupal_realpath(drupal_get_path('module', 'flat_deposit_ui')) . '/inc/config.inc');


class CMDI_Handler

{
    public $bundle;
    public $collection;
    public $md_config;
    public $template;
    public $field_name;
    public $handles;
    public $xml;
    public $export_file;
    public $prefix;
    public $files_info;
    public $form_data;
    public $resources;
    public $form_fields;

    /**
     * CMDI_creator constructor.
     * @param $file string    folder name where to export the xml file to
     * @param $bundle
     * @param $template
     */
    public function __construct($node, $template='default')
    {
        $wrapper = entity_metadata_wrapper('node', $node);

        $this->bundle = $node->title;
        $this->collection = $wrapper->upload_collection->value();
        $this->template = $template;
        $this->user = user_load($node->uid);

        $this->md_config = get_configuration_metadata();

        $this->field_name = $this->md_config['prefix'] . '-' . $template;
        $this->prefix = 'hdl:';
        $this->export_file = $this->determine_export_file($wrapper);
        
    }


    /**
     * Function dertermining location of CMDI. Depending on the bundles status this can be either the freeze directory or either the drupal data directory or an external directory
     * @param $wrapper
     * @return string
     */
    public function determine_export_file($wrapper){
        $status = $wrapper->upload_status->value();
        $external = $wrapper->upload_external->value();

        if ($status == 'processing'){
            $file = FREEZE_DIR . '/' . $this->user->name . "/$this->collection/$this->bundle/metadata/record.cmdi";
        } elseif ($external){
            $a = module_load_include('inc', 'flat_deposit_ui', 'inc/config');
            $config = get_configuration_ingest_service();

            $location = $wrapper->upload_location->value();
            $file = $config['alternate_dir'] . USER . $config['alternate_subdir'] . "/$location/metadata/record.cmdi";
        } else {
            $file = USER_DRUPAL_DATA_DIR."/$this->collection/$this->bundle/metadata/record.cmdi";
        }
    return $file;
    }



    /**
     * This method either loads a simpleXML object from an existing CMDI file or generates a CMDI tree with only the basic nodes.
     */
    function getXML(){

    if ($this->projectCmdiFileExists()){
        $this->xml = simplexml_load_file($this->export_file);
    } else { $this->initiateNewCMDI(); }


}

    /**
     * Methods that generates a new, valid CMDI file including processing instructions, empty data fields and attributes
     */
    function initiateNewCMDI(){

        module_load_include('php', 'flat_deposit_ui', 'inc/xml_functions');
        $this->xml = new SimpleXMLElement_Plus('<CMD/>');

        // add processing instructions
        $processing_instruction = get_processing_instructions($this->md_config['site_name']) ;
        $this->xml->addProcessingInstruction($processing_instruction[0], $processing_instruction[1]);

        // add attributes
        $CMD_attributes = get_attributes ("MPI") ;
        add_attribute_tree_to_xml($CMD_attributes,$this->xml);

        // add (almost) empty xml data fields (=tree)
        $basis_tree = array(
            'Header' => array(
                'MdCreator' => '',
                'MdCreationDate' => '',
                #'MdSelfLink' => '',
                'MdProfile' => $this->md_config['MdProfile'],
            ),
            'Resources' => array(
                'ResourceProxyList' => '',
                'JournalFileProxyList' => '',
                'ResourceRelationList' => '',
                'IsPartOfList' => ''),
            'Components' => array(
                $this->field_name => '')
        );
        array_to_xml($basis_tree,$this->xml);
    }

    /**
     * Methods checking whether a cmdi file is found at a certain location
     *
     * @param $fileName null if a additional parameter is provided the method looks at differnent than standard location
     *
     * @return bool
     */
    function projectCmdiFileExists ($fileName=NULL){
        $checkfile = (is_null($fileName)) ? $this->export_file : $fileName;
        return file_exists($checkfile);
    }



    /**
     * This function recursively    searches for files in the user data directory
     *
     * @param $directory string     path where to search for files
     *
     * @returns $resources array    file id's as keys and file names as values
     */
    public function searchDir($directory){


        $rii = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($directory,RecursiveDirectoryIterator::FOLLOW_SYMLINKS));

        $resources = array();
        $c=10000; # counter for resource ID (each resource within an CMDI-object needs an unique identifier)


        foreach ($rii as $file) {
            if ($file->isDir()){
                continue;}

            $c++;
            $fid = "d$c";
            $resources[$fid] = $file->getPathname();

        }

        return $resources;


    }


    /**
     * This method fills the resources section of the cmdi file with all files found in the open bundle data directory
     *
     * <ResourceRef>../data/Write_me.txt</ResourceRef>
     */
    function addResourcesToXml(){

        foreach ($this->resources as $fid => $file) {

            // transform drupal path to relative path as needed for fedora ingest
            #$localURI = str_replace(USER_FREEZE_DIR ."/" . $this->collection ."/" . $this->bundle, "..", $file);

            # Mimetype of the file;
            $mime = mime_content_type(drupal_realpath($file)) ;

            $data = $this->xml->Resources->ResourceProxyList->addChild('ResourceProxy');
            $data->addAttribute('id', $fid);
            $data->addChild('ResourceType', 'Resource');
            $data->addChild('ResourceRef', $file);

            $data->ResourceType->addAttribute('mimetype', $mime);

        }
    }



    function changeHeader()
    {
        $this->xml->Header->MdCreator = USER;
        $this->xml->Header->MdCreationDate = format_date(time(), 'custom', 'Y-m-d');;
        #$this->xml->Header->MdSelfLink = $this->handles['cmd'];
    }


    /**
     * This method transforms drupal form data into valid cmdi meta data.
     * Particularly, (1) date is formatted (2) tree info is changed (e.g. move Components/field_1/Name to Components/Name)). Only template specific data is added to the class

     * @param $form_data array of meta data harvested from drupal form
     */
    function processFormData($form_data){

        $clean_data = array();
        $clean_data['Title'] = $form_data['field_1']['Title'];
        $clean_data['Name'] = $form_data['field_1']['Name'];

        if ($form_data['field_1']['Date']) {
            $month = (strlen($form_data['field_1']['Date']['month']) == 1 ) ? $form_data['field_1']['Date']['month'] : '0'.$form_data['field_1']['Date']['month'];
            $date = $form_data['field_1']['Date']['year'] . '-' . $month . '-' . $form_data['field_1']['Date']['day'];
        }
        else $date = NULL;

        $clean_data['Date'] = $date;
        $clean_data['Date'] = $date;

        // add all template specific fields to the xml
        foreach ($form_data['form_fields_template'] as $field){
            if ($field != "field_1"){
                $clean_data[$field] = $form_data[$field];}
        }
        $this->form_data = $clean_data;

    }


    /**
     * Transforms array to xml tree
     */
    function addComponentInfoToXml()
    {
        module_load_include('php', 'flat_deposit_ui', 'inc/xml_functions');

        $data = $this->xml->Components->{$this->field_name};
        array_to_xml($this->form_data, $data);
    }

}



/**
 * Returns a form array with fields that may be filled in by researchers to generate metadata to be archived together with their data
 *
 * @param string $template  The name of the template to be used (at the moment options are experiment, session, and minimal
 * @param array $md     Passed meta data will be used to fill the form with default values
 * @return array $form which will be appended to a form array in drupal and rendered.
 */
function get_template_form($template, $bundle, $md=NULL)
{
    module_load_include('inc', 'flat_deposit_ui', 'inc/CMDI_templates');

    $tmp = new CMDI_templates($template);
    $tmp->getTemplate($md);

    $form = $tmp->fields;

    return $form;
}




function get_example_md ($template){
    switch ($template) {

        case 'session':
            $md = array(
                'field_1' => array(
                    'Title' => 'The DvR_Sandbox',
                    'Name' => 'DvR_Sandbox',
                    'Date' => array(
                        'day' => 25,
                        'month' =>5,
                        'year' => 2016),
                    'descriptions' => array(
                        'Description' => 'The is a test dataset and Daniels favorite dog is called James',)
                ),

                'Location' => array(
                    'Continent'=>'Europe',
                    'Country'=> 'The Netherlands',
                    'Region'=> 'House of Language',
                    'Address'=> 'Wundtlaan 1',
                ),

                'Project' => array(
                    'Title' =>'Deposit module',
                    'Name' =>'FLAT archive',
                    'Id' =>'',
                    'Contact' => array(
                        'Name' => 'Daniel',
                        'Email' => 'Daniel@email.nl',
                        'Organisation' => 'MPI Nijmegen',
                    ),
                    'descriptions' => array(
                        'Description' => 'FLAT Test set')
                )
            );
            break;
        case 'experiment':
            $md = array(
                'field_1' =>
                    array (
                        'Title' => 'Pilot EEG Study',
                        'Name' => 'Subject_x01',
                        'Date' => array(
                            'day' => 25,
                            'month' =>3,
                            'year' => 2016),                    ),
                'Experiment' =>
                    array (
                        'Title' => 'EEG study on bilingual idiomatic expressions  ',
                        'Notebook_Name' => '',
                        'Contact' =>
                            array (
                                'User_Name' => 'Daniel Tobias',
                                'Tel_number' => '+3164482903',
                                'Email' => 'Daniel@mpi.nl',
                            ),
                        'descriptions' =>
                            array (
                                'Description' => '',
                            ),
                        'conclusions' =>
                            array (
                                'Conclusion' => '',
                            ),
                    ),
            );
            break;
        case 'minimal':
            $md = array(
                'field_1' =>
                    array (
                        'Title' => 'Title of Bundle',
                        'Name' => 'Name of Bundle',
                        'Date' => array(
                            'day' => 21,
                            'month' =>2,
                            'year' => 2013),
                        ),
                'Project'=> array(
                    'Name' => 'Project name',
                    'Title' => 'Project Title',
                    'Id' => '0187502u',

                    'Contact' =>
                        array (
                            'Name' => 'Daniel Tobias',
                            'Email' => 'Daniel@mpi.nl',
                            'Organisation' => 'MPI'
                        ),
                    'descriptions' =>
                        array (
                            'Description' => 'bvaboav', ),
                ),
            );
            break;

    }
    return $md;

}





function get_processing_instructions($profile){
    switch ($profile){
        case "MPI":
    return array (
        0 => 'xml-stylesheet',
        1 => 'type="text/xsl" href="/cmdi-xslt-1.0/browser_cmdi2html.xsl"');
    }

}

function get_attributes ($xml){
    switch ($xml){
        case "MPI":
    return array(
        'xmlns:xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xmlns' => "http://www.clarin.eu/cmd/",
        'xmlns:xmlns:cmd' => "http://www.clarin.eu/cmd/" ,
        'xmlns:xmlns:imdi' => "http://www.mpi.nl/IMDI/Schema/IMDI",
        'xmlns:xmlns:lat' => "http://lat.mpi.nl/",
        'xmlns:xmlns:iso' => "http://www.iso.org/",
        'xmlns:xmlns:sil' => "http://www.sil.org/",
        'xmlns:xmlns:xs' => "http://www.w3.org/2001/XMLSchema",
        'xmlns:xmlns:functx' => "http://www.functx.com",
        'CMDVersion' => "1.1",
        'xmlns:xsi:schemaLocation' => "http://www.clarin.eu/cmd/ http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/clarin.eu:cr1:p_1407745712035/xsd");
    }
}

