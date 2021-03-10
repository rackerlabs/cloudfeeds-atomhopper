#base tomcat 9 with openjdk 8
FROM tomcat:9.0.41-jdk8 as tomcat

FROM adoptopenjdk/openjdk8:alpine-slim

LABEL maintainer="AtomHopperTeam@rackspace.com" \
      #Atom Hopper version
      version="1.9.1" \
      description="Docker image for CloudFeeds Atom Hopper"

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

RUN mkdir -p "${CATALINA_HOME}" "${AH_HOME}" /etc/atomhopper/ /var/log/atomhopper/ /etc/cloudfeeds/translation/

WORKDIR ${AH_HOME}

COPY --from=tomcat /usr/local/tomcat ${CATALINA_HOME}
COPY application-context.xml atom-server.cfg.xml logback.xml /etc/atomhopper/
COPY xslt-artifacts/* /etc/cloudfeeds/translation/
COPY saxon-license.lic /etc/repose/
COPY feeds-atomhopper-1.9.1.war ${CATALINA_HOME}/webapps/

COPY start.sh .

RUN apk --no-cache add curl \
    && curl -o feeds-atomhopper.war https://maven.research.rackspacecloud.com/content/repositories/releases/com/rackspace/feeds/feeds-atomhopper/${AH_VERSION}/feeds-atomhopper-${AH_VERSION}.war \
#    && unzip feeds-atomhopper.war META-INF/application-context.xml META-INF/template-logback.xml WEB-INF/classes/META-INF/atom-server.cfg.xml -d . \
#    && mv META-INF/application-context.xml WEB-INF/classes/META-INF/atom-server.cfg.xml /etc/atomhopper/ \
#    && mv META-INF/template-logback.xml /etc/feeds-atomhopper/logback.xml \
    && mv feeds-atomhopper.war ${CATALINA_HOME}/webapps/ROOT.war \
#    && rm -rf META-INF WEB-INF \
    && chmod +x ${AH_HOME}/start.sh

EXPOSE 8080

CMD ["start.sh"]

