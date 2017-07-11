# Dockerized Atlassian Bitbucket

"Built for professional teams - Distributed version control system that makes it easy for you to collaborate with your team. The only collaborative Git solution that massively scales." - [[Source](https://www.atlassian.com/software/bitbucket)]

## Supported tags and respective Dockerfile links

| Product |Version | Tags  | Dockerfile |
|---------|--------|-------|------------|
| Bitbucket | 5.1.4 | 5.1.4, latest | [Dockerfile](https://github.com/blacklabelops/bitbucket/blob/master/Dockerfile) |

## Related Images

You may also like:

* [blacklabelops/jira](https://github.com/blacklabelops/jira): The #1 software development tool used by agile teams
* [blacklabelops/confluence](https://github.com/blacklabelops/confluence): Create, organize, and discuss work with your team
* [blacklabelops/bitbucket](https://github.com/blacklabelops/bitbucket): Code, Manage, Collaborate
* [blacklabelops/crowd](https://github.com/blacklabelops/crowd): Identity management for web apps

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

Firstly, start the database server for Bitbucket:

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

Thirdly, configure your Bitbucket yourself and fill it with a test license.

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

# SSH Keys

If you need to use SSH Keys to authenticate Bitbucket to other services (eg, replicating to Github), put the entire contents of what you want to have in the .ssh directory in a directory called 'ssh' on your persistant volume.

When the container is started, the contents of `/var/atlassian/bitbucket/ssh` directory will be copied to `/home/bitbucket/.ssh`, and the permissions will be set to 700.

Example:

~~~~
$ docker run -d --name bitbucket \
    -v your-local-ssh-folder-or-volume:/var/atlassian/bitbucket/ssh \
    -e "BITBUCKET_PROXY_NAME=myhost.example.com" \
    -e "BITBUCKET_PROXY_PORT=443" \
    -e "BITBUCKET_PROXY_SCHEME=https" \
    blacklabelops/bitbucket
~~~~

> ssh keys will be copied and are available at runtime.

Alternatively copy the files in your running container and restart the container:

~~~~
# Creating the folder
$ docker exec bitbucket mkdir -p /var/atlassian/bitbucket/ssh
# Copy the keys
$ docker cp your-local-ssh-folder your-container-name:/var/atlassian/bitbucket/ssh
# Restart container
$ docker restart your-container-name
~~~~

# Proxy Configuration

You can specify your proxy host and proxy port with the environment variables BITBUCKET_PROXY_NAME and BITBUCKET_PROXY_PORT. The value will be set inside the Atlassian server.xml at startup!

When you use https then you also have to include the environment variable BITBUCKET_PROXY_SCHEME.

You can also specify the context path with BITBUCKET_CONTEXT_PATH.

Example HTTPS:

* Proxy Name: myhost.example.com
* Proxy Port: 443
* Poxy Protocol Scheme: https

Just type:

~~~~
$ docker run -d --name bitbucket \
    -e "BITBUCKET_PROXY_NAME=myhost.example.com" \
    -e "BITBUCKET_PROXY_PORT=443" \
    -e "BITBUCKET_PROXY_SCHEME=https" \
    blacklabelops/bitbucket
~~~~

> Will set the values inside the bitbucket.properties in /var/atlassian/bitbucket/bitbucket.properties

# NGINX HTTP Proxy

This is an example on running Atlassian Bitbucket behind NGINX with 2 Docker commands!

First start Bitbucket:

~~~~
$ docker run -d --name bitbucket \
    -e "BITBUCKET_CONTEXT_PATH=/bitbucket" \
    -e "BITBUCKET_PROXY_NAME=myhost.example.com" \
    -e "BITBUCKET_PROXY_PORT=80" \
    -e "BITBUCKET_PROXY_SCHEME=http" \
    blacklabelops/bitbucket
~~~~

> Example with dockertools

Then start NGINX:

~~~~
$ docker run -d \
    -p 80:80 \
    --name nginx \
    --link bitbucket:bitbucket \
    -e "SERVER1SERVER_NAME=myhost.example.com" \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/bitbucket" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://bitbucket:7990" \
    -e "SERVER1REVERSE_PROXY_APPLICATION1: bitbucket"
    blacklabelops/nginx
~~~~

> Bitbucket will be available at http://myhost.example.com/bitbucket.

# NGINX HTTPS Proxy

This is an example on running Atlassian Bitbucket behind NGINX-HTTPS with2 Docker commands!

Note: This is a self-signed certificate! Trusted certificates by letsencrypt are supported. Documentation can be found here: [blacklabelops/nginx](https://github.com/blacklabelops/nginx)

First start Bitbucket:

~~~~
$ docker run -d --name bitbucket \
    -e "BITBUCKET_PROXY_NAME=192.168.99.100" \
    -e "BITBUCKET_PROXY_PORT=80" \
    -e "BITBUCKET_PROXY_SCHEME=http" \
    blacklabelops/bitbucket
~~~~

> Example with dockertools

Then start NGINX:

~~~~
$ docker run -d \
    -p 443:443 \
    --name nginx \
    --link bitbucket:bitbucket \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://bitbucket:7990" \
    -e "SERVER1CERTIFICATE_DNAME=/CN=CrustyClown/OU=SpringfieldEntertainment/O=crusty.springfield.com/L=Springfield/C=US" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1HTTP_ENABLED=false" \
    blacklabelops/nginx
~~~~

> Bitbucket will be available at https://192.168.99.100.

# Vagrant

First install:

* [Vagrant](https://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)

Vagrant is fabulous tool for pulling and spinning up virtual machines like docker with containers. I can configure my development and test environment and simply pull it online. And so can you! Install Vagrant and Virtualbox and spin it up. Change into the project folder and build the project on the spot!

~~~~
$ vagrant up
$ vagrant ssh
[vagrant@localhost ~]$ cd /vagrant
[vagrant@localhost ~]$ docker-compose up
~~~~

> Bitbucket will be available on http://localhost:8080 on the host machine.

# Support

Leave a message and ask questions on Hipchat: [blacklabelops/hipchat](https://www.hipchat.com/gEorzhvnI)

# References

* [Atlassian Bitbucket](https://www.atlassian.com/software/bitbucket)
* [Docker Homepage](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Userguide](https://docs.docker.com/userguide/)
* [Oracle Java](https://java.com/de/download/)
