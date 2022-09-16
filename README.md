# Soda Debug Docker images

Please note: this is (and will most likely remain) a work in progress.

This is a Docker image based on Ubuntu 22.04 (Jammy) and intended for troubleshooting pods and container deployments at Soda.

Two tags will be available through Docker Hub:

- sodadata/soda-debug:slim
- sodadata/soda-debug:full

latest should point to the slim one.

Builds are created for amd64 only.

## Build

Manual build:

```
docker buildx build --platform=linux/amd64 --no-cache \
 -f ./Dockerfile -t sodadata/soda-debug:slim .
```

Or for additional AWS, Azure and Google Cloud CLI tools: 

```
docker buildx build --platform=linux/amd64 --build-arg BUILD_TYPE=FULL --no-cache \
 -f ./Dockerfile-v3.10 -t sodadata/soda-debug:full .
```

## Usage

Some examples:

### By running a Bash session

Start the pod:

```
> kubectl run soda-debug -it --image=sodadata/soda-debug -n soda-agent -- bash
```

Now you can run commands like:

*Ping an address and see if it resolves*

```
> root@soda-debug:/app# ping some-service
PING some-service.soda-agent.svc.cluster.local (1.2.3.4) 56(84) bytes of data.
```

*See if Soda Cloud is accessible*

```
> root@soda-debug:/app# curl https://cloud.soda.io
````

*Execute a Soda scan*

Execute a Soda scan gainst a warehouse (you need a config for the warehouse and checks to to that, see ...), for example like: 

```
> root@soda-debug:/app# soda

Usage: soda [OPTIONS] COMMAND [ARGS]...

  Soda Core CLI version 3.0.7

Options:
  --version  Show the version and exit.
  --help     Show this message and exit.

Commands:
  ingest      Ingest test information from different tools
  scan        runs a scan
  update-dro  updates a DRO in the distribution reference file
```



*Copy a local file to the running pod*

From your machine, you can copy your config file onto the running container (pod) and execute an actual scan.

```
kubectl cp ~/yourlocation/scandefinition.zip soda-debug:/app -n soda-agent
```

Now you can run the scan from the Bash session in the running soda-debug container. To be executed in the pod, for example:

```
> root@soda-debug:/app# unzip scandefinition.zip
> root@soda-debug:/app# soda scan -d warehouse_name  -c configuration.yml checks.yml
```

*Soda packages*

Check which Soda packages are installed on the debug image (check if your warehouse is supported): 

```
> root@soda-debug:/app# pip list | grep -i soda
soda-core                              3.0.7
soda-core-athena                       3.0.7
soda-core-bigquery                     3.0.7
soda-core-db2                          3.0.7
soda-core-mysql                        3.0.7
soda-core-postgres                     3.0.7
soda-core-redshift                     3.0.7
soda-core-scientific                   3.0.7
soda-core-snowflake                    3.0.7
soda-core-sqlserver                    3.0.7
soda-core-trino                        3.0.7
```

*Delete the running pod*

```
> kubectl delete pod soda-debug -n soda-agent
```

### Issuing one time commands

Instead of launching a pod and running commands in a shell or against the running pod, you can also issue one off commands (the `--rm` flag lets Kubernetes remove up the pod once it finishes).


Examples:

```
> kubectl run soda-debug -it --rm --image=sodadata/soda-debug -n soda-agent -- pip list | grep -i soda
```

```
> kubectl run soda-debug -it --rm --image=sodadata/soda-debug -n soda-agent -- curl https://cloud.soda.io
```

```
> kubectl run soda-debug -it --rm --image=sodadata/soda-debug -n soda-agent -- ping some-service
```
(you need to hit CTRL-C for that last one to show up a result)


## Provided Cloud CLI's

You need to use the full image for this:

> sodadata/soda-debug:full


### AWS 

Run

```
aws configure
```

See https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html



### Azure

Run

```
read -sp "Azure password: " AZ_PASS && echo && az login -u <username> -p $AZ_PASS
```

See https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli for alternatives.

### GCP

Run

```
gcloud init
```

See https://cloud.google.com/sdk/gcloud/reference/auth/login



## Todo

- [ ] create pipeline to build and push to Docker Hub