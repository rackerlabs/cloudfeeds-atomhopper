cloudfeeds-atomhopper
=====================

**docker build image and run the container**
Your current direcotry should be pointing to cloudfeeds-atomhopper/docker. Run the following command to build an image.
```
$docker build -t cloudfeeds-atomhopper:latest-alpine .
```

To run atomhopper with default database configuration (H2) and port 8080
```
$docker run -d --name atomhopper -p 8080:8080 atomhopper:latest-alpine
```
These ARGS  should be provided while building the docker image
```
ARG saxon_lic
ARG app_version
ARG ah_version

For ex: docker build --build-arg ah_version=1.9.1 --build-arg AH_VERSION=1.136.1
```

Following environment variables are set by default
```
ENV SAXON_HOME=/etc/saxon
AH_VERSION=$ah_version
CATALINA_HOME=/opt/tomcat
AH_HOME=/opt/atomhopper
PATH=${PATH}:${CATALINA_HOME}/bin:${AH_HOME}
```

**Cloud Feeds Atom Hopper**
is a Cloud Feeds component that customizes Atom Hopper web application for Rackspace use.
Some of the customizations are:

* Xml2JsonFilter: a servlet filter that converts XML to JSON on "application/vnd.rackspace.atom+json" ```Accept``` header
* TenantedEntryVerificationFilter: a servlet filter that ensures the tenantId in the URI matches with the tenantId inside the requested Atom entry via the URI /<feedname>/events/<tenantId>/entries/urn:uuid:<entryId>
* PrivateAttrsFilter: a servlet filter that removes private attributes of certain events/feeds for observers
* ExternalHrefFilter: a servlet filter that resolves the links (header and atom:link) correctly for requests coming in from external Cloud Feeds nodes
* TenantedFitler: a servlet filter that inserts tenantId search category and remove the tenantId from URI
  on tenanted requests

**How to build**
To build this component, we require JDK 1.8
```
mvn clean install
```

**How to build an RPM**
```
mvn -P build-rpm clean install
```
