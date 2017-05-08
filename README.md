[![Build Status](https://travis-ci.org/benschw/horde.svg?branch=master)](https://travis-ci.org/benschw/horde)
[![Download Latest](https://img.shields.io/badge/download-latest-blue.svg)](http://dl.fligl.io/artifacts/horde/horde_latest.gz)
[![Releases](https://img.shields.io/badge/download-release-blue.svg)](http://dl.fligl.io/#/horde)


# Horde

`horde` is a local dev paas that uses docker, consul, and fabio to help make
managing a development platform easy.

The main components of `horde` are [service plugins](#service-plugins) and [driver plugins](#driver-plugins):

* [Service Plugins](#service-plugins) help to manage shared services like consul, mysql, and rabbitmq.
* [Driver Plugins](#driver-plugins) provide a way to express the conventions your application services follow 
  and to run them in a consistent and unified way.

## Table of Contents

* [Install Horde](#install-install)
	* [Dependencies](#dependencies)
	* [Install](#install)
		* [Build Horde From Source](#build-horde-from-source)
	* [Configuration](#configuration)
		* [Linux](#linux)
		* [OS X](#os-x)
* [Your First Application](#your-first-application)
* [Service Plugins](#service-plugins)
	* [Core Services](#core-services)
	* [Contrib Services](#contrib-services)
	* [Custom Services](#custom-services)
* [Driver Plugins](#driver-plugins)
	* [horde.json file reference](#hordejson-file-reference)
	* [Custom Drivers](#custom-drivers)


## Install Horde

### Dependencies

* [hostess](https://github.com/cbednarski/hostess) manages horde application host names in your `/etc/hosts` file.
* [docker](https://www.docker.com/) manages your horde containers.
* [jq](https://stedolan.github.io/jq/) to work with json output

### Install

1) Install the `horde` cli tool
<!-- br -->

	wget http://dl.fligl.io/artifacts/horde/horde_latest.gz
	gunzip horde_latest.gz
	chmod +x horde
	mv horde /usr/local/bin

2) Set up your plugins path
<!-- br -->


	mkdir -p ~/.horde/plugins/

3) Get the _core_ plugins
<!-- br -->


	wget http://dl.fligl.io/artifacts/horde/horde-plugins-core_latest.tar.gz
	tar -C ~/.horde/plugins -xvf horde-plugins-core_latest.tar.gz

4) Get the _contrib_ plugins
<!-- br -->


	wget http://dl.fligl.io/artifacts/horde/horde-plugins-contrib_latest.tar.gz
	tar -C ~/.horde/plugins -xvf horde-plugins-contrib_latest.tar.gz


#### Build Horde From Source


	git clone https://github.com/benschw/horde.git
	cd horde
	make build install contrib-install


Continue reading to learn how to configure your environment.


### Configuration

#### Linux

Specify your machine's `docker0` bridge ip with an environment variable

	export HORDE_IP='172.20.20.1'

Configure the docker daemon to use consul for DNS by specifying your machine's
`docker0` ip. Edit the file `/etc/default/docker` and update the value for `DOCKER_OPTS`:

	DOCKER_OPTS="--dns 172.20.20.1"

By default, consul will recurse DNS requests to google (8.8.8.8) but you can specify a
custom recursor dns server by setting the following env variable:

	export HORDE_DNS=1.2.3.4

#### OS X

Specify your machine's `vboxnet0` bridge ip with an environment variable

	export HORDE_IP='172.20.20.1'

This interface is configurable with the `VBoxManage` command. `horde` can take
care of syncing it to your `HORDE_IP` if you set the following environment variable:

	export HORDE_ENSURE_VBOX=true


Configure the docker daemon to use consul for DNS by specifying your  machine's
`vboxnet0` ip. Navigate to the docker settings UI, click on _Daemon_, and
then click on _Advanced_. Specify your machine's ip:

	{
		"dns": [
			"172.20.20.1"
		]
	}
	
By default, consul will recurse DNS requests to google (8.8.8.8) but you can specify a
custom recursor dns server by setting the following env variable:

	export HORDE_DNS=1.2.3.4

## Your First Application
	
Create a hello world application (or use the [example](https://github.com/benschw/horde/tree/master/example))

	git clone https://github.com/benschw/horde.git
	cd horde/example

Run it
	
	horde run

Test it out

	curl http://foo.horde


### What is running?


The base services are `consul`, `registrator`, and `fabio`.
`registrator` watches as you start up new applications and registers them with consul.
`fabio` watches `consul` and sets up routes to your applications.

Once you've run an application with horde, you can see its discovery details
at [http://consul.horde/ui](http://consul.horde/ui/#/dc1/services)
and its routing details at [http://fabio.horde/routes](http://fabio.horde/routes).


## Service Plugins

### Core Services
#### Fabio
[fabio.horde](http://fabio.horde/)

#### Consul

[consul.horde/ui/](http://consul.horde/ui/)

### Contrib Services
#### Mysql
Use login: admin / changeme


Force the mysql container to publish port 3306 over a specific external port (e.g. 3307):

	export HORDE_MYSQL_PUBLISH_PORT=3307

#### Rabbitmq

[rabbitmq.horde](http://rabbitmq.horde)

Use login: guest / guest

#### Chinchilla

#### Splunk

[splunk.horde](http://splunk.horde)

### Custom Services

In addition to the provided _core_ and _contrib_ services, you can add custom services by
creating a shell script (following the naming convention: `NAME.service.sh`) in
your configured `HORDE_PLUGIN_PATH` (defaults to ~/.horde/plugins). Each service
should implement a single function named like:

	services::custom_name() {
		container::call run -d --name custom_name my/custom_image
	}

Service plugins can be anywhere in the configured plugin path (so cloning the repo
in which you manage your plugin(s) into this directory would work fine.)

Look at the provided services (`~/.horde/plugins/core/common.service.sh`)
as a model for creating your. Notice the helper functions that help you build up a
docker command that integrates well with the `horde` ecosystem.


## Driver Plugins

A json config file named `horde.json` should be placed in each application service
project's root directory. This will configure `horde` when run from the project's
root.

At a bare minimum, this config file should define a `driver` and a `name`. The `driver`
will specify how your application should be run, and the `name` will be used to
register your service with consul and set up a named route to your application
(http://_name_.horde).

In addition to these, there are other properties you can set in order to
customize how your application runs.


### horde.json File Reference

#### driver


Specify your driver in the `horde.json` config. Horde comes with a `static_web` driver included,
but you can add your own with [custom plugin drivers](#custom-drivers).

	{
		...
		"driver": "static_web",
		...
	}

#### name

This property is used as your application's container name in docker, its service name
in consul, and by default is used to generate a host name for your app (http://_name_.horde).

	{
		...
		"name": "foo",
		...
	}

#### host

This field overrides the convention based host name generated using the `name` field.

	{
		...
		"host": "foo.tld",
		...
	}

#### env_file

path to a file containing environment variables you would like injected into your container.


	{
		...
		"env_file": "./env-vars",
		...
	}

#### image

If your driver doesn't have a default image, or if you would like to override it, specify
a docker image string here.

	{
		...
		"image": "ubuntu:14.04",
		...
	}

#### services

An array of services your application depends on. Other than `consul`, `registrator`, and `fabio`
(and whatever you might have set in `HORDE_SERVICES`), if your application needs any other services
(such as `mysql`) here is the place to specify them.

These services will also be linked to your application service.

	{
		...
		"services": [
			"mysql",
			"rabbitmq"
		],
		...
	}

#### hosts

An array of host name aliases. These names will be configured in addition to either the 
default http://_name_.horde or http://_host_.

	{
		...
		"hosts": [
			"foo.tld",
			"bar.tld"
		],
		...
	}



### Custom Drivers

In addition to the provided `static_web` driver, you can add custom drivers by
creating a shell script (following the naming convention: `NAME.driver.sh`) in
your configured `HORDE_PLUGIN_PATH` (defaults to ~/.horde/plugins). Each driver
should implement a single function named like:

	drivers::custom_name() {
		container::call run -d --name custom_name my/custom_image
	}

Driver plugins can be anywhere in the configured plugin path (so cloning the repo
in which you manage your plugin(s) into this directory would work fine.)

Look at the provided `static_web` driver (`~/.horde/plugins/core/static_web.driver.sh`)
as a model for creating your own opinionated drivers. Notice the helper functions
that help you build up a docker command that integrates well with the `horde` ecosystem.


