**docker build image and run the container**

Your current directory should be pointing to **{Project Home}/docker**. 

Run the following command to build an image with the required arguments.

Use **VPN** and keep **saxon.lic** fle in the directory for successful build of the image.

Following arguments are mandatory to be provided while building the docker image

- saxon_lic
- schema_version
- ah_version
- catalog_version



For example: 
```
docker build --build-arg ah_version=1.14.2-SNAPSHOT --build-arg schema_version=1.138.3-SNAPSHOT --build-arg catalog_version=1.138.4-SNAPSHOT --build-arg saxon_lic=saxon-license.lic -t cloudfeeds-atomhopper:latest .
```

- The cloudfeeds atomhopper docker image uses the feeds-atomhopper.war (https://artifacts.rackspace.net/ui/repos/tree/General/cloudfeeds-maven-local/com/rackspace/feeds/feeds-atomhopper)

- Currently we are using the feeds-atomhopper-1.14.2-SNAPSHOT.war which is internally using the atomhopper-1.2.35-SNAPSHOT.war(https://artifacts.rackspace.net/ui/repos/tree/General/cloudfeeds-maven-local/org/atomhopper/atomhopper).

- atomhopper-1.2.35-SNAPSHOT.war is having application-context.xml and atom-server.cfg.xml for dynamodb adapter. 

Following environment variables are set by default
```
ENV SAXON_HOME=/etc/saxon
AH_VERSION=$ah_version
CATALINA_HOME=/opt/tomcat
AH_HOME=/opt/atomhopper
PATH=${PATH}:${CATALINA_HOME}/bin:${AH_HOME}
```
**The Cloudfeeds image supports multiple databases: Postgres, DynamoDB**

Running Cloudfeeds with Postgres database.
```
docker run -d --name cloudfeeds:postgres -p 8080:8080 -e DB_TYPE=postgres -e DB_HOST=abc -e DB_PORT=5432 -e DB_USER=xyz -e DB_PASSWORD=xyz cloudfeeds-atomhopper:latest
```
Running Cloudfeeds with DynamoDB database. The DynamoDB endpoint must be a [Regional Endpoint](https://docs.aws.amazon.com/general/latest/gr/rande.html#regional-endpoints)
```
docker run -d --name cloudfeeds:dynamodb -p 8080:8080 -e DB_TYPE=dynamodb -e DB_ENDPOINT=http://xyz.com:8000 -e ACCESS_KEY_ID=AAAAAA -e SECRET_ACCESS_KEY=BBBBB cloudfeeds-atomhopper:latest
```