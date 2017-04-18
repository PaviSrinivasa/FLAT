#/bin/sh

_PWD=$PWD

if [ -d /lat/Hocank ]; then
    mkdir -p /app/flat/src
    cd /app/flat/src
    ln -s /lat/Hocank .
    ln -s /lat/imdi-to-skip.txt .
fi

/app/flat/do-0-example-setup.sh &&\
 if [ -f /app/flat/do-0-convert.sh ]; then /app/flat/do-0-convert.sh; fi &&\
 /app/flat/do-0-config-cmd-gsearch.sh &&\
 /app/flat/do-1-fox.sh &&\
 /app/flat/do-2-import.sh &&\
 /app/flat/do-3-index.sh &&\
 /app/flat/do-9-example-setup.sh

cd $_PWD

# restart the tomcat, as some step above kills SSL (e.g., to the CR)
/var/www/fedora/tomcat/bin/shutdown.sh &&\
  bash -c "timeout $TOMCAT_TIMEOUT grep -q 'Server shutdown complete' <(tail -f $FEDORA_HOME/server/logs/fedora.log)" &&\
/var/www/fedora/tomcat/bin/startup.sh &&\
 bash -c "timeout $TOMCAT_TIMEOUT grep -q '(AuthFilterJAAS) initialised servlet filter: org.fcrepo.server.security.jaas.AuthFilterJAAS' <(tail -f $FEDORA_HOME/server/logs/fedora.log)" &&\


cat << EOF
TODO: 1. bag the test SIP directory:
TODO:   flat-create-sip.sh /app/flat/test/test-sip
TODO: 2. upload it via sword:
TODO:   flat-sword-upload.sh test-sip.zip test
TODO: 3. check enything went fine:
TODO    curl -u flat:sword http://localhost/flat/easy-deposit/statement/test | xmllint --format -
TODO: 4. trigger the doorkeeper:
TODO:   curl -X PUT http://localhost/flat/doorkeeper/test
TODO: OR
TODO:   doorkeeper.sh sip=test
TODO: 5. check the progress:
TODO:   curl http://localhost/flat/doorkeeper/test
TODO:   (repeat)
TODO: OR
TODO:   tail -f deposit/bags/test/bag-test-sip/data/test-sip/logs/devel.log
EOF