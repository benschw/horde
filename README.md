[![Build Status](https://travis-ci.org/benschw/horde.svg?branch=master)](https://travis-ci.org/benschw/horde)
[![Download Latest](https://img.shields.io/badge/download-latest-blue.svg)](http://dl.fligl.io/artifacts/horde/horde_latest.gz)
[![Releases](https://img.shields.io/badge/download-release-blue.svg)](http://dl.fligl.io/#/horde)


# Horde

`horde` is a local dev paas that uses docker, consul, and fabio to make managing a development platform easy.

The main components of `horde` are [services](services.md) and [drivers](drivers.md):

* [Services](services.md) help to manage shared services like consul, mysql, and rabbitmq.
* [Drivers](drivers.md) provide a way to express the conventions your services follow by providing
  a unified way of running your application services.


## Getting Started 

* [Install Guide](install.md)
* [Services](services.md)
* [Drivers](drivers.md)


### Hello World
	
Create a hello world application (or use the [example](https://github.com/benschw/horde/tree/master/example))

	git clone https://github.com/benschw/horde.git
	cd horde/example

Run it
	
	horde run

Test it out

	curl http://foo.horde


#### What is running?


The base services are `consul`, `registrator`, and `fabio`.
`registrator` watches as you start up new applications and registers them with consul.
`fabio` watches `consul` and sets up routes to your applications.

Once you've run an application with horde, you can see its discovery details
at [http://consul.horde/ui](http://consul.horde/ui/#/dc1/services)
and its routing details at [http://fabio.horde/routes](http://fabio.horde/routes).

