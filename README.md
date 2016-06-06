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

	mkdir httpdocs
	echo "<?php echo 'Hello Horde';" > httpdocs/index.php
	echo '{"driver":"fliglio","name":"foo","health":"/"}' > horde.json

Run it
	
	horde up

Now head on over to [http://foo.horde/](http://foo.horde/) to see your site.
Since the container is sharing your project as a volume, you can edit `index.php`
and see your change immediately by refreshing your browser.


You can also see your services in [consul](https://www.consul.io/): [http://localhost:8500](http://localhost:8500/ui/#/dc1/services)
and the routing details provided by [fabio](https://github.com/eBay/fabio): [http://localhost:9998](http://localhost:9998/routes)

## Base Services

## Configuring an application

Create `horde.json` in your project root and define a `name` and `health` path.
The name will be used to register your service with consul and the health path
used to give consul something to verify your application with.

If you are using the "fliglio" `driver`, you may also include a `db` that will be
created and phynx migrations in the `/migrations` directory will be run.
In addition, your application's container will host the `httpdocs` directory from your project root.



`horde.json`

	{
	    "driver": "fliglio",
	    "name": "foo",
	    "health": "/health",
	    "db": "foo"
	}




#### Other notes

if horde doesn't detect your docker bridge ip correctly, set up an environment variable
declaring it:


	export HORDE_IP='172.17.0.1'


to use consul for dns, configure `/etc/default/docker` to use your bridge ip for dns. e.g. with

	DOCKER_OPTS="--dns 172.17.0.1"


To specify a custom recorsor dns server (other than the default of 8.8.8.8) set the following env variable

	HORDE_DNS=1.2.3.4


