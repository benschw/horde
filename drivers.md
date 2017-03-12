# Drivers

A json config file named `horde.json` should be placed in your project's root directory.
This will drive what a `horde run` command does.

At a bare minimum, this config file should define a `driver` and a `name`. The `driver`
will specify how your application should be run, and the `name` will be used to
register your service with consul and set up a named route to your application
(http://_name_.horde).

In addition there are other properties you can set to
customize how your application runs.


## horde.json

### driver


Add drivers with the naming convention `NAME.driver.sh` to your configured
`$HORDE_PLUGIN_PATH` (defaults to ~/.horde/plugins). They should implement a
single function named like:

	drivers::custom_name() {
		container::call run -d --name custom_name me/custom_image
	}

Driver plugins can be anywhere in the configured plugin path (so checking out the repo
you manage your driver plugin(s) in to this directory would work fine.)

Look at the provided `static_web` driver (`~/.horde/plugins/core/static_web.driver.sh`)
as a model for creating your own opinionated drivers. Notice the helper functions
that help you build up a docker command that integrates well with the `horde` ecosystem.

	
	{
		...
		"driver": "static_web",
		...
	}

#### name

This property is used as your application's container name in docker, its service name
in consul, and by default is used to generate a host name for your app.

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

If your driver doesn't have a default image, or if you ould like to override it, specify
a docker image string here.

	{
		...
		"image": "ubuntu:14.04",
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

#### services

An array of services your application depends on. Other than `consul`, `registrator`, and `fabio`
(and whatever you might have set in `HORDE_SERVICES`), if your application needs any other services
(such as `mysql`) here is the place to specify it

	{
		...
		"services": [
			"mysql",
			"rabbitmq"
		],
		...
	}
