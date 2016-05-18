# Horde

a local dev paas that uses docker, consul, and fabio



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
