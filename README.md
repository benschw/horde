[![Build Status](https://travis-ci.org/benschw/horde.svg?branch=master)](https://travis-ci.org/benschw/horde)
[![Download Latest](https://img.shields.io/badge/download-latest-blue.svg)](http://dl.fligl.io/artifacts/horde/horde_latest.gz)
[![Releases](https://img.shields.io/badge/download-release-blue.svg)](http://dl.fligl.io/#/horde)


# Horde

a local dev paas that uses docker, consul, and fabio


## Getting Started 
make sure you have the dependencies:
* [hostess](https://github.com/cbednarski/hostess) manages horde application host names in your `/etc/hosts` file.
* [docker](https://www.docker.com/) manages your horde containers.


Create a hello world application (or use the [example](https://github.com/benschw/horde/tree/master/example))

	git clone git@github.com:benschw/horde.git
	cd horde/example

Run it
	
	horde up

Test it out

	curl http://foo.horde

Since the container is sharing your project as a volume, you can edit `httpdocs/index.php`
and see your change immediately by refreshing your browser.


You can also see your services in [consul](https://www.consul.io/): [http://consul.horde/ui](http://consul.horde/ui/#/dc1/services)
and the routing details provided by [fabio](https://github.com/eBay/fabio): [http://fabio.horde/routes](http://fabio.horde/routes).

If you are using rabbitmq, it's available at [http://rabbitmq.horde](http://rabbitmq.horde).

## Base Services

## Configuring an application

Create `horde.json` in your project root and define a `driver` and a `name`.
The name will be used to register your service with consul and the health path
used to give consul something to verify your application with.

If you are using the "fliglio" `driver`, you may also include a `db` that will be
created and phynx migrations in the `/migrations` directory will be run.
In addition, your application's container will host the `httpdocs` directory from your project root.

_you must use the mysql credentials: admin / changeme_


`horde.json`

	{
	    "driver": "fliglio",
	    "name": "foo",
	    "db": "foo"
	}


Rabbitmq and Chinchilla are also available for fliglio apps (use the rabbitmq creds: guest/guest)

#### Other notes

to use consul for dns, configure `/etc/default/docker` to use your bridge ip for dns. e.g. with

	DOCKER_OPTS="--dns 172.17.0.1"



Export your docker bridge ip:

	export HORDE_IP='172.17.0.1'


To specify a custom recorsor dns server (other than the default of 8.8.8.8) set the following env variable

	export HORDE_DNS=1.2.3.4


Force the mysql container to publish port 3306 over a specified external port:

	export HORDE_MYSQL_PUBLISH_PORT=3306


