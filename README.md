![FLAT logo](docker/flat/drupal/flat-logo.png) FLAT
===================================================
The FLAT project aims to develop an easy to use and
maintainable archive setup for language resources with
[Component Metadata](http://www.clarin.eu/cmdi/). Its based on [Fedora Commons](http://fedora-commons.org/)
and [Islandora](http://islandora.ca/). It should meet the technical requirements
for a [CLARIN B centre](http://hdl.handle.net/1839/00-DOCS.CLARIN.EU-77), the [Data Seal of Approval](http://datasealofapproval.org/) and those from the
organizations, the [Max Planck Institute for Psycholinguistics](http://www.mpi.nl/) and
the [Meertens Institute](http://www.meertens.knaw.nl/), that cooperate in [The Language Archive](http://tla.mpi.nl/).

Currently the setup of this project consists of a series of docker setups:

 1. A [FLAT base image](docker/flat/) that
   1. installs Fedora Commons and Islandora
   2. provides tools and scripts to import CMD records into Fedora
   3. adds support for rendering of CMD records in Islandora

 2. A [FLAT Islandora SOLR image](docker/add-islandora-solr-to-flat) builds on the base image and
   1. installs Islandora's SOLR modules

 3. A [FLAT search image](docker/add-gsearch-to-flat) builds on the base image and the Islandora SOLR image
   1. installs generic search for Fedora Commons
   2. provides tools and scripts to configure the index proces for a specific set of CMD records and profiles

 4. A [FLAT SWORD image](docker/add-sword-to-flat) builds on the base image and
   1. installs a SWORD v2 API to receive bags
   
 5. Am *experimental* [FLAT DoorKeeper image](docker/add-doorkeeper-to-flat) builds on the base image and
   1. installs the DoorKeeper, which guards the repository and checks new or updated resources and metadata
   2. installs the DoorKeeper API to process bags

 6. An *experimental* [FLAT deposit UI image](docker/add-deposit-ui-to-flat) builds on the base image and the SWORD image
   1. installs a module that provides an UI for users to deposit data
   
 7. An *experimental* [FLAT Shibbolet image](docker/add-shibboleth-to-flat) builds on the base image and
   1. installs Shibboleth
   2. installs Drupal's Shibboleth modules
   
 8. An *experimental* [FLAT solution packs image](docker/add-solution-packs-to-flat) builds on the base image and
   1. installs Islandora solution packs
   2. provides scripts to trigger the addition of derived datastreams like thumbnails

The FLAT base image is required, but the other ones can be added to it as needed (but might depend on eachother).

Additionally there are two docker setups specific for IMDI and CMDIfied IMDI:

 7. A [FLAT IMDI conversion image](docker/add-imdi-conversion-to-flat) builds on the base image and
   1. provides tools and scripts to convert from IMDI to CMDI

 8. A [FLAT IMDI search image](docker/add-imdi-gsearch-to-flat) builds on the search image and
   1. provides the mapping to configure the index proces for CMDIfied IMDI records and profiles

## Building a FLAT docker image (for CMDIfied IMDI) ##

(This description assumes you're using the [Docker Toolbox](https://www.docker.com/products/docker-toolbox).
In case you can run Docker natively you'll have to change the ```192.168.99.100``` by ```localhost```, both in the following commands and in some of the Dockerfiles used.)

CMDI records can vary a lot. This introductionary example uses CMDIfied IMDI as it allows some more pre-defined configuration. See below for some hints when you don't have IMDI records.

The following commands show how to build a setup that supports CMDIfied IMDI with the FLAT base plus facetted search:

```sh
cd docker
#start with the FLAT base
docker build --rm=true -t flat-base flat/
#run a flat-base container, and type exit when the prompt appears
docker run -p 80:80 -p 8443:8443 --name=flat-base -t -i flat-base
#export the flat-base container as a new image, this overcomes the limit of 127 layers
docker export flat-base | docker import - flat
#dynamically create a Dockerfile with the settings which are missing from the new image
mkdir add-flat-env
echo "FROM flat" > add-flat-env/Dockerfile
egrep '^(ENV|CMD|ENTRYPOINT|EXPOSE|WORKDIR).*' flat/Dockerfile >> add-flat-env/Dockerfile
docker build --rm=true -t flat add-flat-env/
#add IMDI conversion
docker build --rm=true -t flat add-imdi-conversion-to-flat/
#add Fedora gsearch + SOLR
docker build --rm=true -t flat add-gsearch-to-flat/
#add Islandora SOLR module
docker build --rm=true -t flat add-islandora-solr-to-flat/
#add configuration for CMDIfied IMDI search
docker build --rm=true -t flat add-imdi-gsearch-to-flat/
```

## Running a FLAT docker image ##

Now the FLAT docker image can be run:

```sh
docker run -p 80:80 -p 8443:8443 -p 8080:8080 -v ./some-directory:/lat -t -i flat
```

Where ```./some-directory``` contains your own IMDI records and resources. At the prompt type:

```sh
cd /app/flat
#make the IMDI records in /lat the source
ln -s /lat /app/flat/src
#CMDIfy the IMDI records
./do-0-convert.sh
#turn the records into FOXML
./do-1-fox.sh
#import the FOXML into Fedora Commons
./do-2-import.sh
#configure the facetted search
./do-3-config-cmd-search.sh
#index the records
./do-4-index.sh
```

Now visit FLAT in your browser: http://192.168.99.100/flat.

##Configuration for your CMDI##

If you have native CMD records you need both less and more. You won't need the IMDI conversion and the configuration for CMDIfied IMDI search.

```sh
cd docker
#start with the FLAT base
docker build --rm=true -t flat-base flat/
#run a flat-base container, and type exit when the prompt appears
docker run -p 80:80 -p 8443:8443 --name=flat-base -t -i flat-base
#export the flat-base container as a new image, this overcomes the limit of 127 layers
docker export flat-base | docker import - flat
#dynamically create a Dockerfile with the settings which are missing from the new image
mkdir add-flat-env
echo "FROM flat" > add-flat-env/Dockerfile
egrep '^(ENV|CMD|ENTRYPOINT|EXPOSE|WORKDIR).*' flat/Dockerfile >> add-flat-env/Dockerfile
docker build --rm=true -t flat add-flat-env/
#add Fedora gsearch + SOLR
docker build --rm=true -t flat add-gsearch-to-flat/
#add Islandora SOLR module
docker build --rm=true -t flat add-islandora-solr-to-flat/
```

However, you'll need an XSLT that provides a mapping from your CMD records to some basic Dublin Core elements, i.e., at least ```dc:title``` and preferably ```dc:description```.
You can take [the one for CMDIfied IMDI](./docker/add-imdi-conversion-to-flat/flat/scripts/cmd2dc.xsl) as inspiration.
It can be mounted at the right place in the docker image:

```sh
docker run -p 80:80 -p 443:443 -p 8443:8443 -p 8080:8080 -v ./some-directory:/lat -v ./another-directory/cmd2dc.xsl:/app/flat/cmd2dc.xsl -t -i flat
```

The scripts for the bulk import start look for the CMD records in the ```/app/flat/cmd``` directory:

```sh
cd /app/flat
#make the CMDI records in /lat the source
ln -s /lat /app/flat/cmd
#turn the records into FOXML
./do-1-fox.sh
#import the FOXML into Fedora Commons
./do-2-import.sh
#configure the facetted search
./do-3-config-cmd-search.sh
#index the records
./do-4-index.sh
```

## Publications, Presentations & Demonstrations ##

* M. Windhouwer. [Fedora Commons in the CLARIN Infrastructure](http://www.slideshare.net/mwindhouwer/fedora-commons-in-the-clarin-infrastructure). Presentation at [_CLARIN-PLUS workshop: "Facilitating the Creation of National Consortia - Repositories"_](https://www.clarin.eu/event/2017/clarin-plus-workshop-facilitating-creation-national-consortia-repositories). Prague, Czech Republic, February 9 - 10, 2017.
* P. Trilsbeek, M. Windhouwer. [FLAT: A CLARIN-compatible repository solution based on Fedora Commons](https://www.clarin.eu/content/abstracts-overview-clarin-annual-conference-2016#Z). At the [_CLARIN Annual Conference_](https://www.clarin.eu/event/2016/clarin-annual-conference-2016-aix-en-provence-france). Aix-en-Provence, France, 26-28 October, 2016. 
* M. Windhouwer, M. Kemps-Snijders, P. Trilsbeek, A. Moreira, B. van der Veen, G. Silva, D. von Rhein. [FLAT: constructing a CLARIN compatible home for language resources](http://www.lrec-conf.org/proceedings/lrec2016/summaries/476.html). In _Proceedings of the Tenth International Conference on Language Resources and Evaluation_ ([LREC 2016](http://lrec2016.lrec-conf.org/en/)), European Language Resources Association ([ELRA](http://www.elra.info/)), Portorož, Slovenia, May 23 - 28, 2016. ([Local updated version](documents/2016-LREC-FLAT.pdf))

___
FLAT was once upon a time known as EasyLAT, so occassionally documentation and code might still use that name.
