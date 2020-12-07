# Docker

This image contains tooling commonly needed when working with Docker in a GitOps context:

- [Docker CLI](https://docs.docker.com/engine/reference/commandline/cli/)
- [Docker Compose](https://docs.docker.com/compose/)
- [backplane](https://github.com/wearep3r/backplane)
- [kubectl](https://kubernetes.io/de/docs/tasks/tools/install-kubectl/)
- [HELM](https://helm.sh/)

It's available as `wearep3r/docker` on [Docker Hub](https://hub.docker.com/r/wearep3r/docker).

## Build

```bash
make build
```

### Advanced 

```bash
docker buildx ls
docker buildx create --name wearep3r --use
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64 -t wearep3r/docker:latest --push .
```