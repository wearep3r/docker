ARG DOCKER_VERSION=20.10.3

FROM docker:${DOCKER_VERSION} AS docker-cli

FROM python:3.9.0-slim-buster as build

RUN apt-get update \
    && apt-get -y --no-install-recommends install \
    ca-certificates \
    curl \
    gcc \
    git \
    libc-dev \
    libffi-dev \
    libssl-dev \
    make \
    openssl \
    python3-dev \
    python3-pip \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker

ARG BACKPLANE_VERSION=0.7.5
ARG COMPOSE_VERSION=1.27.4
RUN pip3 install pyyaml openshift jmespath ansible "backplane${BACKPLANE_VERSION:+==}${BACKPLANE_VERSION}" "docker-compose${COMPOSE_VERSION:+==}${COMPOSE_VERSION}"

ARG HELM_VERSION=3.4.1
ARG KUBECTL_VERSION=1.19.0
ARG PORTER_VERSION=v0.33.0

RUN echo "curl -fsSL -o helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
    && curl -fsSL -o helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && tar xfvz helm.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf linux-amd64

RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o kubectl \
    && mv kubectl /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

RUN curl https://cdn.porter.sh/${PORTER_VERSION}/install-linux.sh | bash

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && groupadd -g 1000 docker \
    && useradd -g docker -u 1000 docker

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["sh"]

ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="wearep3r/docker"
LABEL org.label-schema.description="a Docker utility container including docker CLI, docker-compose, HELM, kubectl and Ansible"
LABEL org.label-schema.url="https://www.p3r.one/"
LABEL org.label-schema.vcs-url="https://github.com/wearep3r/docker"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vcs-type="Git"
LABEL org.label-schema.vendor="wearep3r"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.dockerfile="/Dockerfile"
