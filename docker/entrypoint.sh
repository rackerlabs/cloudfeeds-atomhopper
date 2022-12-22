#!/bin/sh
export APP_CTX_PATH=/etc/atomhopper

echo "using APP_CTX_PATH="$APP_CTX_PATH
echo "Database type selected:"$DB_TYPE

export CURRENT_CTX_FILE=$APP_CTX_PATH/application-context-$DB_TYPE.xml

if [[ -e $CURRENT_CTX_FILE.orig ]]
    then
        echo "Replacing $CURRENT_CTX_FILE with original config."
        mv $CURRENT_CTX_FILE.orig $CURRENT_CTX_FILE
fi

if [[ -e $APP_CTX_PATH/atom-server.cfg.xml.orig ]]
    then
        echo "Replacing $APP_CTX_PATH/atom-server.cfg.xml with original config."
        mv $APP_CTX_PATH/atom-server.cfg.xml.orig $APP_CTX_PATH/atom-server.cfg.xml
fi

if [ "$DB_TYPE" = 'postgres' ] ;
then
    echo "PostgreSQL selected for configuration"
    if [[ -e $CURRENT_CTX_FILE ]] ; then
        #Taking backup of the original configuration 
        cp $CURRENT_CTX_FILE $CURRENT_CTX_FILE.orig
        echo "Replacing database configuration in $CURRENT_CTX_FILE"
        sed -i "s/\(jdbc:postgresql:\/\/\)[^\/]*\(\/\)/\1${DB_HOST}:${DB_PORT}\2/g" $CURRENT_CTX_FILE
        #Replace username
        sed -i "s/\(name=\"username\" value=\"\).*\(\".*\)/\1${DB_USER}\2/g" $CURRENT_CTX_FILE
        #Replace Password
        sed -i "s/\(name=\"password\" value=\"\).*\(\".*\)/\1${DB_PASSWORD}\2/g" $CURRENT_CTX_FILE
    fi
fi

if [ "$DB_TYPE" = 'dynamodb' ] ;
then
    echo "DynamoDB selected for configuration"
    if [[ -e $CURRENT_CTX_FILE ]] ; then
        #Taking backup of the original configuration 
        cp $CURRENT_CTX_FILE $CURRENT_CTX_FILE.orig
        echo "Replacing database configuration in $CURRENT_CTX_FILE"
        #Replacing Endpoint
        sed -i -e "s@\(<property name=\"endpoint\" value=\"\).*\(\".*\)@\1${DB_ENDPOINT}\2@g" $CURRENT_CTX_FILE

        #Taking backup of the original atom-server.cfg.xml
        cp $APP_CTX_PATH/atom-server.cfg.xml $APP_CTX_PATH/atom-server.cfg.xml.orig
        #Replacing DynamoDB Configuration
        sed -i "s/\(<publisher reference=\"\).*\(\".*\)/\1dynamodb-feed-publisher\2/g" $APP_CTX_PATH/atom-server.cfg.xml
        sed -i "s/\(<feed-source reference=\"\).*\(\".*\)/\1dynamodb-feed-source\2/g" $APP_CTX_PATH/atom-server.cfg.xml 
    fi
fi

#Final replacement to application-context.xml 
mv $CURRENT_CTX_FILE $APP_CTX_PATH/application-context.xml

#Start tomcat server
sh /opt/tomcat/bin/catalina.sh run
