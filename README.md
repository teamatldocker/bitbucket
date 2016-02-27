# Dockerized Atlassian bitbucket

# Make It Short

Docker-CLI:

Just type and follow the manual installation procedure in your browser:

~~~~
$ docker run -d -p 7990:7990 --name bitbucket blacklabelops/bitbucket
~~~~

> Point your browser to http://yourdockerhost:7990

# Setup

1. Start database server for Bitbucket.
1. Start Bitbucket.
1. Manual Bitbucket setup.

Firstly, start the database server for Crowd:

> Note: Change Password!

~~~~
$ docker run --name postgres_bitbucket -d \
    -e 'POSTGRES_DB=bitbucketdb' \
    -e 'POSTGRES_USER=bitbucketdb' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    -e 'POSTGRES_ENCODING=UTF8' \
    blacklabelops/postgres
~~~~

Secondly, start Bitbucket:

~~~~
$ docker run -d --name bitbucket \
	  --link postgres_bitbucket:postgres_bitbucket \
	  -p 7990:7990 blacklabelops/bitbucket
~~~~

>  Starts Crowd and links it to the postgresql instances. JDBC URL: jdbc:postgresql://postgres_bitbucket/bitbucketdb

Thirdly, configure your Crowd yourself and fill it with a test license.

Point your browser to http://yourdockerhost:7990

1. Choose `External` for `Database` and fill out the form:
  * Database Type: `PostgreSQL`
  * Hostname: `postgres_bitbucket`
  * Port: `5432`
  * Database name: `bitbucketdb`
  * Database username: `bitbucketdb`
  * Database password: `jellyfish`
1. Create and enter license information
1. Fill out the rest of the installation procedure.

# Support & Feature Requests

Leave a message and ask questions on Hipchat: [blacklabelops/hipchat](https://www.hipchat.com/geogBFvEM)

# References

* [Atlassian Bitbucket](https://www.atlassian.com/software/bitbucket)
* [Docker Homepage](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Userguide](https://docs.docker.com/userguide/)
* [Oracle Java](https://java.com/de/download/)
