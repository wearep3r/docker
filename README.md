# Docker

[!["Version"](https://img.shields.io/github/v/tag/wearep3r/docker?label=version)](https://github.com/wearep3r/docker)
[!["p3r. Slack"](https://img.shields.io/badge/slack-@wearep3r/general-purple.svg?logo=slack&label=Slack)](https://join.slack.com/t/wearep3r/shared_invite/zt-d9ao21f9-pb70o46~82P~gxDTNy_JWw)
[!["Release"](https://img.shields.io/github/v/release/wearep3r/docker)](https://github.com/wearep3r/docker/releases)
[!["Docker Downloads](https://img.shields.io/docker/pulls/wearep3r/docker)](https://hub.docker.com/r/wearep3r/docker)


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