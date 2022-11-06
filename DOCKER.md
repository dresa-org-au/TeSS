# TeSS: Docker Installation

This page details how to deploy TeSS using Docker. 
To use an alternative deployment method see the [manual installation](./README.md#manual-installation) section.

## Install Docker
First, make sure Docker has been installed on the machine. Verify that the following commands run successfully:

```shell
docker version
docker compose version
```

If these fail, see the [Get Docker](https://docs.docker.com/get-docker/) website for instruction to install on your environment.

## Source code
The source code for TeSS can be cloned using the following command;

```shell
git clone https://github.com/dresa-org-au/TeSS.git
```

The rest of this document assumes that the repository was cloned successfully and that you have changed into the *TeSS* 
directory, as follows;

```shell
cd TeSS
```

The following sections will describe the images, configuration and docker commands required to run a development server.

## Images
These instructions have been tested with the following images;

  - walroz/dresa:1.4.3
  - walroz/nginx:1.4.3
  - solr:8
  - redis:6
  - postgres:14.2
  - ruby:2.7.2
  - ubuntu:20/04

### Rebuild images
If changes are made to the source code or configuration files, the dresa and nginx images can be rebuilt using the 
following commands:

```shell
  sh docker-rebuild.sh walroz/dresa:<version number> Dockerfile
  sh docker-rebuild.sh walroz/nginx:<version number> Dockerfile-nginx
```

## Configuration

The following six files need to be copied to configure TeSS:

```shell
  cp config/ingestion.example.yml config/ingestion.yml
  cp config/schedule.example.yml config/schedule.yml
  cp config/secrets.example.yml config/secrets.yml
  cp config/sunspot.example.yml config/sunspot.yml
  cp config/tess.example.yml config/tess.yml
  cp env.sample .env
```

For a minimum build only the *TeSS* and *Environment* files need to be updated.

### File: *<span style="color:SandyBrown">config/tess.yml</span>*
1. Set the *base_url* parameter; change from http://localhost:3000 to the appropriate URL or IP address.

2. Add a reference for the *dresa* parameters to the *development* and *production* 
environments, e.g. for the development environment:

```yaml
development:
  <<: *default
  <<: *dresa
```

### File: *<span style="color:SandyBrown">.env</span>*
Update the following parameters:
1. Docker build values: 
   *<span style="color:orange">PREFIX</span>*, 
   *<span style="color:orange">REPOSITORY</span>*, and 
   *<span style="color:orange">IMAGE_VERSION</span>* (if required)
2. *<span style="color:orange">DB_PASSWORD</span>* should be set to a new value
3. *<span style="color:orange">ADMIN_PASSWORD</span>* should be set to a new value
4. *<span style="color:orange">SECRET_KEY_BASE</span>* should be changed to a newly value, which can be 
   generated using the following command: `rake secret`
5. *<span style="color:orange">URL</span>* and *<span style="color:orange">IP_ADDR</span>* should be set to the 
    IP Address of the development machine.
6. *<span style="color:orange">SSL_CERT_FILE</span>* and *<span style="color:orange">SSL_KEY_FILE</span>*:
    <span style="color:olive">TBA</span>

<!--6. *SSL_CERT_FILE* and *SSL_KEY_FILE* should be updated to the SSL file names, which should be copied into the following
    directory: *tba*-->

## Compose
Use the following command to start and stop the server:

  - Start:  `docker compose up -d`
  - Stop:   `docker compose down --remove-orphans`
  - Status: `docker compose ps -a`

## Verifying the server
The container logs can be checked using the following command:
```shell
docker logs dresa-app
```

# Deploying a Production Server
<span style="color:olive">TBA</span>


<!-- end of file -->