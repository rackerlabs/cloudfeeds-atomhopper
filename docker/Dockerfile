#base tomcat 9 with openjdk 8
FROM tomcat:9.0.41-jdk8 as tomcat
COPY server.xml /usr/local/tomcat/conf/
COPY logging.properties /usr/local/tomcat/conf/
FROM adoptopenjdk/openjdk8:alpine-slim

LABEL maintainer="cloudfeeds-core@rackspace.com" \
      description="Docker image for Cloudfeeds-Atom Hopper"

#Saxon License file
ARG saxon_lic
ARG schema_version
ARG ah_version
ARG catalog_version

ENV SAXON_HOME=/etc/saxon \
    AH_VERSION=$ah_version \
    CATALINA_HOME=/opt/tomcat \
    AH_HOME=/opt/atomhopper \
    PATH=${PATH}:${CATALINA_HOME}/bin:${AH_HOME} \
    #Database type - postgres/dynamodb
    DB_TYPE= \
    #Postgres Variables
    DB_USER= \
    DB_PASSWORD= \
    DB_HOST= \
    DB_PORT= \
    #DynamoDB Variables
    DB_ENDPOINT= 

RUN mkdir -p "${CATALINA_HOME}" "${AH_HOME}" "${SAXON_HOME}" /etc/atomhopper/ /var/log/atomhopper/ /etc/cloudfeeds/translation/

WORKDIR ${AH_HOME}

COPY --from=tomcat /usr/local/tomcat ${CATALINA_HOME}
COPY entrypoint.sh .
COPY files/* /etc/atomhopper/
COPY feedscatalog.xml /etc/feedscatalog/
COPY ${saxon_lic} ${SAXON_HOME}/saxon-license.lic
COPY feeds-atomhopper.war .
#pulling from Artifactory and placing the war components 
RUN chmod +x ${AH_HOME}/entrypoint.sh
RUN apk --no-cache add curl tar bash \
    && curl https://artifacts.rackspace.net/artifactory/cloudfeeds-maven-local/com/rackspace/usage/usage-schema/${schema_version}/usage-schema-${schema_version}-schema.tar.gz | tar xz \
    && mv usage-schema-${schema_version}/xslt-artifacts/* /etc/cloudfeeds/translation/. \
    && mv feeds-atomhopper.war ${CATALINA_HOME}/webapps/ROOT.war \
    && curl -o ${CATALINA_HOME}/webapps/feedscatalog.war https://artifacts.rackspace.net/artifactory/cloudfeeds-maven-local/com/rackspace/feeds/feedscatalog/${catalog_version}/feedscatalog-${catalog_version}.war \
    && rm -r usage-schema*

EXPOSE 8080

CMD entrypoint.sh

