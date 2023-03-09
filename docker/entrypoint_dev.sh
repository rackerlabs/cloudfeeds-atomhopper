#!/usr/bin/env sh
#export APP_CTX_PATH=/etc/atomhopper

#echo "using APP_CTX_PATH="$APP_CTX_PATH
#echo "Database type selected:"$DB_TYPE

#export CURRENT_CTX_FILE=$APP_CTX_PATH/application-context-dynamodb.xml

#Replacing Endpoint
#sed -i -e "s@\(<property name=\"endpoint\" value=\"\).*\(\".*\)@\1${DB_ENDPOINT}\2@g" $CURRENT_CTX_FILE

#Replacing DynamoDB Configuration
#sed -i "s/\(<publisher reference=\"\).*\(\".*\)/\1dynamodb-feed-publisher\2/g" $APP_CTX_PATH/atom-server.cfg.xml
#sed -i "s/\(<feed-source reference=\"\).*\(\".*\)/\1dynamodb-feed-source\2/g" $APP_CTX_PATH/atom-server.cfg.xml 
#Final replacement to application-context.xml 
#mv $CURRENT_CTX_FILE $APP_CTX_PATH/application-context.xml

#Start tomcat server
#sh /opt/tomcat/bin/catalina.sh run
sh /usr/local/tomcat/bin/catalina.sh run
