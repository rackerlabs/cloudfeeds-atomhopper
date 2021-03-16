#base tomcat 9 with openjdk 8
FROM tomcat:9.0.41-jdk8 as tomcat

FROM adoptopenjdk/openjdk8:alpine-slim

LABEL maintainer="cloudfeeds@rackspace.com" \
      #Atom Hopper version
      version="1.9.1" \
      description="Docker image for Cloudfeeds-Atom Hopper"

#Saxon License file
ARG saxon_lic
ENV SAXON_HOME=/etc/saxon \

    #The database type
ENV DB_TYPE=H2 \
    #Database username
    DB_USER=sa \
    #Database password
    DB_PASSWORD= \
    #Database Host:Port
    DB_HOST=h2 \
    AH_VERSION=1.9.1 \
    CATALINA_HOME=/opt/tomcat \
    AH_HOME=/opt/atomhopper  \
    PATH=${PATH}:${CATALINA_HOME}/bin:${AH_HOME}

RUN mkdir -p "${CATALINA_HOME}" "${AH_HOME}" "${SAXON_HOME}" /etc/atomhopper/ /var/log/atomhopper/ /etc/cloudfeeds/translation/

WORKDIR ${AH_HOME}

COPY --from=tomcat /usr/local/tomcat ${CATALINA_HOME}
COPY start.sh .
COPY files/* /etc/atomhopper/
COPY feedscatalog.xml /etc/feedscatalog/
COPY ${saxon_lic} ${SAXON_HOME}/saxon-license.lic
RUN chmod +x ${AH_HOME}/start.sh

RUN apk --no-cache add curl tar bash \
    && curl https://maven.research.rackspacecloud.com/content/repositories/releases/com/rackspace/usage/usage-schema/${APP_VERSION}/usage-schema-${APP_VERSION}-schema.tar.gz | tar xz \
    && mv usage-schema-${APP_VERSION}/xslt-artifacts/* /etc/cloudfeeds/translation/. \
    && curl -o atomhopper.war https://maven.research.rackspacecloud.com/content/repositories/releases/com/rackspace/feeds/feeds-atomhopper/${AH_VERSION}/feeds-atomhopper-${AH_VERSION}.war \


EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]

