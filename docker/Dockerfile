# syntax=docker/dockerfile:1

# use below command to build image

# docker build -t ah-mvn:v1 -f Dockerfile --build-arg AH_VERSION="1.14.1-SNAPSHOT" --build-arg SCHEMA_VERSION=1.138.3-SNAPSHOT --build-arg CATALOG_VERSION=1.138.4-SNAPSHOT  --build-arg saxon_lic=saxon-license.lic  ../
#docker build --platform=linux/amd64 -t khannakavish/cloudfeeds-atomhopper:v43 -f Dockerfile --build-arg AH_VERSION="1.14.1-SNAPSHOT" --build-arg SCHEMA_VERSION=1.138.3-SNAPSHOT --build-arg CATALOG_VERSION=1.138.4-SNAPSHOT  --build-arg saxon_lic=saxon-license.lic  ../

# docker build -t ah-mvn:v1 -f Dockerfile .

# =============== Clone Cloudfeeds-atomhopper repo to build container image in AWS EC2 Image Builder ===============
FROM bitnami/git:latest AS fetcher

# Pass custom values for any Below ARG variables from ECS Container Definition
ARG git_url=https://github.com/rackerlabs/cloudfeeds-atomhopper.git

# ARG git_branch="feature_containerization"
ARG git_branch="CF-3561-EC2-image-builder"

ENV GIT_URL=${GIT_URL:-$git_url} \
    GIT_BRANCH=${GIT_BRANCH:-$git_branch}

RUN mkdir -p /home/ah && \
    cd /home && \
    git clone -b ${GIT_BRANCH} ${GIT_URL} ah

# ======================== Build cloudfeeds atomhopper using maven container image =======================

FROM maven:3.8.6-openjdk-8-slim AS builder

ARG ah_version="1.14.1-SNAPSHOT"

ENV AH_VERSION=${AH_VERSION:-$ah_version}

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

COPY --from=fetcher /home/ah/ /cf-ah
#RUN mvn clean -e -B package
RUN mvn -B package


# ======================== Download artifacts =======================
# Multi stage build
# Download artifacts

FROM alpine:3 as package

# Pass custom values for any ENV variables from ECS Container Definition
ARG schema_version="1.138.3-SNAPSHOT"

ENV SCHEMA_VERSION=${SCHEMA_VERSION:-$schema_version}

RUN apk add --update --no-cache curl tar && \
    curl https://artifacts.rackspace.net/artifactory/cloudfeeds-maven-local/com/rackspace/usage/usage-schema/${SCHEMA_VERSION}/usage-schema-${SCHEMA_VERSION}-schema.tar.gz | tar xz
   # TODO: verify the authenticity and integrity of above packages


# ======================== Create deploy Image =======================
FROM tomcat:9-jre8 as tomcat

ARG ah_version="1.14.1-SNAPSHOT"
ARG ah_home=/opt/atomhopper
ARG service_port=8080
ARG saxon_lic
ARG schema_version="1.138.3-SNAPSHOT"
ARG db_endpoint="https://dynamodb.us-east-1.amazonaws.com"


ENV SAXON_HOME=/etc/saxon \
    AH_VERSION=${AH_VERSION:-$ah_version} \
    SCHEMA_VERSION=${SCHEMA_VERSION:-$schema_version} \
    APP_CTX_PATH=/etc/atomhopper \
    AH_HOME=${AH_HOME:-$ah_home} \
    PATH=${PATH}:${CATALINA_HOME}/bin:${AH_HOME} \
    SERVICE_PORT=${SERVICE_PORT:-$service_port} \
    # DynamoDB Variables
    DB_ENDPOINT=${DB_ENDPOINT:-$db_endpoint}

LABEL Maintainer="cloudfeeds-core@rackspace.com" \
      description="Docker image for Cloudfeeds Atom-Hopper" \
      NAME="atomhopper" \
      Version="${AH_VERSION}"

# add non privileged user
RUN   groupadd --gid 1000 feeds && \
      useradd -u 1000 -g feeds feeds  && \
      mkdir -p "${AH_HOME}" "${SAXON_HOME}" "${APP_CTX_PATH}" /var/log/atomhopper/ /etc/cloudfeeds/translation/ && \
      chown -R feeds:feeds "${CATALINA_HOME}" "${AH_HOME}" "${SAXON_HOME}" "${APP_CTX_PATH}" /var/log/atomhopper/ /etc/cloudfeeds/translation/  && \
      wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64  && \
      chown feeds:feeds /usr/local/bin/dumb-init  && \
      chmod u+x /usr/local/bin/dumb-init

WORKDIR ${CATALINA_HOME}

COPY --chown=feeds:feeds --from=fetcher /home/ah/docker/files/application-context.xml           "${APP_CTX_PATH}"
COPY --chown=feeds:feeds --from=fetcher /home/ah/docker/files/atom-server.cfg.xml               "${APP_CTX_PATH}"
COPY --chown=feeds:feeds --from=fetcher /home/ah/docker/files/logback.xml                       "${APP_CTX_PATH}"
COPY --chown=feeds:feeds --from=fetcher /home/ah/docker/feedscatalog.xml                        /etc/feedscatalog/
COPY --chown=feeds:feeds --from=fetcher /home/ah/docker/transform.xsl                           /usr/local/tomcat
#COPY --chown=feeds:feeds --from=fetcher /home/ah/docker/${saxon_lic}                            ${SAXON_HOME}/saxon-license.lic
# COPY --chown=feeds:feeds ./entrypoint.sh /tmp/


RUN   apt-get update  && \
      yes | apt-get install xsltproc  && \
      xsltproc --output /usr/local/tomcat/conf/server.xml /usr/local/tomcat/transform.xsl /usr/local/tomcat/conf/server.xml  && \
      rm -rf /var/lib/apt/lists/*

USER feeds
VOLUME /usr/local/tomcat/logs/ /var/log/atomhopper/

COPY --chown=feeds:feeds --from=builder /cf-ah/feeds-atomhopper/target/feeds-atomhopper-1.14.1-SNAPSHOT.war ${CATALINA_HOME}/webapps/ROOT.war

COPY --chown=feeds:feeds --from=package /usage-schema-${SCHEMA_VERSION}/xslt-artifacts/* /etc/cloudfeeds/translation/

EXPOSE ${SERVICE_PORT}

# Perform health check
HEALTHCHECK --interval=20s --timeout=5s --start-period=10s --retries=3 \
      CMD curl -L --fail --silent --show-error --connect-timeout 3 --max-time 3 http://localhost:${SERVICE_PORT}/feedscatalog/catalog || exit 1


#Start tomcat server
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
# CMD ["sh", "-c", "echo ${SAXON_CONTENT} > ${SAXON_HOME}/saxon.lic", "&&",  "/usr/local/tomcat/bin/catalina.sh", "run"]
CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]
