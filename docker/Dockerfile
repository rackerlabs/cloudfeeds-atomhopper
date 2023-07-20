# syntax=docker/dockerfile:1

# use below command to build image

# docker build -t ah-mvn:v1 -f Dockerfile --build-arg AH_VERSION="1.14.1-SNAPSHOT" --build-arg SCHEMA_VERSION=1.138.3-SNAPSHOT --build-arg CATALOG_VERSION=1.138.4-SNAPSHOT  --build-arg saxon_lic=saxon-license.lic  ../
#docker build --platform=linux/amd64 -t khannakavish/cloudfeeds-atomhopper:v43 -f Dockerfile --build-arg AH_VERSION="1.14.1-SNAPSHOT" --build-arg SCHEMA_VERSION=1.138.3-SNAPSHOT --build-arg CATALOG_VERSION=1.138.4-SNAPSHOT  --build-arg saxon_lic=saxon-license.lic  ../

# docker build -t ah-mvn:v1 -f Dockerfile .

# =============== Clone Cloudfeeds-atomhopper repo to build container image in AWS EC2 Image Builder ===============
# FROM amazon/aws-cli:latest AS fetcher
FROM bitnami/git:latest AS fetcher

ARG GIT_URL=https://github.com/rackerlabs/cloudfeeds-atomhopper.git
#feature_containerization
ARG GIT_BRANCH="CF-3561-EC2-image-builder"

RUN mkdir -p /home/ah && \
    cd /home && \
#     git config --global credential.helper '!aws codecommit credential-helper $@' && \
#     git config --global credential.UseHttpPath true && \
    git clone -b ${GIT_BRANCH} ${GIT_URL} ah

# ======================== Build cloudfeeds atomhopper using maven container image =======================

FROM maven:3.8.6-openjdk-8-slim AS builder

ARG AH_VERSION="1.14.1-SNAPSHOT"

LABEL Maintainer="cloudfeeds-core@rackspace.com" \
      description="Docker image for Cloudfeeds Atom-Hopper" \
      NAME="cloudfeeds-atomhopper" \
      Version="${AH_VERSION}"

WORKDIR /cf-ah
COPY --from=fetcher /home/ah/pom.xml                              /cf-ah/pom.xml
COPY --from=fetcher /home/ah/test-utils/pom.xml                   /cf-ah/test-utils/pom.xml
COPY --from=fetcher /home/ah/filters/filter-utils/pom.xml         /cf-ah/filters/filter-utils/pom.xml
COPY --from=fetcher /home/ah/filters/xslt-filter/pom.xml          /cf-ah/filters/xslt-filter/pom.xml
COPY --from=fetcher /home/ah/filters/tenant-filter/pom.xml        /cf-ah/filters/tenant-filter/pom.xml
COPY --from=fetcher /home/ah/filters/external-href-filter/pom.xml /cf-ah/filters/external-href-filter/pom.xml
COPY --from=fetcher /home/ah/filters/private-attrs-filter/pom.xml /cf-ah/filters/private-attrs-filter/pom.xml
COPY --from=fetcher /home/ah/filters/json-filter/pom.xml          /cf-ah/filters/json-filter/pom.xml
COPY --from=fetcher /home/ah/feeds-atomhopper/pom.xml             /cf-ah/feeds-atomhopper/pom.xml

# RUN mvn -e -B dependency:resolve
RUN mvn dependency:go-offline

# COPY . .
COPY --from=fetcher /home/ah/ /cf-ah
#RUN mvn clean -e -B package
RUN mvn -B package


# ======================== Download artifacts =======================
# Multi stage build
# Download artifacts

FROM alpine:3 as package

# set SCHEMA_VERSION in other places also in this Dockerfile
ARG SCHEMA_VERSION="1.138.3-SNAPSHOT"
#ARG CATALOG_VERSION

#RUN apk add --update --no-cache curl tar ca-certificates && \
RUN apk add --update --no-cache curl tar && \
    curl https://artifacts.rackspace.net/artifactory/cloudfeeds-maven-local/com/rackspace/usage/usage-schema/${SCHEMA_VERSION}/usage-schema-${SCHEMA_VERSION}-schema.tar.gz | tar xz
#     curl -o /feedscatalog.war https://artifacts.rackspace.net/artifactory/cloudfeeds-maven-local/com/rackspace/feeds/feedscatalog/${CATALOG_VERSION}/feedscatalog-${CATALOG_VERSION}.war
   # TODO: verify the authenticity and integrity of above packages


# ======================== Create deploy Image =======================
# FROM tomcat:9.0.73-jre8-temurin-jammy as tomcat
FROM tomcat:9-jre8 as tomcat

ARG AH_VERSION
ARG ah_home=/opt/atomhopper
ARG service_port=8080
ARG saxon_lic
ARG SCHEMA_VERSION="1.138.3-SNAPSHOT"
ARG db_endpoint="https://dynamodb.us-east-1.amazonaws.com"

LABEL Maintainer="cloudfeeds-core@rackspace.com" \
      description="Docker image for Cloudfeeds Atom-Hopper" \
      NAME="cloudfeeds-atomhopper" \
      Version="${AH_VERSION}"


ENV SAXON_HOME=/etc/saxon \
    #CATALINA_HOME=/opt/tomcat \
    #AH_VERSION=$ah_version \
    APP_CTX_PATH=/etc/atomhopper \
    AH_HOME=${AH_HOME:-$ah_home} \
    PATH=${PATH}:${CATALINA_HOME}/bin:${AH_HOME} \
    SERVICE_PORT=${SERVICE_PORT:-$service_port} \
    # DynamoDB Variables
    DB_ENDPOINT=${DB_ENDPOINT:-$db_endpoint}

# add non privileged user
# RUN <<EOF
#       groupadd -r feeds && useradd -r -g feeds feeds

#       mkdir -p "${AH_HOME}" "${SAXON_HOME}" "${APP_CTX_PATH}" /var/log/atomhopper/ /etc/cloudfeeds/translation/
#       chown -R feeds:feeds "${CATALINA_HOME}" "${AH_HOME}" "${SAXON_HOME}" "${APP_CTX_PATH}" /var/log/atomhopper/ /etc/cloudfeeds/translation/

#       wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64
#       chown feeds:feeds /usr/local/bin/dumb-init
#       chmod u+x /usr/local/bin/dumb-init
# EOF

RUN   groupadd --gid 1000 feeds && \
      useradd -u 1000 -g feeds feeds  && \
      mkdir -p "${AH_HOME}" "${SAXON_HOME}" "${APP_CTX_PATH}" /var/log/atomhopper/ /etc/cloudfeeds/translation/ && \
      chown -R feeds:feeds "${CATALINA_HOME}" "${AH_HOME}" "${SAXON_HOME}" "${APP_CTX_PATH}" /var/log/atomhopper/ /etc/cloudfeeds/translation/  && \
      wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64  && \
      chown feeds:feeds /usr/local/bin/dumb-init  && \
      chmod u+x /usr/local/bin/dumb-init

WORKDIR ${CATALINA_HOME}

#COPY --chown=feeds:docker ./docker/entrypoint_dev.sh .
COPY --chown=feeds:feeds --from=fetcher /home/ah/docker/files/application-context.xml           "${APP_CTX_PATH}"
COPY --chown=feeds:feeds --from=fetcher /home/ah/docker/files/atom-server.cfg.xml               "${APP_CTX_PATH}"
COPY --chown=feeds:feeds --from=fetcher /home/ah/docker/files/logback.xml                       "${APP_CTX_PATH}"
COPY --chown=feeds:feeds --from=fetcher /home/ah/docker/feedscatalog.xml                        /etc/feedscatalog/
COPY --chown=feeds:feeds --from=fetcher /home/ah/docker/transform.xsl                           /usr/local/tomcat
#COPY --chown=feeds:feeds --from=fetcher /home/ah/docker/${saxon_lic}                            ${SAXON_HOME}/saxon-license.lic



RUN   apt-get update  && \
      yes | apt-get install xsltproc  && \
      xsltproc --output /usr/local/tomcat/conf/server.xml /usr/local/tomcat/transform.xsl /usr/local/tomcat/conf/server.xml  && \
      rm -rf /var/lib/apt/lists/*

USER feeds
VOLUME /usr/local/tomcat/logs/ /var/log/atomhopper/



#  ======================= get ca cert bundle from curl.haxx.se  =======================
#RUN curl https://curl.haxx.se/ca/cacert.pem -L -o /cacert.pem


COPY --chown=feeds:feeds --from=builder /cf-ah/feeds-atomhopper/target/feeds-atomhopper-1.14.1-SNAPSHOT.war ${CATALINA_HOME}/webapps/ROOT.war

COPY --chown=feeds:feeds --from=package /usage-schema-${SCHEMA_VERSION}/xslt-artifacts/* /etc/cloudfeeds/translation/

EXPOSE ${SERVICE_PORT}

# Perform health check
HEALTHCHECK --interval=20s --timeout=5s --start-period=10s --retries=3 \
      CMD curl -L --fail --silent --show-error --connect-timeout 3 --max-time 3 http://localhost:${SERVICE_PORT}/feedscatalog/catalog || exit 1


#Start tomcat server
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]
