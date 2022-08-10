<center> <h1>Docker</h1> </center>

Docker is a tool used to automate the deployment of an application as a lightweight container so that the application can work efficiently in different environments.

Virtual machines have a host operating system and a guest operating system inside each VM. The guest OS can be any OS, such as Linux or Windows, irrespective of the host OS. In contrast, Docker containers are hosted on a single physical server with the host OS shared among them. Sharing the host OS between containers makes them light and decreases the boot time. Docker containers are considered suitable to run multiple applications over a single OS kernel; whereas, virtual machines are needed if the applications or services are required to run on different OS.

![Containers vs Virtual Machines](./images/containers-vs-virtual-machines.png?raw=true "Containers vs Virtual Machines")
<p align = "center"> Containers vs Virtual Machines </p>

## Docker Architecture

Docker architecture:

* `Client-server architecture`: In Docker, the docker daemon (server) and docker client are separate binaries and the client could be used to communicate with different daemons.
* `The client talks to the Docker daemon`
* `The Docker daemon handles` all the heavy liftings as follows for the docker containers
  * Building
  * Running
  * Distributing
* Both the daemon and clients communicate using a `REST API`. This can be done using the following ways. When we execute a command using a docker client, it communicates with the API which receives the request and then tells the docker daemon to execute the action
  * Unix sockets
  * Network interface
* The Docker daemon (`dockerd`) is the persistent process that manages containers. The Docker daemon listens for the Docker API requests and manages Docker objects. Few of these objects are shown as follows:
  * Images
  * Containers
  * Networks
  * Volumes
* The docker client (`docker`) is what we use to interact with the docker daemon (`dockerd`) through the REST API. The client sends these command to `dockerd`. From the CLI we use `docker` as a command for executing the commands. For example, when we use the command `docker run ...` it sends the command to the daemon to run an image.
* Docker registry is the place where we `store the images`. A docker registry is similar to a Github repository. In the docker registry we store images and in Github repository we store codes. By default Docker uses the Docker hub (public registry where we can save our own images as well as down other images created by other people or companies). We can also setup Docker to use the private registry as well, in this case we need to configure the Docker to communicate with the private registry. We interact with the docker registry by using `docker push` or `docker pull` command.

> Basically, `Docker registry` is a service that is used to store the docker images. Docker registry could be hosted by a third party, as public or private registry, f.e. Docker Hub, Quay, etc. On the other hand, `Docker repository` is a collection of different docker images with same name, that have different tags. Tag is alphanumeric identifier of the image within a repository.

![Docker Architecture](./images/docker-architecture.png?raw=true "Docker Architecture")
<p align = "center"> Docker Architecture </p>

The Docker client communicates with the Docker daemon using the API. When we go and create a container (f.e. using `docker run ...`), that container is going to be based of an image. If that image does not exist on the Docker server (i.e. the local host machine), it will go and communicate with the Docker registry (by default Docker hub unless configured to use the private registry) and pulls down that image from the registry. Once the image has been pulled down to the server, it's then creates the container based on this image. We use the `docker pull [IMAGE NAME]` command to pull an image and `docker push [IMAGE NAME]` to push an image to and from the Docker registry.

Most important Docker objects

* Images
  * An image is a read-only template with a set of instructions for creating a Docker container
  * This instructions can be used to set a base image
  * An image (tailored image for our own usecases) is always based on another image (also known as base image)
  * Use a `Dockerfile` to build an image. This `Dockerfile` has all the instructions on how an image should be built
* Containers
  * Runnable instance of an image that it was created from
  * Using Docker API/CLI, we can create, stop, start, move, or delete containers
  * We can create a network and attach multiple containers to it. Also, a container can be attached to mulitple networks
  * Create a persistent storage and attach it to the container hence the important data is not lost even after container deletion
  * Create a new image based on its current state (i.e. running container)
  * Containers are isolated from other containers and the host machine
* Services
  * Allows us to go and scale containers across multiple Docker daemons across multiple Docker hosts
  * We can have multiple docker hosts working together by enabling `Docker Swarm` and each member of the swarm is its own docker daemon and all these docker hosts will be able to communicate with one another using the Docker API
    * Two types of nodes in the `Docker Swarm`
      * Managers/Masters: Responsible for the mangement of the cluster
      * Workers: Responsible for executing tasks
  * Allows us to define a desired state, f.e. if want to have 3 replicas and 1 dies off then the service will create a new replacement replica to bring up the desired state (of 3 replicas)
  * Load-balance replicas across all the worker nodes that are in the cluster

`Docker Swarm` is multiple Docker daemons working together. There are two types of nodes
  * Managers/Masters: Responsible for the mangement of the cluster
  * Workers: Responsible for executing tasks

All of the docker daemons communicates with each other using Docker API. `Docker Swarm` is supported from Docker 1.12 or higher.

## Docker Engine

`Docker Engine` is the heart of the Docker which creates and runs the Docker containers. Docker engine is the layer on which the Docker runs. It is installed on the host machine.

* It is modular in design, that is often described as `batteries included` but `replaceable` hence giving the user ability to swap out components whenever needed
* Most of the engine is based on an open-standards outline by the `Open Container Initiative (OCI)`

Major component of the Docker engine are as follows. All these components work together to create and run containers.

* `Docker client` or CLI: It is a client that is used to enter docker commands.
* Docker `daemon` or Server: It is the docker daemon called `dockerd`. It can create and manage docker images, i.e, Containers, networks.
* `containerd`: Responsible for managing lifecycle of the container. It sits between the Docker daemon and the `runc` at the OCI layer. Also responsible for the management of the images (i.e. push and pull the images)
  * Start
  * Stop
  * Pause
  * Delete
* `runc`: Implementation of the OCI container-runtime-spec. It is a lightweight CLI wrapper for `libcontainer` and it's sole purpose is to create and run containers.
* Rest API: It is used to instruct docker daemon what to do.

![Docker Engine](./images/docker-engine.png?raw=true "Docker Engine")
<p align = "center"> Docker Engine </p>

> Earlier Docker used to use `LXC` for the capabilities, namespaces, cgroups, and dealing with the host kernel. Later the `LXC` was replaced by `libcontainer` (platform agnostic) since `LXC` (only Linux specific) was external tool and it's core to the Docker also since it only works with Linux (hence no Windows or /MacOS support)\

`Shims` is used to decouple running containers from the daemon (so allows for `daemon-less containers`). When new container is created `containerd` forks an instance of `runc` for each new container. Once the container is created, the `runc` process exits and the `shim` process becomes the new parent of the container. This allows us to run hundreds of containers without running hundreds of `runc` instances. It is responsible for keeping STDIN and STDOUT streams open. This means if the daemon is restarted, the container doesn't go and terminate due to the closed pipes. It is also responsible for reporting the exit status of a container to the Docker daemon.

### Running Containers

`docker container run -it --name [NAME] [IMAGE NAME]:[TAG]`

Creating containers steps

* Use the Docker client (CLI) to execute a command - `docker container run ...`
* Docker client then uses the appropriate API payload and POSTs to the correct API endpoint to communicate with the Docker daemon
* The Docker daemon receives instructions and calls the `containerd` to start a new container. It uses `gRPC` (a CRUD styled API)
* The `containerd` creates an OCI bundle from the docker image
* Then `containerd` communicates with `runc` to create a container using that OCI bundle
* The `runc` interfaces with the OS Kernel to get the constructs needed to create a container. This includes namespaces, cgroups, capabilites, etc.
* The `runc` then start the container process as a child process
* Once the container comes online then `runc` will exit and `shims` become the new parent process
* At this point the process is complete and the container is now running

![Docker Container Running Process](./images/docker-running-containers-process.png?raw=true "Docker Container Running Process")
<p align = "center"> Docker Container Running Process </p>

More read:

* https://mohitgoyal.co/2021/04/03/going-down-the-rabbit-hole-of-docker-engine/
* https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker/
* https://alexander.holbreich.org/docker-components-explained/ 

## Docker Images and Containers

* Docker image is a template for the containers. We use image to create an instance of a container
* Images are made up of multiple layers, where each one being stacked on top of the next and this as a whole represents a single object.
* `Image is considered to be built-time` contructs while `containers are the run-time` contructs
* When we create a container from an image, these two becomes dependent on one another (i.e. we can't delete the image without all the containers built from this image have been deleted first)
* An image is built from a `Dockerfile`. This file contains a set of instructions. This is going to include all of the binaries, as well as libraries to run the application. For example, if we have a Node.JS application, we want to make sure that we have the Node.JS binary.
* Containers are meant to be light-weight, hence we need to make sure that the images are as small as possible and only installing things which are necessary for the application.

`Docker images are made up of multiple layers` where each layer in the image represents a single instruction (or command) in the `Dockerfile`. `All the layers in the image are read-only`. Each layer is only a set of differences from the layer that came before it. When a `container is created, it adds a new writable layer on top` of all the other underlying layers and this layer is often referred to as the `container layer`. Any time a change is made to the container, it is written to this container layer.

> All Docker image starts with a base image and each instruction adds a new layer on top of this base image.

![Docker Images and Layers](./images/docker-images-layers.png?raw=true "Docker Images and Layers")
<p align = "center"> Docker Images and Layers </p>

A container is a run-time instance of the image.

> The major difference between a container and an image is the top `writable layer`.

All writes to the container that add new or modify existing data are stored in this writable layer. For example, if we log into the container and install Vim, the change is made to the container layer. When the container is deleted, the writable layer is also deleted. The underlying image remains unchanged.

![Docker Containers and Layers](./images/docker-containers-layers.png?raw=true "Docker Containers and Layers")
<p align = "center"> Docker Containers and Layers </p>

## Docker Basics

In Docker, we want to make sure that, when we execute a command, that we are not running it as a service. For example, usually `nginx` runs as a service but the service is turned off in the docker image

```sh

...
...
CMD ["nginx", "-g", "daemon off;"]
```

* `--name`: To name a container
* `--detach or -d`: To detach a container
* `--publish or -p`: To publish a container port
* `--publish-all or -P`: To publish all the exposed ports in the container

#### Exposing and publish container port

Exposing a port means to make the port available to map to the host port. `--expose [PORT]` only exposes a container port but doesn't do anything with the mapping to the host. The option `--publish [HOST PORT]:[CONTAINER PORT]` exposes and maps the application running in the container to the host port. Start the `nginx` application running in the container with port 80 and map to the host machine in the port 8081.

```sh
docker run --name my-nginx --publish 8081:80 --detach nginx
```

Output is as follows

```sh
ba77b00f635a   nginx     "/docker-entrypoint.…"   7 minutes ago   Up 7 minutes   0.0.0.0:8081->80/tcp, :::8081->80/tcp                                          my-nginx
```

We can then use `curl localhost:8081` to access the nginx page in our host machine.

If we need to expose multiple ports then we can use `--publish` option multiple times. Below command publishes both the `tcp` port and the `udp` port in the `nginx` container. Note to use `/tcp` or `/udp` for the TCP or UDP type. Default is TCP and it doesn't need to be mentioned explicitly.

```sh
docker run --name my-nginx2 --publish 8082:80/tcp --publish 8082:80/udp --detach nginx
```

Output is as follows

```sh
b5ac4774debf   nginx     "/docker-entrypoint.…"   3 seconds ago   Up 2 seconds   0.0.0.0:8082->80/tcp, 0.0.0.0:8082->80/udp, :::8082->80/tcp, :::8082->80/udp   my-nginx2
```

#### Executing commands in the container

Three ways to do

* Defining `CMD` within a Dockerfile which will be executed when the container starts up
* Using the `docker container run [IMAGE] [COMMAND]`
* Using the `docker container exec -it [CONTAINER ID or NAME] [COMMAND]`

#### Docker logging

How to retrieve log from the container and also how to send the application log data to the container logs?

Create a docker container as follows using the image `linuxacademycontent/weather-app`

```sh
docker container run --name weather-app -d -p 80:3000 linuxacademycontent/weather-app
```

`docker container logs [CONTAINER ID or NAME]` shows information logged by a container that is `not running as a service`. To retreive logs for a service, we need to run `docker service logs [SERVICE ID or NAME]`

```sh
docker container logs weather-app
> Listening on port 3000
```

Go to the application using `localhost:80` and then search for some city then try to see the logs using `docker container logs weather-app`. We will see several informations are logged.

Follow [The Twelve Factor App](https://12factor.net/) methodology for building SAAS apps. For Logging, the logs need to be output to `STDOUT` and `STDERR`.

## Docker Networking

There are 3 major components that consists of networking

1. Container Network Model (`CNM`): It is a design specification and it outlines the fundamental building blocks of a Docker network

2. `libnetwork`: This is the real-world implementation of the CNM and this is the implementaiton Docker uses for connecting the containers. Libnetwork is also responsible for
   1. Service discovery
   2. Ingress-based container load balancing
   3. The network and management control plane functionality

3. `Network drivers`: Libnetwork uses a `system of drivers`. The `drivers` extend the model by implementing specific network topologies. Below are the network topologies:

   1. `bridge`: This is the `default network driver`. If we don’t specify a driver, this is the type of network that is created when we create a container. A bridge network is a link layer device, which forwards traffic between network segments. The bridge driver in the Docker uses a software bridge, which `allows containers connected to the same bridge network to be able to communicate`. It also `provides a layer of isolation` from other containers that are not connected to that network. Also, this driver `only works on Linux`. If we want to create a distributed network among multiple Docker hosts, we need to use the `overlay` network driver.
      1. Usecase: Bridge networks are best when we need multiple containers to communicate on the same Docker host
   2. `host`: For standalone containers, the `host network` removes the network isolation between the containers and the Docker host, and use the host’s networking directly.
      1. Usecase: Host networks are best when the network stack should not be isolated from the Docker host, but we want other aspects of the container to be isolated.
   3. `overlay`: Overlay network `connects multiple Docker daemons together` and enable swarm services to communicate with each other. we can also use overlay network to `facilitate communication between a swarm service and a standalone container`, or `between two standalone containers on different Docker daemons`.
      1. Usecase: Overlay networks are best when we need containers running on different Docker hosts to communicate, or when multiple applications work together using swarm services.
   4. `macvlan`: Macvlan network allows us to assign a MAC address to a container, making it appear as a physical device on our network. The Docker daemon routes traffic to containers by their MAC addresses.
      1. Usecase: Sometimes when we have legacy applications or if we have a application that monitors networking traffic, and those applications are expected to be physically connected to a network.
   5. `none`: Disables all networking in the container. Normally, we will use this driver in conjunction with a customer network driver. The network driver `none` is not available for the swarm services.
   6. `Network plugins`: We can install and use third-party network plugins with Docker. These plugins are available from Docker Hub or from third-party vendors.

We know that the CNM defines the fundamental building blocks of a Docker network. There are 3 building blocks, namely

1. `Sandbox`: The `sandbox` isolates the network stack. This includes the networking interfaces, ports, route tables, and DNS. Due to the isolation, there are no inbound network connection to the sandboxed container. However, it is very unlikely that a container will be of any value in a system if absolutely there is no communication with it is possible. To work around this, we have second element named, `endpoint`.
2. `Endpoints`: The `endpoints` are the virtual network interfaces. It's main responsibility is to connect the sandbox to the `network`. It is a controlled gateway from the outside world into the network's sandbox that shields the container.
3. `Network`: The `network` is the pathway that transports the data packets of an instance of communication from endpoint to endpoint, or ultimately from container to container. A network sandbox can have zero to many endpoints.

![Docker Networking](./images/docker-networking.png?raw=true "Docker Networking")
<p align = "center"> Docker Networking </p>

This diagram above illustrates how these CNM components relates to the containers. If we look inside both container A and B, we can see that we have the `sandbox` component. And this is what provides networking connectivity for our containers.

Container A has a single `endpoint` and this endpoint is connecting to network A. On container B, we have 2 endpoints, one connected to network A, and the second connected to network B. Because both container A and B are connected to network A, this allows both containers to be able to communicate with each other. However, in container B, both endpoints are not able to communicate with one another, unless there is a layer 3 router involved. Since `endpoints` behave like real-world network adapters, they `can only be connected to a single network`, which is the reason why container B requires 2 endpoints to be connected to both network A and B. Even though both container A and B are running on the same Docker host, their network stacks are completely isolated from one another.

More read:

* https://docs.docker.com/network/

#### Executing networking commands in the container

List Docker Networks

```sh
docker network ls

NETWORK ID     NAME      DRIVER    SCOPE
ade02b76829f   bridge    bridge    local
39d589cb0253   host      host      local
7bb43513b65c   none      null      local
```

Getting detailed information on a network

```sh
docker network inspect [NETWORK NAME]
```

Create a network

```sh
docker network create [NETWORK NAME]
```

Delete a network

```sh
docker network rm [NETWORK NAME]
```

Remove all unused networks (bit risky to use)

```sh
docker network prune
```

Adding a container to a network

```sh
docker network connect [NETWORK NAME] [CONTAINER ID or NAME]
```

Removing a container from a network

```sh
docker network disconnect [NETWORK NAME] [CONTAINER ID or NAME]
```

Create a network with a subnet (it will private IP ranges -- 10.x.x.x or 192.x.x.x or 172.x.x.x and not public IP ranges) and gateway

```sh
docker network create --subnet [SUBNET] --gateway [GATEWAY] [NETWORK NAME]
(eg) docker network create --subnet 10.1.0.0/24 --gateway 10.1.0.1 br02

docker container run -d -p 8081:80 --name nginx-network-test01 nginx
docker container connect br02 nginx-network-test01
```

Create a network with a subnet and gateway and a subet of IP's within the range

```sh
docker network create --subnet [SUBNET] --gateway [GATEWAY] --ip-range=[IP RANGE] --driver=[DRIVER NAME] [NETWORK NAME]
(eg) docker network create --subnet 10.1.0.0/16 --gateway 10.1.0.1 --ip-range=10.1.4.0/24 --driver=bridge --label=host4network br03

docker container run --name network-test01 -it --network br03 centos /bin/bash
```

> There are 3 files that are mounted into the container that Docker manages for us. These are `/etc/hostname`, `/etc/host`, and `/etc/resolv.conf`

Assign a specific IP to the container

```sh
# after creating the network with IP range 
docker container run -d --name network-test02 --ip 10.1.4.102 --network br03 nginx
docker container inspect network-test02 | grep -i ipaddr
```

Create an `internal` network (i.e. restricts external access to the network) and the name is localhost. Create a MySQL container and attach to localhost network. Create another container Centos and attach to default bridge network and also attach this container to the localhost network as well 

```sh
docker network create --driver bridge --internal localhost
docker container run --detach --name test_mysql --env MYSQL_ROOT_PASSWORD=password --network localhost mysql:5.7

docker container run -it --name ping-mysql --network bridge centos # make sure to exit after connecting to the container
docker network connect localhost ping-mysql # attach to the localhost container
docker container start --interactive --attach ping-mysql # start and attach to the container  
> ping test_msql # pinging to the test_mysql container
```

## Docker Storage

Categories of data storage:

* Non-persistent
  * Data that is ephemeral, for example the application code data which is tied to the container, it's not requried to store the application code data and it's fine to get deleted during the container deletion.
  * Every container has non-persistent storage, and this storage gets created with the container, which is the read-write layer.
  * Non-persistent data is tied to the container lifecycle, so when the container is deleted, non-persistent data gets deleted too.
* Persistent
  * Persistent data is the data that is not ephemeral, this is achieved by using `volumes`.
  * `Volumes` data lives outside of the lifecycle of the container (decoupled from the containers), for example if the application data (which ephemeral) talks to the database, we want to the database data to be persisted.

> Note: On Linux systems, storage can be found under `/var/lib/docker/[STORAGE-DRIVER]/`. For example, let's say we are using the `overlay2` storage driver then the location would be `/var/lib/docker/overlay2/`. The version of the OS determines what `storage driver` is going to be used by default. `RHEL` systems uses `overlay2`, `Ubuntu` can use `overlay2` or `aufs`.

By default all files created inside a container are `stored on a writable container layer`. This means that:

1. The `data doesn't persist when that container no longer exists`, and it can be difficult to get the data out of the container if another process needs it.
2. A container's `writable layer is tightly coupled to the host machine` where the container is running. It's `not easy to move the data` somewhere else.
3. Writing into a container's writable layer requires a storage driver to manage the filesystem. The storage driver provides a `union filesystem`, using the Linux kernel. This extra abstraction `reduces performance` as compared to using **data volumes, which write directly to the host filesystem**.

Docker has two options for containers to store persistent data on the host machine (hence the data are persisted even after the container stops):

1. `volumes`
2. `bind mounts`

`Volumes` are the preferred method when it comes to maintaining persistent data in Docker. `Volumes` usecases are as follows 

* `Volumes` are more easier to back up, as well as migrate. We can manage volumes using the Docker CLI, or the API.
* `Volumes` work on both Linux and Windows.
* We can more safely share a volume with multiple containers.
* Certain drivers allows us to create volumes on a remote system or in the cloud, for example, REX-Ray driver
* When we can create a volume and we mount it to a directory that has files pre-existing, those files will get pre-populated into the volume.

More read:

* https://docs.docker.com/storage/

#### Volumes

Volumes are created and managed by the Docker. We can create a volume explicitly using the `docker volume create` command, or Docker can create a volume during container or service creation.

* First create the volume
* Then create the container, and then the volume is mounted inside of it (this is done by `mounting the volume to a directory`)

Any changes that are made from within that directory is going to be made on that volume. For example, if we create a file, it's written to that volume. If we make a change to that file, it will be written to it as well. And if we delete the file from that directory, it's also removed from the volume. `Volumes live outside of the lifecycle of containers`, hence allowing us to safely delete a container without worrying about our data being impacted. Volumes are first-class citizens in Docker. This means they have their own APIs, as well as their own subcommand.

The `local driver is used by default`. This means that when we create a volume, it's created locally on the Docker server.

Volumes also supports third party drivers:

1. `block storage`: Good for `high performance` or `small block random access workloads`. This includes storage like Amazon EBS, as well as OpenStack Cinder.
2. `file storage`: Uses `protocols` such as `NFS` or `SMB`, and like block storage, it's also good for high performance workloads. Some examples include NetApp FAS, Azure File Storage, and Amazon EFS.
3. `object storage`: For large data blobs that don't change all that often. Some examples are Amazon S3, Ceph, MinIO, and OpenStack Swift.

> Note: When a volume is created on Linux, it's going to be located in `/var/lib/docker/volumes/`.

![Docker Volume](./images/docker-volume.png?raw=true "Docker Volume")
<p align = "center"> Docker Volume </p>

An example of how a volume is mounted into a container is shown in the diagram above. Let's say we have a directory called `code` under `/var`. The Docker volume will be mounted to `/var/code`, and any changes that we make in the code directory is going to be written to the volume as well.

More read:

* https://docs.docker.com/storage/volumes/

#### Executing volume commands in the container

`Non-persistent storage` is also known as `local storage` (by default all container use local storage). And for the persistent data we need to use either `volumes` or `bind mounts`.

List all volumes on a host

```sh
docker volume ls
```

Create a volume on a host

```sh
docker volume create [VOLUME NAME]
```

Inspect a volume on a host

```sh
docker volume inspect [VOLUME NAME]
```

Delete a volume on a host

```sh
docker volume rm [VOLUME NAME]
```

Remove all the unused volumes 

```sh
docker volume prune
```

Use the `--mount` flag to attach a volume to the container

```sh
docker volume create [VOLUME NAME]
docker container run -d --name [CONTAINER NAME] --mount type=volume,source=[VOLUME NAME],target=[TARGET PATH] [IMAGE NAME]

docker volume create html-volume
docker container run -d --name nginx-volume1 -p 8081:80 --mount type=volume,source=html-volume,target=/usr/share/nginx/html nginx
docker volume inspect html-volume
sudo ls -l /var/lib/docker/volumes/html-volume/_data
```

Use the `--volume` flag to attach a volume to the container

```sh
docker container run -d --name [CONTAINER NAME] --volume [VOLUME NAME]:[TARGET PATH] [IMAGE NAME]
(eg) docker container run -d --name nginx-volume2 -p 8081:80 --volume html-volume:/usr/share/nginx/html/ nginx
```

Use the `--mount` flag to attach a volume to the container but enabling `readonly`. By enabling `readonly` we won't be able to any files in the container inside the Volume created (f.e. `html-volume`)

```sh
docker container run -d --name [CONTAINER NAME] --mount type=volume,source=[VOLUME NAME],target=[TARGET PATH],readonly [IMAGE NAME]
(eg) docker container run -d --name nginx-volume3 -p 8081:80 --mount type=volume,source=html-volume,target=/usr/share/nginx/html,readonly nginx
```

#### Bind Mounts

Bind mounts have `limited functionality` compared to `volumes`. When we use a bind mount, `a file` or `directory` on the `host machine` is `mounted into a container`. For example, let's say we have a pre-existing `code` directory in our `/root` directory. We can mount this `code` directory into the `/var/code` on our container. With `volumes` the directory is located within the Docker storage directory (which is `/var/lib/docker/volumes`).

Even though `volumes` is the preferred method for maintaining persistent data but it is better to use `bind mounts` when we want to mount a single file, for example, a config file in our container. In this way we can just change the file in our host machine and restart the container to pickup the changes in the file, hence we don't need to make a change in the image, re-build the image, and re-deploy the container when the config file needs to be updated. 

> Note: `The file or directory is referenced by its absolute path on the host machine`. By contrast, when we use a `volume, a new directory is created within Docker’s storage directory on the host machine, and Docker manages that directory’s contents`.

For the `bind mount`, the file or directory does not need to exist on the Docker host already. It is created on demand if it does not yet exist. `Bind mounts are very performant, but they rely on the host machine’s filesystem having a specific directory structure available`. Recommendation is to use `named volumes` while developing new Docker applications. We can’t use Docker CLI commands to directly manage bind mounts.

More read:

* https://docs.docker.com/storage/bind-mounts/

#### Executing bind mount commands in the container

When we want to create a bind mount, there are 2 ways we can do it. We can either use `--mount` flag or `--volume or -v` flag. In general, `--mount` is more explicit and verbose. The biggest difference is that the `--volume or -v` syntax combines all the options together in one field, while the `--mount` syntax separates them. [Read more about the flags](https://docs.docker.com/storage/bind-mounts/#choose-the--v-or---mount-flag)

Using the `--mount` flag

```sh
mkdir [SOURCE PATH]
docker container run -d --name [CONTAINER NAME] --mount type=bind,source=[SOURCE PATH],target=[TARGET PATH] [IMAGE NAME]

mkdir "$(pwd)/target"
docker container run -d --name nginx-bind-mount1 -p 8081:80 -it --mount type=bind,source="$(pwd)"/target,target=/app nginx:latest
```

Using the `--volume or -v` flag

```sh
docker container run -d --name [CONTAINER NAME] --volume [SOURCE PATH]:[TARGET PATH] [IMAGE NAME]
(eg) docker run -d --name nginx-bind-mount2 --volume "$(pwd)"/target2:/app nginx:latest
```

> Note: If we use `--volume or -v` to bind-mount a file or directory that does not yet exist on the Docker host, `-v creates the endpoint` for us, however, it is always `created as a directory`. If we use `--mount` to bind-mount a file or directory that does not yet exist on the Docker host, `Docker does not automatically create it` for us, but `generates an error`.

## Dockerfile

Docker is able to build an image by `reading instructions` from the `Dockerfile`.

* A Docker image is a collection of `read-only layers`
* Each layer represents a Dockerfile instruction
* These layers are stacked on top of one another
* Each layer in a `delta of the changes` from the previous layer
* We use `docker image build ...` command to build the image. We pass any necessary flags that needs to be used and the `Dockerfile`

A `Dockerfile` looks as follows

```Dockerfile
FROM ubuntu:20.04
LABEL version="1.0"
COPY . /app
RUN make /app
CMD python /app/app.py
```

The above Dockerfile `layers` are described as below:

* `FROM` initialzies a new build stage and sets the `Base Image`. Every valid Dockerfile must start with a `FROM` instruction.
* `LABEL` instruction adds metadata to an image. A `LABEL` is a key-value pair. 
* `COPY` instruction `copies` new files or directories from the `source` (from our Docker client's current directory and the paths of the files and the directories will be interpreted as relative to the source of the context of the build directory) and adds them to the filesystem of the container at the path `destination`.
* `RUN` instruction will `execute any commands` (in a new layer on top of the current image and `commit the results`), here it builds the application using `make` command.
* `CMD` instruction tells the container `what command to run when the container starts`. There can only be `one` `CMD` instruction in a `Dockerfile`. The main purpose of a `CMD` is to provide defaults for an executing container.
  * These defaults can include an executable, or
  * We can omit the executable in the `CMD`, in which case we must specify an `ENTRYPOINT` instruction as well
    * `ENTRYPOINT` instruction allows us to configure a container that will run as an executable.

General guidelines:

* `Keep containers as ephemeral as possible`, hence we stop and destroy our container at a moment's notice, and create a new one to replace it with very little effort.
* `Follow` [Principle 6 of the 12 Factor App](https://12factor.net/processes) regarding processes. Execute the app as one or more stateless processes. Twelve-factor processes are stateless and shares nothing.
* `Avoid including unncessary fles`, i.e. any data that needs to be persisted must be stored in a stateful backing service, typically a database. We want to make sure that we don't add any bloat to our image, so avoid using any unnecessary files. All this will do is just make the image bigger.
* `Use .dockerignore` to avoid having unnecessary files getting copied over to the image.
* `Use multi-stage builds` to reduce the size of our Docker image. In a multi-stage build, 2 Docker images are being built from 1 Docker file. The first image is used to create our build artifact. This will include all the tools that are necessary to build our image, as well as test it. The second image, which is the image that will be created, is where we copy our build artifact to. This image will only have the necessary binaries and libraries to run our application. This will greatly reduce the size of our image.
* `Don't install unnecessary packages`, hence making the size of the image smaller. For example, anything that we see as being nice to have, don't include it in the image.
* `Decouple applications`, i.e. each container should only have a single concern. For example, if we want to build an WordPress application, we don't want one container running the WordPress along with the database. We would decouple this by creating multiple containers, one for the WordPress application itself, and another for the database. We could possibly be using Memcache, as well as the load balancer. All these will be running in their own containers as well.
* `Minimize the number of layers` because as we add additional layers, we do add additional size to the image. A good way of reducing the number of layers is by using multi-stage builds.
* `Sort multi-line arguments`, hence making the Dockerfile more readable, and a lot easier during peer review. Also, it's a good idea to have a space before the backslashes.
* `Leverage the build cache`. When Docker goes to build an image, it's going to step through each instruction in order. And, because each layer is its own image, Docker's going to go and look for a cached image. If it finds that cached image, it's going to reuse it. Optionally, when we are executing a `docker image build ...`, we can use the `--no-cache` flag, and set it to true. This will ignore any of the cached images.

Read more:

* https://docs.docker.com/engine/reference/builder/

### Create an application

Create an image for the `weather-app` application. The source code is taken from [linuxacademy/content-weather-app](https://github.com/linuxacademy/content-weather-app)

```Dockerfile
FROM node
LABEL version="1.0"
RUN mkdir -p /var/node
ADD src/ /var/node/
WORKDIR /var/node
RUN npm install
EXPOSE 3000
CMD ./bin/www
```

Build the `Dockerfile` as follows

```sh
docker image build --tag anis016/weather-app:1.0 .
# or, docker image build --tag anis016/weather-app:1.0 -f /path/Dockerfile
```

Check that the image is created

```sh
docker images | grep weather-app
```

Create an application container from this image

```sh
docker container run -d --name weather-app1 -p 8081:3000 anis016/weather-app:1.0
```

### Environment Variables

In the [Principle 3 of the 12 Factor App](https://12factor.net/config) regarding config, it states that the apps sometimes store configs as constants in code. This is a violation of twelve-factor, which requires strict separation of config from code. Config vary substantially across deploys, code does not.

We don't want to manage a bunch of configuration files that can vary from environment to environment. We just want to use one, and this is where the `Docker environment variables` come in. For example, we use an API key for an application and that API key is going to be different from development, staging, and production. When we deploy the container to development, we can specify the API key as an environment variable. So when that container comes online, it will use the API key that was specified for the development. The same logic applies when we want deploy our container to production. Instead of using the development API key, we specify the one that is for production.

There are 2 ways we can use the environment variable with our build.

* Through the `command line`. When we execute a `docker image build ...`, we use the `--env [KEY]=[VALUE]` flag to set the key-value pair of the environment variable.
* Set in the Dockerfile using `ENV` instruction. This is alo set using key-value pair. When we use the `ENV [KEY]=[VALUE]` instruction, we're setting the default that the container will use.

```sh
mkdir env && cd env
git clone https://github.com/linuxacademy/content-weather-app.git src
touch Dockerfile

FROM node
LABEL version="1.1"
ENV NODE_ENV="development"
ENV PORT 3000

RUN mkdir -p /var/node
ADD src/ /var/node/
WORKDIR /var/node
RUN npm install
EXPOSE $PORT
CMD ./bin/www
```

Note that in the `Dockerfile`, we have 2 environment variables, `NODE_ENV` and `PORT`. These 2 environment variables are set as default when we won't supply any environment variable during container creation. In this case, the `NODE_ENV=development` and `PORT=3000`.

Build the `Dockerfile` as follows

```sh
docker image build -t anis016/weather-app:1.1 .
```

Inspect the environment variables for the Docker image created

```sh
docker image inspect anis016/weather-app:1.1
```

Create an application container from this image

```sh
docker container run -d --name weather-app2 -p 8082:3001 --env PORT=3001 anis016/weather-app:1.1
```

If we wanted to change any of the environment variables, we could use the `--env` flag. For example, to set **production** to the `NODE_ENV`, we could set it as `--env NODE_ENV=production` and and this would overwrite default **development** in the Docker image built.

Inspect the environment variables for the Docker container created

```sh
docker inspect container weather-app2
```

### Build Arguments

Build arguments are used to `parametrize` a `Dockerfile`. Build arguments allows us to set build time variables in the `Dockerfile` and these variables can be referenced inside the file. We can do this by using the `ARG` instruction, which takes the name of the argument and the default value. We can also override the default build argument in the Dockerfile at build time when executing a docker image build. This can be done by using the `--build-arg` flag which takes a key-value pair. We can use multiple build arguments when building an image (by supplying the build argument again and supplying the key-value pair).

```sh
mkdir args && cd args
git clone https://github.com/linuxacademy/content-weather-app.git src
touch Dockerfile

FROM node
LABEL version="1.2"
ARG SRC_DIR=/var/node

RUN mkdir -p $SRC_DIR
ADD src/ $SRC_DIR
WORKDIR $SRC_DIR
RUN npm install
EXPOSE 3000
CMD ./bin/www
```

Build the `Dockerfile` as follows

```sh
docker image build -t anis016/weather-app:1.2 --build-arg SRC_DIR=/var/code .
```

Inspect the `WorkingDir` variable for the Docker image created

```sh
docker image inspect anis016/weather-app:1.2 | grep "WorkingDir"
```

Create an application container from this image

```sh
docker container run -d --name weather-app3 -p 8083:3000 anis016/weather-app:1.2
```

### Non-privileged User

The `USER` instruction allows us to create a non-privileged user. Below are things that happens when we use this instruction.

* When we connect to the container, it will be using this non-privileged user
* Any instructions we run after setting the user will be executed as that user

```sh
mkdir non-privileged-user && cd non-privileged-user
git clone https://github.com/linuxacademy/content-weather-app.git src
touch Dockerfile

FROM centos:latest
RUN useradd -ms /bin/bash cloud_user
USER cloud_user
```

In the `Dockerfile` we added a new user `cloud_user` by executing `useradd` command. We also make sure that we set `/bin/bash` as the shell for this user. Lastly, we use the `USER` instruction and set this to the `cloud_user`. The `USER` instruction is going to `set the name`, and optionally, the `user group` to use when it's running the image. This means that the `RUN`, `CMD`, and `ENTRYPOINT` instructions that follow after this `USER` instruction will be executed as that user.

Build the `Dockerfile` as follows

```sh
docker image build -t centos7/nonroot:1.0 .
```

Create container from this image and we will see that, the logged in user is the `cloud_user`.

```sh
docker container run -it --name test-non-priv-user centos7/nonroot:1.0
```

> Note: With non-privileged user we won't have access to the container's root using normal way. To get the root access, we need to be enter the container by supplying `--user 0` (0 is the root user id) flag. The command is `docker container exec --user 0 -it test-non-priv-user /bin/bash`

```sh
mkdir node-non-privileged-user && cd node-non-privileged-user
git clone https://github.com/linuxacademy/content-weather-app.git src
touch Dockerfile

FROM node
LABEL version="1.3"
RUN useradd -ms /bin/bash node_user
USER node_user

ADD src/ /home/node_user
WORKDIR /home/node_user
RUN npm install
EXPOSE 3000
CMD ./bin/www
```

> Note: If we see the error `npm ERR! path /home/node_user/package-lock.json` then delete the `src/package-lock.json` file and rebuild.

Build the `Dockerfile` as follows

```sh
docker image build -t anis016/weather-app:1.3 .
```

Create an application container from this image

```sh
docker container run -d --name weather-app4 -p 8084:3000 anis016/weather-app:1.3
```

### Order of Execution

As we write a `Dockerfile` to build the image, we add instructions, and these instructions are going to be executed in a linear fashion, starting at the top most instruction and making its way down to the bottom. The order of execution is important in the sense that sometimes some instructions are dependent on others.

```sh
mkdir centos-conf && cd centos-conf
touch Dockerfile

FROM centos:latest
RUN mkdir -p ~/new-dir1
RUN useradd -ms /bin/bash cloud_user
USER cloud_user
RUN mkdir -p ~/new-dir2
RUN mkdir -p /etc/myconf
RUN echo "some config data" >> /etc/myconf/my.conf
```

Try Build the `Dockerfile` as follows

```sh
docker image build -t centos7/myconf:v1 .
```

We will see the image build failed. The order of execution of the image build is shown below

```sh
Sending build context to Docker daemon  2.048kB
Step 1/7 : FROM centos:latest
 ---> 5d0da3dc9764
Step 2/7 : RUN mkdir -p ~/new-dir1
 ---> Running in 11d651b91d9d
Removing intermediate container 11d651b91d9d
 ---> ff09e42915e8
Step 3/7 : RUN useradd -ms /bin/bash cloud_user
 ---> Running in f7b2af096a02
Removing intermediate container f7b2af096a02
 ---> 1cdce89ca7b4
Step 4/7 : USER cloud_user
 ---> Running in c64ea42cc693
Removing intermediate container c64ea42cc693
 ---> 5f24fc33437e
Step 5/7 : RUN mkdir -p ~/new-dir2
 ---> Running in 08751a7bbfb0
Removing intermediate container 08751a7bbfb0
 ---> d2dc0b63ddc9
Step 6/7 : RUN mkdir -p /etc/myconf
 ---> Running in 61fe7dc2ac77
mkdir: cannot create directory '/etc/myconf': Permission denied
The command '/bin/sh -c mkdir -p /etc/myconf' returned a non-zero code: 1
```

From the above execution we can see we first set the `cloud_user` and then we are trying to create a directory, named `/etc/myconf`, and we're getting permission denied. We are getting permission denied because we are trying to execute a command that is only reserved for superuser or root. Because we are the `cloud_user` at this point, when `mkdir` command is executed in `/etc/` directory, we don't have the necessary permissions. And the same thing happens, when we are trying to `echo` some data into the `conf` file. To make this right we need to re-order the execution plan such that the these instructions (which requires root user privileges) are executed before we set the `cloud_user`.

```Dockerfile
FROM centos:latest
RUN mkdir -p ~/new-dir1
RUN useradd -ms /bin/bash cloud_user
RUN mkdir -p /etc/myconf
RUN echo "some config data" >> /etc/myconf/my.conf
USER cloud_user
RUN mkdir -p ~/new-dir2
```

Build the `Dockerfile` as follows

```sh
docker image build -t centos7/myconf:v1 .
```

### Using Volume Instruction

The `VOLUME` instruction allows us to create a mountpoint for a specified directory. This means when we create a container using the image, it's going to automatically have a volume attached to it. The `VOLUME` instruction can take a string or an array, so if we want to create multiple volumes at once, we can use the square brackets, and then a comma-delimited list of mountpoints.

```sh
mkdir volumes && cd volumes
touch Dockerfile

FROM centos:latest
VOLUME ["/usr/share/nginx/html/"]
```

Build the `Dockerfile` as follows

```sh
docker image build -t anis016/nginx:v1 .
```

Create a container from this image

```sh
docker container run -d --name nginx-volume anis016/nginx:v1
```

Run inspect on the container, check the volume added and get the volume name from the `Mounts`

```sh
docker container inspect nginx-volume
```

Inspect the volume and check the contents of the Mountpoint. We will see the default HTML files pre-populated in the volume.

```sh
docker volume inspect 07c87599e99006c40fd1a88862ceebfcdd1d2b13c472a0ea118d83c5987a8a1d
```

More read:

* https://docs.docker.com/engine/reference/builder/#volume

### Entrypoint vs. Command

`CMD` instruction provides defaults for an executing conatiner. These defaults can include an `executable`, or we can omit the executable, in which case we must specify an `ENTRYPOINT` instruction as well.

> Note: Usecase for the `CMD` instruction is to set default command with the expectation that we would want to override the command if we wanted to do something else.

`ENTRYPOINT` allows us to configure a container that will run as an executable. It cannot be overridden when starting the container but we can override the `ENTRYPOINT` instruction using the `docker run --entrypoint` flag.

> Note: Use `ENTRYPOINT` to specify an executable and `CMD` to set environment variables.

```sh
mkdir entrypoint && cd entrypoint
git clone https://github.com/linuxacademy/content-weather-app.git src
touch Dockerfile

FROM node
LABEL version="v1.6"
ENV NODE_ENV="production"
ENV PORT 3001

RUN mkdir -p /var/node
ADD src/ /var/node/
WORKDIR /var/node
RUN npm install
EXPOSE $PORT
ENTRYPOINT ./bin/www
```

Build the `Dockerfile` as follows

```sh
docker image build -t anis016/weather-app:v6 .
```

Create an application container from this image, note that we are sending a command - `echo "Hello World"` after the image name.

```sh
docker container run -d --name weather-app6 -p 8081:3001 anis016/weather-app:v6 echo "Hello World"
```

If we now inspect the container, we can see the command `echo "Hello World"` is added to the `Args`. What this means is, `ENTRYPOINT` allows us to add additional flags to it, if there are additional commands are supplied to it.

```sh
"Args": [
    "-c",
    "./bin/www",
    "echo",
    "Hello World"
],
...
...
Cmd": [
    "echo",
    "Hello World"
],
```

### Using .dockerignore

The `.dockerignore` file is very similar to the `.gitignore` file in that it allows us to specify a list of files or directories that Docker is to ignore during the build process.

```sh
touch .dockerignore

*/*.md
*/.git
src/docs/
*/tests/
```

## Building and Distributing Images

Build an image from a Dockerfile. There is a `.` (dot) at the end of the command (which is an alias for `$PWD` current directory). This tells docker the that the resources for building the image are in the current directory.

```sh
docker image build -t [IMAGE NAME]:[TAG] .
(or) docker image build -t [IMAGE NAME]:[TAG] -f Dockerfile.test .
```

> Note: By default, when we run the docker build command, it looks for a file named `Dockerfile` in the current directory. To target a different file, we need to pass `-f` flag.

Useful flags:

* `-f`, `--file` **string**: Name of the Dockerfile
* `-t`, `--tag` **string**: Name of the image and optionally a tag in the `'name:tag'` format
* `--label` **key=value**: Sets metadata for an image
* `--rm` **boolean**: Removes intermediate containers after a successful build
* `--force-rm`: Always remove intermediate containers
* `--ulimit`: Ulimit options

Read more:

* https://docs.docker.com/engine/reference/commandline/image_build/

### Multi-stage build

One of the most challenging things about building images is keeping the image size down. Each instruction in the `Dockerfile` adds a layer to the image, and we need to remember to clean up any artifacts we don’t need before moving on to the next layer. Often we need to `RUN` commands using the Bash `&&` operator, to avoid creating an additional layer in the image.

One of the ways to help us acheive the small image size is by using `multi-stage` builds. A multi-stage build allows us to use multiple images to build a final product. In a multi-stage build, we have a `single Dockerfile`, but we are able to define multiple images in there to help us build a final image. This is done by using multiple `FROM` statements in our Dockerfile. Each `FROM` instruction can use a different base, and each of them begins a new stage of the build. We can selectively copy artifacts from one stage to another, leaving behind everything that we don’t want in the final image. Using multi-stage builds

* By default, the stages are not named
* Stages are integer numbers, starting with 0 for the first `FROM` instruction
* Name the stage by adding `<name>` to the `FROM` instruction
* Reference the stage name in the `COPY` instruction

```sh
mkdir multi-stage-build && cd multi-stage-build
git clone https://github.com/linuxacademy/content-weather-app.git src
touch Dockerfile

FROM node as build
RUN mkdir -p /var/node
ADD src/ /var/node/
WORKDIR /var/node
RUN npm install

FROM node:alpine
ARG VERSION=V1.1
ARG ENV="production"
LABEL version=${VERSION}
ENV NODE_ENV=${ENV}
COPY --from=build /var/node /var/node
WORKDIR /var/node
EXPOSE 3000
ENTRYPOINT ["./bin/www"]
```

Build the `Dockerfile` as follows, note that we are using `--rm` so that any additional images that gets created are purged after successful build.  

```sh
docker image build -t anis016/weather-app:multi-stage-build --rm --build-arg VERSION=1.6 .
```

Use `docker image prune` to delete the dangling image. However, note the size difference between the current image built and the earlier images.

```sh
$ docker images
REPOSITORY            TAG                 IMAGE ID       CREATED          SIZE
anis016/weather-app   multi-stage-build   54975465f5d0   3 minutes ago   183MB
anis016/weather-app   v6                  c2a2cc1edc85   9 hours ago     1.02GB
```

Create an application container from this image

```sh
docker container run -d --name weather-app-multi-stage-build -p 8081:3000 anis016/weather-app:multi-stage-build
```

Read more:

* https://docs.docker.com/develop/develop-images/multistage-build/

### Tags

Docker Image tags are simple `labels` or `aliases` given to a docker image to describe that particular image.

* When we are trying to build an image using the `docker build` command, we can specify the tag along with the image name to build the image with that specific tag. we can use the `-t` or `--tag` flag to do so.
  ```sh
  docker image build −t [USERNAME]/[IMAGE NAME]:[TAG] .
  (or) docker image build −-tag [USERNAME]/[IMAGE NAME]:[TAG] .
  ```
* We can also create a new tagged image `TARGET_IMAGE` that refers to an already existing image `SOURCE_IMAGE`
  ```sh
  docker image tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
  ```

Read more:

* https://docs.docker.com/engine/reference/commandline/tag/


## Container Mangement

Display the running processes of a container

```sh
docker container top [CONTAINER NAME or ID]
```

Display a live stream of container(s) resource usage stats

```sh
docker container stats [CONTAINER NAME or ID]
```

### Auto Restart the Containers

We can use the `--restart` flag to set the restart policies for a container. By default, `--restart` is set to `no`. This means that every container we created won't restart automatically. If the Docker server stops, or if the server is rebooted, those containers are not going to start back up.

There are 4 options to configure the restart policy using the `--restart` flag:

* `no`: The default option. If the container was stopped, the container will not automatically restart under any circumstances.
* `on-failure`: This will restart the container if it exists due to an error (i.e. non-zero exit code).
* `always`: The container will always restart, even if it's stopped manually.
* `unless-stopped`: Similar to the `always` option. The big difference is that if we stop the container, it's not going to restart on it's own. This means that the container won't restart, even if the Docker daemon is restarted.

```sh
docker container run -d --name [CONTAINER NAME] --restart [RESTART-POLICY] [IMAGE NAME]:[TAG]
```

### Docker Events

Docker events is a way to get the `real-time event data` about containers. For example, if an user attaches to a container, we may want to get a notification because once they detach, that container is going to stop, and this is the kind of stuffs that we want to be alerted on. We can use both the CLI and the API to get the docker events from the container.

To get the events we can use the below command

```sh
# for monitoring the current events only
docker system events
```

Use the `--since` flag and then specify a time period to get the events from past 1 hour and continue monitoring the current events

```sh
docker system events --since '[TIME PERIOD]'
(eg) docker system events --since '1h'
```

We can also filter events by using the `--filter` flag, we are going to tell the filter what to look for by supplying a filter name

```sh
docker system events --filter [FILTER NAME]=[FILTER]
```

```sh
# filtering on container object type and get the events from past 1 hour and the future events of this type
docker system events --filter type=container --since '1h'

# Using multiple filters, the first one is filtering on type container, and then filtering for the start event
(eg) docker system events --filter type=container --filter event=start --since '1h'

(eg) docker system events --filter type=container --filter event=attach
(eg) docker system events --filter type=container --filter event=attach --filter event=die --filter event=stop
```

More read:

* https://docs.docker.com/engine/reference/commandline/events/

### Managing Docker with Portainer

`Portainer` is a simple `management UI tool` that helps us to manage Docker as well as Docker Swarm. We can basically do everything in it that we can do with the command line.

For more information on `Portainer`, visit the website https://portainer.io and the GitHub repository at https://github.com/portainer/portainer

Start the `Portainer` using the following command

```sh
docker volume create portainer_data
docker container run -d --name portainer -p 8081:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
```

Connect to the portainer using `localhost:8081`.

```sh
username: admin
password: password123
```

![Portainer](./images/portainer.png?raw=true "Portainer")
<p align = "center"> Portainer </p>

### Updating Containers with Watchtower

`Watchtower` is an application that will monitor the running Docker containers and watch for changes to the images that those containers were originally started from. If the `Watchtower` detects that an image has been changed, it will automatically restart the container using the new image. It is a tool to keep the containers up to date.

For more information on `Watchtower`, visit the website https://containrrr.dev/watchtower/ and the GitHub repository at https://github.com/containrrr/watchtower

Start the `Watchtower` using the following command. Poll interval (in seconds) controls how frequently watchtower will poll for the new images, it is set by using `--interval` flag. For more arguments, check: https://containrrr.dev/watchtower/arguments/

```sh
docker run --detach --name watchtower --restart always --volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --interval 15
```

The `Watchtower` works as follows (`Watchtower` is running in the background and monitors the running containers):

1. Create a Docker image
2. Push it to the Docker Hub, because `Watchtower` checks the Docker registry for the image for comparing and see if there is any differences there
3. Create a container from this image.
4. Next make some changes and update the Docker image
5. Re-build the image by supplying the `--no-cache` flag becasue we don't want to use any of the previous layers
6. Push the image to the Docker Hub
7. `WatchTower` polls after the interval set (15 seconds). It pulls the latest image and compares it to the one that was used to run the old container. If it sees that the image has been changed it will stop/remove the old container and then restart it using the new image and the same `docker run` options that were used to start the old container initially.

## Docker Compose

Docker Compose is a tool for running multi-container Docker applications defined using the Compose file format. A Compose file is used to define how one or more containers that makes up the application are configured. Once we have a Compose file, we can create and start our application with a single command - `docker compose up`. A sample Compose file looks as follows

```yaml
---
services:
  web:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - .:/code
  redis:
    image: redis
```

Read more:

* https://docs.docker.com/compose/

### Multi-service application

Create a simple `docker-compose.yml` file

```yaml
---
version: "3.9"
services:
  web:
    image: nginx
    ports:
      - "8082:80"
    volumes:
      - nginx_html:/usr/share/nginx/html/
    links:
      - redis
  redis:
    image: redis
volumes:
  nginx_html: {}
```

Use the command to build and start the application

```sh
docker-compose up -d
```

An example of a real world micro-service application could be found in the `web-hit-counter`. This is a simple Python web application running on Docker Compose. The application uses the Flask framework and maintains a hit counter in Redis.

Run the `build.sh` file to build the compose services.

> Note: If we make changes to our Dockerfile, we need to rebuild before executing the `docker-compose up`. The rebuilding is done by executing `docker-compose build`, this will use the cached layer. To rebuilt completely use `docker-compose build --no-cache`

Monitor the health check of a container using the following command.

```sh
docker inspect --format "{{json .State.Health }}" mysql | jq
```

Read more:

* https://docs.docker.com/compose/compose-file/
* https://docs.docker.com/compose/compose-file/#depends_on
* https://docs.docker.com/engine/reference/builder/#healthcheck
* https://github.com/peter-evans/docker-compose-healthcheck

## Docker Swarm

Docker swarm is a container orchestration tool, meaning that it allows the user to manage multiple containers deployed across multiple host machines. Also, we can scale our containers as per need.

Swarm has two major components:

* Swarm cluster
  * A cluster consists of 1 or more Docker nodes. When we initialize it, the very first node is always going to be a manager, and the other nodes are the worker nodes.
  * Docker Swarm has a number of security features
    * Encrypted, distributed cluster store. By default, communication between the nodes is encrypted.
    * Swarm also uses secure join tokens for both manager and worker nodes.
* An orchestration engine for creating microservices
  * Swarm expose an API that allows us to deploy and manage complex microservices with ease.
  * We can define our applications in a manifest file in a declarative fashion.
  * Swarm makes it easy to perform rolling updates, roll back failed deployments, and scale our applications up and down.

A swarm consists of one or more Docker nodes. The Docker swarm can be run on anything from physical servers to virtual machines, cloud instances, and it could even run on raspberry PI.

There are 2 types of nodes in a Swarm. Nodes are either a manager or a worker.

* `Manager nodes`: The primary role of the manager nodes is to `manage the state of the cluster`, as well as `dispatching tasks to the worker nodes`.
* `Worker nodes`: These nodes are responsible for `accepting the tasks and executing them`.

Configuration data and the state of the swarm is stored in the `etcd` database. The `etcd` is also run in memory on the manager nodes, which means that it keeps things always up to date.

> Transport layer security (TLS) is tightly integrated into swarm. It uses TLS to encrypt communication, as well as handling the authentication of nodes and authorizing roles. There is also automatic key rotation.

In a swarm, the atomic unit of the scheduling is the `service`. This is a new object in the Docker API. It is a construct that wraps the container, and it gives it additional functionality, such as
* Scaling
* The ability to perform rolling updates
* Rolling back to a previous deploy

When a container is created by a service, it's typically referred to as a `task` or a `replica`.

More read:

* https://docs.docker.com/engine/swarm/

### Docker Swarm Commands

Running Docker in Swarm mode

Initialize the manager. The flag `--advertise-addr [PRIVATE IP]` specifies the address that will the advertised to the other members of the swarm. This will include API access as well as the overlay network. The output from the below command will be to join the token that needs to be run on the worker nodes.

```sh
docker swarm init --advertise-addr [MANAGER NODE PRIVATE IP]
```

Get the command shown in the previous `swarm init` and use this command to add the worker nodes to the cluster

```sh
docker swarm join --token [TOKEN] [MANAGER NODE PRIVATE IP]:2377
```

Back in the Manager execute the list of the nodes in the swarm

```sh
docker node ls
```

### Managing Swarm Nodes Commands

Listing nodes in the swarm. The command needs to be executed from the Manager node.

```sh
docker node ls
```

To get information about a specific node, use the below command

```sh
docker node inspect [NODE ID or NODE HOSTNAME]
```

Promote a worker node to a manager. Use case would be that we need to take the leader for the maintenance

```sh
docker node promote [NODE ID or NODE HOSTNAME]
```

Demote a manager to a worker node

```sh
docker node demote [NODE ID or NODE HOSTNAME]
```

Remove a node from the swarm. Before deleting a manager node, first we need to demote this node to a worker node

```sh
docker node rm -f [NODE ID or NODE HOSTNAME]
```

Have a worker node leave the swarm node as well. This needs to be executed from the worker node that was removed from the swarm. This will demote this node from being a worker node down to just being a Docker host.

> Only leaving the swarm won't make manager node to automatically delete the node

```sh
docker swarm leave
```

To rejoin the worker node to the swarm.

> We need to make sure the node left the swarm before joining back to the swarm

```sh
# get the join-token from the manager for either the worker or the manager
docker swarm join-token [worker|manager]

# have the node rejoin the swarm
docker swarm join --token [TOKEN] [MANAGER NODE PRIVATE IP]:2377
```

### Working with Services

Setup a Docker swarm with 1 Master node and 2 Worker nodes

```sh
cd docker_swarm
vagrant up
bash generate-host-file.sh -m 1 -w 2

# login to the master1 node
vagrant ssh master1
vagrant@master1:~$ sudo docker swarm init --advertise-addr 192.168.56.91
...
To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-1utt46ae4j6sqegedkuav1nvnaqeghssgr8x8n311266aihsoa-52wo9zkqgxqskjnfwmkl95gm9 192.168.56.91:2377
...
...

# login to the worker nodes and join the worker nodes
vagrant ssh worker1
vagrant@worker1:~$ docker swarm join --token SWMTKN-1-1utt46ae4j6sqegedkuav1nvnaqeghssgr8x8n311266aihsoa-52wo9zkqgxqskjnfwmkl95gm9 192.168.56.91:2377

vagrant ssh worker2
vagrant@worker2:~$ docker swarm join --token SWMTKN-1-1utt46ae4j6sqegedkuav1nvnaqeghssgr8x8n311266aihsoa-52wo9zkqgxqskjnfwmkl95gm9 192.168.56.91:2377

# from the master1 node check the swarm status
vagrant@master1:~$ docker node ls
ID                            HOSTNAME   STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
jjz1rdaoo495ldxxwhb5ns7r3 *   master1    Ready     Active         Leader           20.10.17
duqp2ptw6iw2e8049evi4lg80     worker1    Ready     Active                          20.10.17
mo5v59afvy2kn6sql90clgej1     worker2    Ready     Active                          20.10.17
```

An `application that is deployed` to a Docker host running in `swarm mode` is deployed as a `service`. A service is the image for a microservice within the context of some larger application. Examples of services might include an HTTP server, a database, or any other type of executable program that we wish to run in a distributed environment. When a service is created, it is accepted by the swarm manager and the `service definition represents the desired state`. Based on the `number of replicas`, the swarm will schedule replica `tasks`, and `each task invokes a single container`, and these containers run in isolation.

Read more:

* https://docs.docker.com/engine/swarm/key-concepts/#services-and-tasks
* https://docs.docker.com/engine/swarm/how-swarm-mode-works/services/

![Docker Swarm Services](./images/docker-swarm-services.png?raw=true "Docker Swarm Services")
<p align = "center"> Docker Swarm Services </p>

From the diagram above, we have a single service - `nginx` with 3 replicas. Each of the instances of the `nginx` service is also a `task` in the swarm. The swarm manager schedules the 3 replica tasks, and each of these tasks will be scheduled onto an available node within the swarm. In the swarm mode model, `each task` invokes exactly `one container`.

> When the container is live, the scheduler recognizes the task is in a running state. If, for whatever reason, the container fails a health check or is terminated, the task is also terminated. If the minimum number of replicas is not met, then a new task will be scheduled and created.

Creating a service is similar to creating a container, but rather than executing docker container run, we will be using the command `docker service create`.

```sh
docker service create -d --name [NAME] -p [HOST PORT]:[CONTAINER PORT] --replicas [NUMBER OF REPLICAS] [IMAGE] [CMD]
(eg) docker service create -d --name nginx_service -p 8080:80 --replicas 3 nginx:latest
```

> Note: `-d` flag is used to run the service in the background, `--replicas` sets the number of replica tasks

List services

```sh
docker service ls
(eg) docker service ls
ID             NAME            MODE         REPLICAS   IMAGE          PORTS
m799kz2gf424   nginx_service   replicated   3/3        nginx:latest   *:8080->80/tcp
```

List all tasks of a service

```sh
docker service ps [SERVICE NAME]
(eg) docker service ps nginx_service
ID             NAME              IMAGE          NODE      DESIRED STATE   CURRENT STATE            ERROR     PORTS
ctrljs9c3l2z   nginx_service.1   nginx:latest   worker1   Running         Running 28 seconds ago             
5dig05hg1v7b   nginx_service.2   nginx:latest   worker2   Running         Running 25 seconds ago             
8xb4ozw7yd9h   nginx_service.3   nginx:latest   master1   Running         Running 27 seconds ago
```

Inspect service

```sh
docker service inspect [SERVICE NAME]
```

Using the `NetworkID` (from `docker service inspect` command) we can search for the network the containers will be attached to

```sh
docker service inspect nginx_service | grep "NetworkID"
"NetworkID": "5fxnwlyhgx617734qhtwlcg9w",

docker network ls --no-trunc | grep "p01rgyj8869ss2oytujpqltyt"
```

Getting the logs of the service

```sh
docker service logs [SERVICE NAME]
```

Scaling a service up or down

```sh
docker service scale [SERVICE NAME]=[REPLICAS]

(eg) docker service scale nginx_service=4
nginx_service scaled to 4
overall progress: 4 out of 4 tasks 
1/4: running   [==================================================>] 
2/4: running   [==================================================>] 
3/4: running   [==================================================>] 
4/4: running   [==================================================>] 
verify: Service converged 

(eg) docker service ps nginx_service 
ID             NAME              IMAGE          NODE      DESIRED STATE   CURRENT STATE                ERROR     PORTS
ctrljs9c3l2z   nginx_service.1   nginx:latest   worker1   Running         Running about a minute ago             
5dig05hg1v7b   nginx_service.2   nginx:latest   worker2   Running         Running about a minute ago             
8xb4ozw7yd9h   nginx_service.3   nginx:latest   master1   Running         Running about a minute ago             
uiwyda3nri58   nginx_service.4   nginx:latest   master1   Running         Running 9 seconds ago
```

Updating a certain aspects of the service. Use the `--help` command to check all the options

```sh
docker service update [OPTIONS] [SERVICE NAME]
```

Since the containers are running on different nodes the service is being load balanced, so we will not able to access it using localhost. However, we can curl it using either the public or private IP of the nodes in the cluster.

```sh
curl 192.168.56.91:8080
```

### Working with Network

Docker swarm uses `overlay` network. The overlay network connects `multiple Docker daemons` together to create a flat virtual network across hosts where we can establish a communication

* between a swarm service and a standalone container, or
* between two standalone containers on different Docker daemons

For example, the diagram below shows the overlay network that allows us to establish connections between different hosts that are hidden from each other. There there are two hosts and each one runs `docker`, the overlay network The overlay network sits on top of the host-specific network and each container connected to this overlay network will be able to communicate with other containers.

> By default, all service management traffic are encrypted. Manager nodes in the swarm rotate the keys used to encrypt the data every 12 hours.

![Docker Swarm Overlay Example](./images/docker-swarm-overlay-example.png?raw=true "Docker Swarm Overlay Example")
<p align = "center"> Docker Swarm Overlay Example </p>

Docker handles the routing of the packets to the correct Docker host and to the correct container. This allows us to use the public IP of our swarm manager to access the service and this routes the traffic to the correct Docker host and to the correct container. Overlay networks are best when we need containers running on different Docker hosts to communicate, or when multiple applications work together using the swarm services. We can add a service to multiple networks as shown below.

![Multiple services connected to network](./images/docker-swarm-overlay-multi-service.png?raw=true "Multiple services connected to network")
<p align = "center"> Multiple services connected to network </p>

For the services to communicate in the swarm, we can use the following commands to attach the services to the network

```sh
docker network create -d overlay test1
docker network create -d overlay test2
docker service create --name my-network-test --network test1 --network test2 [IMAGE]:[TAG]
```

A Docker swarm generates two different kinds of traffic:

1. `Control and management plane traffic`: This includes swarm management messages, such as requests to join or leave the swarm. This traffic is always encrypted.
2. `Application data plane traffic`: This includes container traffic and traffic to and from external clients.

The following three network concepts are important to swarm services:

* `Overlay networks` creates a `distributed network` across multiple Docker nodes. We can attach a service to one or more existing overlay networks, to enable service-to-service communication.
* The `ingress network` is a special overlay network that `handles the control and data traffic related to swarm services`. The `ingress network` is created automatically when we initialize or join a swarm. If we don't supply a user-defined network, it's going to use ingress by default.
* The `docker_gwbridge` is a bridge network that `connects individual Docker daemons to other daemons participating in the swarm`.

List the available networks

```sh
vagrant@master1:~$ docker network ls
NETWORK ID     NAME              DRIVER    SCOPE
b663606e10b0   bridge            bridge    local
b865705d6fa7   docker_gwbridge   bridge    local **
1c4b481a948c   host              host      local
5fxnwlyhgx61   ingress           overlay   swarm **
c760565189d7   none              null      local
```

List the available network without truncation

```sh
docker network ls --no-trunc
NETWORK ID                                                         NAME                DRIVER    SCOPE
b663606e10b0b969d5f420933fe96164ce53437affd37a4cbf5ae0cb74893acf   bridge              bridge    local
b865705d6fa7cbbf9ea553cbd401960695757c43a505ee6a0b3c3dd2b3dc5445   docker_gwbridge     bridge    local
1c4b481a948c8f876e4b5ce0c4f3ef76ebd6d03c41d838b17e855044092bdfba   host                host      local
5fxnwlyhgx617734qhtwlcg9w                                          ingress             overlay   swarm
c760565189d79b6841c4c6b53c13959126a5ad81e602faabec8df2c59a87a6e3   none                null      local
```

Creating a new `overlay network` is like creating a bridge network.

```sh
docker network create -d overlay [NETWORK NAME]
(eg) docker network create -d overlay my_overlay
```

To create an encrypted network use the below command

```sh
docker network create -d overlay --opt encrypted [NETWORK NAME]
(eg) docker network create -d overlay --opt encrypted encrypted_overlay

docker network inspect encrypted_overlay
...
...
"Options": {
    "com.docker.network.driver.overlay.vxlanid_list": "4098",
    "encrypted": "" ## normal overlay network won't have this option
},
```

Create new service using the user-defined overlay network

```sh
docker service create -d --name [NAME] --network [NETWORK NAME] -p [HOST PORT]:[CONTAINER PORT] --replicas [NUMBER OF REPLICAS] [IMAGE] [CMD]
(eg) docker service create -d --name nginx_service_overlay --network my_overlay -p 8080:80 --replicas 2 nginx:latest
```

To add a pre-existing service and add to a network

```sh
docker service update --network-add [NETWORK NAME] [SERVICE NAME]
(eg) docker service update --network-add my_overlay nginx_service
```

To remove a service from a network

```sh
docker service update --network-rm [NETWORK NAME] [SERVICE NAME]
(eg) docker service update --network-rm my_overlay nginx_service
```

Deleting a new `overlay network` is like deleting a bridge network.

```sh
docker network rm [NETWORK NAME]
(eg) docker network rm encrypted_overlay
```

Read more:

* https://docs.docker.com/network/overlay/
* https://docs.docker.com/engine/swarm/networking/
* https://docs.docker.com/network/network-tutorial-overlay/
* https://nigelpoulton.com/demystifying-docker-overlay-networking/

### Working with Volumes

When it comes to using volumes in swarm mode, we need to use a `volume plugin`, like REX-Ray, because the native driver for volumes is local. This means, if we create a volume, it will be created locally to where that command was executed. For example, if we create a service and it has multiple replica tasks, and those tasks are running on different nodes. A volume will be created on each worker node. so, if we have worker 1 and 2, and we have 2 replica tasks, each are running on those individual nodes, then we will have 2 separate volumes created, which presents a problem. So, if we change the data on one of the volumes, it is not going to be updated on the other. So the data will not be persistent across those volumes, and that's the reason why we need to use a driver. Typically, this is handled through some form of block storage device.

Adding plugins to the docker

```sh
docker plugin install [PLUGIN] [PLUGIN OPTIONS]
(eg) docker plugin install store/splunk/docker-logging-plugin:2.0.0 --alias splunk-logging-plugin
```

Listing plugins

```sh
docker plugin ls
```

Remove a plugin

```sh
docker plugin disable [PLUGIN ID]
docker plugin rm [PLUGIN ID]
```

Create `rexray/dobs` plugin:

```sh
docker plugin install rexray/dobs DOBS_REGION=[DO REGION] DOBS_TOKEN=[DIGITAL OCEAN TOKEN] DOBS_CONVERTUNDERSCORES=true
```

Create a `local` volume using a driver. Since we created the volume with `local`, this volume will not be present on other docker host. This volume will only be present in the host where the volume is created 

```sh
docker volume create -d [DRIVER] [NAME]
(eg) docker volume create -d local portainer_data # this volume is created local to the manger host
```

Create a service using a driver

```sh
docker service create -d --name [NAME] --mount type=[TYPE],src=[SOURCE],dst=[DESTINATION] -p [HOST PORT]:[CONTAINER PORT] --replicas [REPLICAS] [IMAGE] [CMD]

# run this command on the manager host since volume is created there, and since we used the `constraint` on the manager node hence any replicas created will be also created on the manger node
(eg) docker service create \
        --name portainer \
        --publish 8000:9000 \
        --constraint 'node.role == manager' \
        --mount type=volume,src=portainer_data,dst=/data \
        --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
        portainer/portainer \
        -H unix:///var/run/docker.sock
```

Access `portainer` using `http://192.168.56.91:8000/`

Read more:

* https://rexray.readthedocs.io/en/stable/user-guide/schedulers/docker/plug-ins/

### Deploying Stacks

Stacks let us deploy a complete application to our swarm environment, and we do this using the Docker Compose file. 

Create `prometheus` applicaton **configuration** file

```sh
vagrant@master1:~/prometheus$ vi prometheus.yml

---
global:
  scrape_interval: 15s
  scrape_timeout: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: prometheus
    scrape_interval: 5s
    static_configs:
    - targets:
      - prometheus_main:9090

  - job_name: nodes
    scrape_interval: 5s
    static_configs:
    - targets:
      - 192.168.56.91:9100
      - 192.168.56.41:9100
      - 192.168.56.42:9100

  - job_name: cadvisor
    scrape_interval: 5s
    static_configs:
    - targets:
      - 192.168.56.91:8081
      - 192.168.56.41:8081
      - 192.168.56.42:8081
```

Create `prometheus` **docker-compose** file

```sh
vagrant@master1:~/prometheus$ vi docker-compose.yml

---
version: '3'
services:
  main:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - 8080:9090
    command:
      - --config.file=/etc/prometheus/prometheus.yml
      - --storage.tsdb.path=/prometheus/data
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - data:/prometheus/data
    depends_on:
      - cadvisor
      - node-exporter
  cadvisor:
    image: google/cadvisor:latest
    container_name: cadvisor
    deploy:
      mode: global
    restart: unless-stopped
    ports:
      - 8081:8080
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    deploy:
      mode: global
    restart: unless-stopped
    ports:
      - 9100:9100
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - --collector.filesystem.ignored-mount-points
      - "^/(sys|proc|dev|host|etc|rootfs/var/lib/docker/containers|rootfs/var/lib/docker/overlay2|rootfs/run/docker/netns|rootfs/var/lib/docker/aufs)($$|/)"
  grafana:
    image: grafana/grafana
    container_name: grafana
    ports:
      - 8082:3000
    volumes:
      - grafana_data:/var/lib/grafana
      s- grafana_plugins:/var/lib/grafana/plugins
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=password
    depends_on:
      - prometheus
      - cadvisor
      - node-exporter

volumes:
  data:
  grafana_data:
  grafana_plugins:
```

Deploy the stack in the swarm.

```sh
docker stack deploy [STACK NAME]
(eg) vagrant@master1:~/prometheus$ docker stack deploy --compose-file docker-compose.yml prometheus
```

> Note that we will get volume permissions issue because `prometheus` image uses the user `nobody`. Hence, create the user and the group and then correct the permission

```sh
vagrant@master1:~/prometheus$ sudo useradd nobody
vagrant@master1:~/prometheus$ sudo groupadd nobody
vagrant@master1:~/prometheus$ sudo chown nobody:nobody prometheus.yml
vagrant@master1:~/prometheus$ sudo chown nobody:nobody -R /var/lib/docker/volumes/prometheus_data
```

List the stack

```sh
docker stack ls
```

Check the service

```sh
docker service ls
```

List the tasks

```sh
docker service ps prometheus_main
```

Remove the stack

```sh
docker stack rm prometheus
```

Access `prometheus` using `http://192.168.56.91:8080/`

## Docker Security

Docker containers are very similar to LXC containers. They have some very similar security features. Whenever we create a container by executing `docker container run ...` command, Docker creates a set of `namespaces` as well as `control groups (cgroups)` for that container.

![Docker Security](./images/docker-security.png?raw=true "Docker Security")
<p align = "center"> Docker Security </p>

* `Namespaces` provides **isolation** for the **container**. This means `processes running within that container cannot see or interact with processes running on the host operating system or in another container`. This also gives each container its own network stack. That is, each container does not have privileged access to sockets or interfaces on other containers. This also means that containers can interact with one another using their network interfaces. This is just like any other computer on a network.
  > When a Docker container is created, it's going to get its own namespaces for the **process ID (PID)**, **network (net)**, **filesystem mount (mount)**, **inter-process communication (IPC)**, **user**, and **UTS**. This `collection of namespaces` is what we call a container. The namespace are briefly discussed below.
  >  * `Process ID (pid)` namespace isolates the process free of each container. It prevents the container from seeing or accessing the process tree of other containers or the host that it's running on.
  > * `Network (net)` namespace provides each container with its own isolated network stack. This includes things such as the network interface, IP addresses, port ranges, and route tables.
  > * `Filesystem/mount (mount)` namespace gives every container its own unique isolated file system. This prevents the container from accessing mount namespaces of the Linux host or other containers.
  > * `Inter-process communication (IPC)` namespace is used for sharing memory access within a container and also isolates it from other containers.
  > * `User (user)` namespace allows us to go and map a user inside of a container to a different user on the host. A good example of this is mapping the root user of a container to a non-root user on the host.
  > * `UTS (uts)` namespace provides each container with its own unique hostname.
* `Control groups (cgroups)` are responsible for accounting and limiting resources on a container. It is also responsible for making sure that each container gets its fair share of resources. This includes CPU, memory, and disk IO. Cgroups are also responsible for making sure that a container can't exhaust all the resources on a Docker host, therefore bringing the system down.
  > By default, containers don't have any resource constraints. This means they can consume as many resources as allowed by the kernel scheduler. One of the problems that we face when running containers is that we typically don't want to run them as a root because root is pretty powerful and it can be very, very dangerous. However, if we run it using a non-root user, it can become pretty useless. And in order to solve this problem, this is where capabilities come in. The root account is made up of a long list of capabilities. Docker works with these capabilities so the container can run as root, but strips out some of these capabilities that are not needed. Also, if a capability has been removed, Docker will prevent the container from adding a back in.

Docker works with 2 of the major mandatory access control systems: 

* `AppArmor`: AppArmor, or Application Armor, is a Linux security module that is responsible for protecting the operating system and its applications from security threats.
* `SELinux`: Security-enhanced Linux, or SELinux, is a Linux kernel security module that provides a mechanism for supporting access control security policies.

The last of the Linux technologies is `secure computing mode`, also known as `seccomp`. Seccomp is a Linux kernel future that allows us to go into `restrict actions available within a container`. Every container is given a default `seccomp` profile. This profile can be overwritten during container creation.

> Docker security scanning is currently available with private repositories on Docker Hub or the Docker trusted registry on-premises solution. This solution helps identify code vulnerabilities within our images. It does this by performing binary-level scans of the Docker image, and then checks it against a database of known vulnerabilities. `Docker Content Trust (DTC)` allows us to verify the integrity and the publisher of an image. This is how we know that an image coming from Nginx is actually from the Nginx. This also allows developers to sign their images before pushing them to Docker Hub or to a trusted registry.

`Docker secrets` allows us to store sensitive data such as passwords and API keys.

The easiest way of adding an additional layer of security is by having Docker run in swarm mode. This gives us the following features:

1. Cryptographic node IDs
2. Mutual authentication via TLS
3. Secure join tokens for both worker and management nodes
4. CA with automatic certificate rotation
5. Encrypted cluster stores
6. Encrypted networking

High-level workflow of how secrets work.

1. Secrets are only available to us in swarm mode, and this is because of the encrypted cluster store. When we create a secret, it is posted to the swarm.
2. The secret is encrypted and gets stored in the encrypted cluster store, and this runs on all the managers.
3. We can then create the service that is going to be using the secret and have that secret attached to it.
4. The secret is encrypted in-flight when it's delivered to the replica task.
5. The secret is then mounted into the container of the service as an unencrypted file. It's to be found in `/run/secrets`. This is a `in-memory tmpfs`. This means that each secret is going to be mounted into the container using its own `tmpfs` file system. For example, let's say we have a secret called, **my-secret**. It's going to be mounted in a container under **/run/secrets/mysecret**.
6. When the replica task is complete, the in-memory file system is torn down and then the secret is flushed from the node.

More read:

* https://docs.docker.com/engine/security/
* https://docs.docker.com/engine/security/seccomp/

### Working with Docker Security

#### Seccomp

Adding a custom `seccomp` profile

```sh
docker container run --security-opt seccomp=[PROFILE] [IMAGE] [CMD]
```

Testing `seccomp`. Since we have a default `seccomp` profile, even though we are `root` we don't permssion to many things, for example, mounting `/dev/sda1` into `/tmp` as show below

```sh
docker container run --rm -it alpine sh
/ # whoami 
root
/ # mount /dev/sda1 /tmp/
mount: permission denied (are you root?)
/ # 
```

Rather than using the default profile we will create our own customized profile

```sh
cd docker_security

# create a new directory
mkdir -p seccomp/profiles/chmod
wget https://raw.githubusercontent.com/moby/moby/master/profiles/seccomp/default.json

vi default.json
# remove chmod, fchmod, and fchmodat. This will remove the ability to do chmod in a container

# run the container with custom seccomp
docker container run --rm -it --security-opt seccomp=./seccomp/profiles/chmod/default.json alpine sh
/ # whoami 
root
/ # chmod +r home/
chmod: home/: Operation not permitted
/ # chmod +x home/
chmod: home/: Operation not permitted
```

#### Capabilities

Adding Capabilities

```sh
docker container run --cap-add=[CAPABILITY] [IMAGE] [CMD]
```

Dropping Capabilities

```sh
docker container run --cap-drop=[CAPABILITY] [IMAGE] [CMD]
```

Test the `mknod` (`mknod` is the command used to create device files) Capabilities

```sh
docker container run --rm -it alpine sh
/ # mknod /dev/random2 c 1 8
/ # ls -l /dev/random2 
crw-r--r--    1 root     root        1,   8 Aug 10 23:19 /dev/random2
```

Drop the `mknod` Capabilities and retest

```sh
docker container run --rm -it --cap-drop=mknod alpine sh
/ # mknod /dev/random2 c 1 8
mknod: /dev/random2: Operation not permitted
```

Read more:

* https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities

#### Control Groups

Limiting the amount of resources (CPU and Memory) a container can consume. By default, a container has no resource constraints. This means the container can use as much resources as the host kernel scheduler allows.

```sh
docker container run -it --cpus=[VALUE] --memory=[VALUE][SIZE] --memory-swap [VALUE][SIZE] [IMAGE] [CMD]
```

* `--cpus`: limits the amount of CPU access the container has
* `--memory`: limits on the amount of memory that the container can consume
* `--memory-swap`: limits the amount of swap space that the container has access to

Limit the CPU and Memory of a container

```sh
mkdir weather-app
cd weather-app && git clone https://github.com/linuxacademy/content-weather-app.git src
```

Create the Dockerfile

```Dockerfile
FROM node
LABEL version="1.0"
RUN mkdir -p /var/node
ADD src/ /var/node/
WORKDIR /var/node
RUN npm install
EXPOSE 3000
CMD ./bin/www
```

Create the image

```sh
docker image build --tag weather-app:latest .
docker container run -d --name resource-limits --cpus=".5" --memory=512M --memory-swap=1G weather-app:latest
docker container inspect resource-limits | grep Memory | head -n 1
            "Memory": 536870912,
docker container inspect resource-limits | grep Cpus | head -n 1
            "NanoCpus": 500000000,
```

Read more:

* https://docs.docker.com/config/containers/resource_constraints
* https://docs.docker.com/engine/reference/run/#runtime-constraints-on-resources

#### Docker Bench Security

Running Docker Bench Security:

```sh
docker container run --rm -it --network host \
    --pid host \
    --userns host \
    --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /var/lib:/var/lib \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/lib/systemd:/usr/lib/systemd \
    -v /etc:/etc \
    --label docker_bench_security \
    docker/docker-bench-security
```

Read more:

* https://github.com/docker/docker-bench-security

## Docker Commands

### Manage images

```sh
# download an image from the Docker hub
docker image pull [IMAGE NAME]:[TAG]

# list all local images
docker image ls

# creating and running a container from an image, if the image doesn't exist locally then the image is pulled from docker hub
docker run [IMAGE NAME]:[TAG]

# override the default run command
docker run [IMAGE NAME]:[TAG] [command]

# inspect an image
docker image inspect [IMAGE NAME or ID]

# removing an image with dependency
docker image rmi [IMAGE NAME or ID]

# removing an image with dependency
docker inspect --format='{{.Id}} {{.Parent}}' $(docker images --filter since=[IMAGE ID] -q)
docker image rm <child images>
docker image rm <parent image>

# force remove all the images
docker image rmi -f $(docker images -aq)

# build an image with a tag and location note the dot which says current location
docker image build -t [IMAGE NAME] .

# publish an image to dockerhub
docker image push [IMAGE NAME]

# create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
docker image tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]

# show history of an image i.e. shows every layer that was used to create the image
docker image history [IMAGE NAME]

# save image to a tar archive
docker image save [IMAGE NAME] > [FILE].tar
docker image save [IMAGE NAME] -o [FILE].tar
docker image save [IMAGE NAME] --output [FILE].tar

# load image from a tar archive
docker image load < [FILE].tar
docker image save -i [FILE].tar
docker image save --input [FILE].tar
```

### Manage Containers

```sh
# run a container from an image with tag
docker container run [IMAGE NAME]:[TAG]

# run a container from an image without tag (takes the default tag)
docker container run [IMAGE NAME]

# run a container from an image with a defined container name
docker container run --name [CONTAINER NAME] [IMAGE NAME]

# run a container in a detached mode
docker container run -d [IMAGE NAME]
docker container run -d --name [CONTAINER NAME] [IMAGE NAME]

# -P publishes all the exposed ports inside a container and maps to a random ports to the host
docker container run -P -d [IMAGE NAME]
(or) docker container run -P -d --name [CONTANER NAME] [IMAGE NAME]

# run a container with interactive terminal and attach to it, closing the terminal will stop the container too
docker container run -it [IMAGE NAME]

# same as above but attach to 'bash' terminal, closing the terminal will stop the container too
docker container run -it [IMAGE NAME] bash

# run a container with interactive terminal and attach to it, closing the terminal will remove the container too
docker container run --rm [IMAGE NAME]
docker container run --rm --name [CONTAINER NAME] [IMAGE NAME]

# list all the running containers
docker container ls
(or) docker ps

# list all the containers, even the stopped ones
docker container ls -a
(or) docker ps -a
(or) docker ps --all

# filter containers which are running
docker container ls -a --filter status=running

# filter containers which are exited
docker container ls -a --filter status=exited

# get the id of the stopped containers
docker container ls -a -q -f status=exited

# run a container from an image, publishing the specified ports
docker container run -p [PUBLIC PORT]:[CONTAINER PORT] [IMAGE NAME]

# inspect a running container
docker container inspect [CONTAINER ID or NAME]
(or) docker inspect [CONTAINER ID or NAME]

# get the processes inside a running container
docker container top [CONTAINER ID or NAME]
(or) docker top [CONTAINER ID or NAME]

# get the resource usage of a container
docker container stats [CONTAINER ID or NAME]

# attaching to a container, note that if we detach from the container it will stop the container. Also no shell present
docker container attach --name [CONTAINER ID or NAME]

# execute command in a container
docker container exec -it [CONTAINER ID or NAME] [COMMAND]
(eg) docker container exec -it nginx ls /usr/share/nginx/html/

# another way of attaching to a container using a bash shell by using exec command, this will keep the container intact
# note: the base distro needs to have bash/sh
docker container exec -it [CONTAINER ID or NAME] /bin/bash

# special form of the above, runs a bash shell and connects to the container terminal
docker container exec -it [CONTAINER ID or NAME] /bin/sh

# pause a contaner, this pauses all the processes running in the container
docker container pause [CONTAINER ID or NAME]

# unpause a contaner, this resumes all the paused processes in the container
docker container unpause [CONTAINER ID or NAME]

# create new container from an image, not that it doesn't start the container
docker create [IMAGE NAME]
(or) docker create --name [CONTAINER NAME] [IMAGE NAME]

# start a container
docker container start [CONTAINER ID or NAME]

# start a container and attach to the container
docker container start -a [CONTAINER ID or NAME]

# stop a running container
docker container stop [CONTAINER ID or NAME]

# kill a running container
docker container kill [CONTAINER ID or NAME]

# restart a stopped container
docker container start [CONTAINER ID or NAME]

# remove a stopped container
docker container rm [CONTAINER ID or NAME]

# forefully remove a stopped container
docker container rm -f [CONTAINER ID or NAME]

# remove all the stopped containers
docker container rm $(docker container ls -aq)

# remove all stopped containers (another way)
docker container prune

# remove all the containers without prompt
docker container prune -f

# forefully remove all the containers (even if the container is running)
docker container rm -f $(docker container ls -aq)

# remove all stopped containers, dangling images, networks, and build cache
docker sytem prune

# lists all the ports of a container
docker container port [CONTAINER ID or NAME]

# inspect the log in the container
docker container logs [CONTAINER ID or NAME]

# follow the log (STDIN/System.out) of the container
docker container logs -f [CONTAINER ID or NAME]

# take a snapshot image of a container
docker container commit -a "author" [CONTAINER ID or NAME] [IMAGE NAME]
```

### Manage Docker Registry

```sh
# this instructs Docker to start a registry named "registry:2" in detached mode with the name "registry". It also map the registry’s port 5000 to a local port 5000 and restart it immediately if it dies
docker run -d -p 5000:5000 --restart=always --name registry registry:2

# this requests docker to pull "ubuntu:latest" image from the public registry f.e. Docker hub
docker pull ubuntu:latest

# tagging the image and point to the registry
docker image tag ubuntu:latest localhost:5000/gfg-image

# push the image
docker push localhost:5000/gfg-image

# pull the image
docker pull localhost:5000/gfg-image

# stop the registry
docker container stop registry

# remove the data
docker container rm -v registry
```

### Manage local VM

```sh
# find the IP address of the VM (only when using Docker Toolbox)
docker-machine ip
```

### Manage Networks

```sh
# list all networks
docker network ls

# create a network using the bridge driver
docker network create <network name>
```

### Manage Volumes

```sh
# list all volumes
docker volume ls

# delete all volumes that are not currently mounted to a container
docker volume prune

# inspect a volume (can find out the mount point, the location of the volume on the host system)
docker volume inspect <volume name>

# remove a volume
docker volume rm <volume name>
```

### Docker Compose

```sh
# for building all the services inside docker-compose.yml file 
docker-compose build

# for building all the services inside docker-compose.yml file. This won't use the earlier cached layers 
docker-compose build --no-cache

# for building only a single service inside docker-compose.yml file. This won't use the earlier cached layers 
docker-compose build --no-cache [SERVICE NAME]

# for building all the services inside docker-compose.yml file and create the compose service 
docker-compose up

# for rebuilding the build that is listed inside the docker-compose.yml file. Use it when anything inside the code is changed. Better to use volumes for the service
docker-compose up --build

# start the compose service in the detached state
docker-compose up -d

# for listing all the running compose projects  
docker-compose ls

# stop the compose service, note that we need to be in the directory where docker-compose.yml file is
docker-compose stop

# start the compose service, note that we need to be in the directory where docker-compose.yml file is
docker-compose start

# restart the compose service, note that we need to be in the directory where docker-compose.yml file is
docker-compose restart

# stop all the containers (services) listed in the docker-compose.yml file and delete the compose project
docker-compose down

# list all the running docker-compose containers, note that we need to be in the directory where docker-compose.yml file is
docker-compose ps

# list all the running docker-compose containers by supplying the docker-compose.yml file path
docker-compose -f /path/to/docker-compose.yml ps

# follow the log for the specified service
docker-compose logs -f <service name>
```

### Manage a Swarm

```sh
# switch the machine into Swarm mode
docker swarm init (--advertise-addr <ip address of the manager>)

# stop swarm mode
docker swarm leave --force

# start a service in the swarm. The args are largely the same as those we will have used in docker container run.
docker service create <args>

# create a network suitable for using in a swarm
docker network create --driver overlay <name>

# list all services
docker service ls

# list all nodes in the swarm
docker node ls

# follow the log for the service. This feature is a new feature in the Docker and may not be available on all the version
docker service logs -f <service name>

# list full details of the service - in particular the node on which it is running and any previous failed containers from the service.
docker service ps <service name>

# get a join token to enable a new node to connect to the swarm, either as a worker or manager.
docker swarm join-token <worker|manager>
```

### Manage Stacks

```sh
# list all stacks on this swarm.
docker stack ls

# deploy (or re-deploy) a stack based on a standard compose file.
docker stack deploy -c <compose file> <stack name>

# delete a stack and its corresponding services/networks/etc.
docker stack rm <stack name> 
```

### Working with Dockerfile

```sh
# to build Dockerfile, go to the directory where Dockerfile exists and then build the file to create the image
docker build .

# to build Dockerfile by specifying a file (f.e. Dockerfile.dev) then use -f flag to create the image
docker build -f Dockerfile.dev .

# to build Dockerfile with a tag, go to the directory where Dockerfile exists and then build the file to create the image
# note: [version] is the tag
docker build -t [dockerhub-id]/[project-name]:[version]
docker build -t anis016/redis:latest .

# run the built custom image. Get the image id or the image name from the docker build command
docker run <IMAGE ID or NAME>

# run the image with port forwarding from the outside to the inside of the container
docker run -p [host port]:[container port] <IMAGE ID or NAME>
docker run -p 4040:8080 anis016/simpleweb

# run the image with port forwarding and with adding the bindmount volume (use --mount instead of -v option)
# note: -v /app/node_modules -> without the colon (:) it tells that the folder is inside the node, don't map it with the folder in the local machine
docker run -p [host port]:[container port] -v [local machine dir]:[container dir] <IMAGE ID or NAME>
docker run -it -p 3000:3000 -v $(pwd):/app anis016/frontend
docker run -it -p 3000:3000 -v /app/node_modules -v $(pwd):/app anis016/frontend

# run the docker image and access the running container with a shell
docker run -it [IMAGE NAME] bash/sh
docker run -it anis016/simpleweb sh

# manual image generation with docker commit
docker run -it [IMAGE NAME] sh
docker run -it alpine sh [in one terminal]

# run the required RUN command specified in the Dockerfile
docker ps [in another terminal and get the container id]
docker commit -c 'CMD["redis-server"]' [CONTAINER ID] [manual image generation and create entry point]
```

### Resources

* Most of the commands were taken from [Docker for Java Developers training](https://www.virtualpairprogrammers.com/training-courses/Docker-for-Java-Developers-training.html)
