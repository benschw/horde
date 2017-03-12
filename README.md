[![Build Status](https://travis-ci.org/benschw/horde.svg?branch=master)](https://travis-ci.org/benschw/horde)
[![Download Latest](https://img.shields.io/badge/download-latest-blue.svg)](http://dl.fligl.io/artifacts/horde/horde_latest.gz)
[![Releases](https://img.shields.io/badge/download-release-blue.svg)](http://dl.fligl.io/#/horde)


# Horde

a local dev paas that uses docker, consul, and fabio


## Getting Started 

### Get Dependencies

* [hostess](https://github.com/cbednarski/hostess) manages horde application host names in your `/etc/hosts` file.
* [docker](https://www.docker.com/) manages your horde containers.
* [jq](https://stedolan.github.io/jq/) to work with json output


### Configure Docker

Configure `/etc/default/docker` to use consul for DNS by specifying your bridge ip. e.g. with

	DOCKER_OPTS="--dns 172.17.0.1"

### Configure Horde

Specify your bridge ip with an environment variable

	export HORDE_IP='172.17.0.1'

Specify a custom recursor dns server (other than the default of 8.8.8.8) by setting the following env variable

	export HORDE_DNS=1.2.3.4


In addition to consul, registrator, and fabio, you can configure additional services to always start up

	export HORDE_SERVICES=splunk,rabbitmq

In order to echo out the various `docker` commands being run (useful while developing plugins), enable debug mode:

	HORDE_DEBUG=true horde up


### Hello World
	
Create a hello world application (or use the [example](https://github.com/benschw/horde/tree/master/example))

	git clone git@github.com:benschw/horde.git
	cd horde/example

Run it
	
	horde up

Test it out

	curl http://foo.horde


#### What is running?

`horde up` starts up a set of containers that provide an  ecosystem to run your
application in, and then runs your application in this ecosystem (bundled in a
Docker container or its own). Subsequent `horde up` runs on different
applications will install those applications into this same ecosystem.

The base services are `consul`, `registrator`, and `fabio`.D `registrator`
(todo: explain the ecosuystem here)
You can also see your services in [consul](https://www.consul.io/): [http://consul.horde/ui](http://consul.horde/ui/#/dc1/services)
and the routing details provided by [fabio](https://github.com/eBay/fabio): [http://fabio.horde/routes](http://fabio.horde/routes).


## Base Services

### Fabio
[fabio.horde](http://fabio.horde/)

### Consul

[consul.horde/ui/](http://consul.horde/ui/)

### Mysql
Use login: admin / changeme


Force the mysql container to publish port 3306 over a specific external port:

	export HORDE_MYSQL_PUBLISH_PORT=3306

### Rabbitmq

[rabbitmq.horde](http://rabbitmq.horde)

use login: guest / guest

### Chinchilla

## Drivers

Create `horde.json` in your project root and define a `driver` and a `name`.
The name will be used to register your service with consul and the health path
used to give consul something to verify your application with.

### Custom Drivers

add drivers with the naming convention `NAME.driver.sh` to your configured
`$HORDE_DRIVER_PATH` (defaults to ~/.horde/drivers).

Driver plugins can be anywhere in this directory (so checking out the repo
you manage your driver plugin(s) in to this directory would work.)


### Fliglio
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
### Springboot

