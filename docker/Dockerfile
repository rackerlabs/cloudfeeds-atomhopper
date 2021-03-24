#base tomcat 9 with openjdk 8
FROM tomcat:9.0.41-jdk8 as tomcat

FROM adoptopenjdk/openjdk8:alpine-slim

LABEL maintainer="cloudfeeds-core@rackspace.com" \
      description="Docker image for Cloudfeeds-Atom Hopper"

#Saxon License file
ARG saxon_lic
ARG schema_version
ARG ah_version

ENV SAXON_HOME=/etc/saxon \
    AH_VERSION=$ah_version \
    CATALINA_HOME=/opt/tomcat \
    AH_HOME=/opt/atomhopper \
    PATH=${PATH}:${CATALINA_HOME}/bin:${AH_HOME}


RUN mkdir -p "${CATALINA_HOME}" "${AH_HOME}" "${SAXON_HOME}" /etc/atomhopper/ /var/log/atomhopper/ /etc/cloudfeeds/translation/

WORKDIR ${AH_HOME}

COPY --from=tomcat /usr/local/tomcat ${CATALINA_HOME}
COPY files/* /etc/atomhopper/
COPY feedscatalog.xml /etc/feedscatalog/
COPY ${saxon_lic} ${SAXON_HOME}/saxon-license.lic

RUN apk --no-cache add curl tar bash \
    && curl https://maven.research.rackspacecloud.com/content/repositories/releases/com/rackspace/usage/usage-schema/${schema_version}/usage-schema-${schema_version}-schema.tar.gz | tar xz \
    && mv usage-schema-${schema_version}/xslt-artifacts/* /etc/cloudfeeds/translation/. \
    && curl -o feeds-atomhopper.war https://maven.research.rackspacecloud.com/content/repositories/releases/com/rackspace/feeds/feeds-atomhopper/${AH_VERSION}/feeds-atomhopper-${AH_VERSION}.war \
    && mv feeds-atomhopper.war ${CATALINA_HOME}/webapps/ROOT.war

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]

