
## Install

Build and install horde from source

	git clone https://github.com/benschw/horde.git
	cd horde
	make build install
	
And if your want to install the _contrib_ plugins:

	make contrib-install


Now you have the cli tool installed. Continue on this page to make sure your system
is configured and you have the necessary dependencies.

## Dependencies

* [hostess](https://github.com/cbednarski/hostess) manages horde application host names in your `/etc/hosts` file.
* [docker](https://www.docker.com/) manages your horde containers.
* [jq](https://stedolan.github.io/jq/) to work with json output


## Configuration

### Linux

Specify your machine's `docker0` bridge ip with an environment variable

	export HORDE_IP='172.20.20.1'

Configure the docker daemon to use consul for DNS by specifying your machine's
`docker0` ip. Edit the file `/etc/default/docker` and update the value for `DOCKER_OPTS`:

	DOCKER_OPTS="--dns 172.20.20.1"

By default, consul will recurse DNS requests to google (8.8.8.8) but you can specify a
custom recursor dns server by setting the following env variable:

	export HORDE_DNS=1.2.3.4

### OS X

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
