import docker

client = docker.from_env()

# get image list

print client.images.list()

# create a container

container = client.containers.create(
    image='nginx:latest',
    detach=True,
    ports={'80/tcp': 80}
)

# start container

container.start()

container.status()

container.name()