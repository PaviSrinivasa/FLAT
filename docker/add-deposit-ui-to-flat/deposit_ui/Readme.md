# FLAT deposit UI configuration #
## General ##
When using the docker environment most settings will be configured automatically. However, a few things still need to be done manually.


### File and Folder permissions ###
In order to ingest data without doorkeeper plugin, the sudoer file (visudo) needs to be adapted. Please copy/paste the code from the shell/sudoer.ini file using visudo

```ssh
sudo /usr/sbin/visudo
:%d #deletes the whole content

```
### SSH (optional) ### 
In order to ssh to the ssh server on a running container, you need to run following command (optional)
```ssh
/usr/sbin/sshd 
```

### Fedora web gui (optional) ### 
In order to see data on the fedora server(e.g. Foxml), we need to change a parameter in our native fedora config file. 

```ssh
vim /var/www/fedora/server/config/fedora.fcfg
# change value of ENFORCE MODE to permit all requests: <param name="ENFORCE-MODE" value="permit-all-requests"/>
```


## When not using docker ##
All configurations are specified in the inc/config.inc file. If you don't use docker, you definitely need to adapt this file to your needs. As, most likely, problems might particularly relate to the ingest function, also consult the Helpers/Ingest_service.php and Helpers/Fedora_REST_API.inc 

### Owncloud ###
If you want to use owncloud, you need to configure this app. You definitely need to change the permission of your owncloud installation. If you also want to be able open the owncloud web gui, you need to add the url of your server to the trusted domanins (see owncloud/addTrusted.php).

Also, the deposit folder needs to be accessible by the php server (e.g. www-data)

## Notes and knwon issues##

The UI expects that FOXML object names start with lat. If this is violated the Ingest service will complain

When the user opens the 'commit changes' page before creating a first upload, some owncloud errors might occur.

