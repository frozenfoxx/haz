# Docker Deployment

# Requirements

* [Docker](https://www.docker.io/).
* Some videos, images, and/or audio files you wish to deploy.

# Build

```
git clone https://github.com/frozenfoxx/haz haz
cd haz
docker build -t frozenfoxx/haz:latest .
```

# Run

Deploy with host networking and a persistent media directory.

```
docker run \
  -it \
  --rm \
  --network host \
  -v /path/to/media:/data \
  frozenfoxx/haz:latest
```