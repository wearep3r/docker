ARG DOCKER_VERSION=19.03.13
ARG COMPOSE_VERSION=1.27.4
ARG BACKPLANE_VERSION=0.7.5

FROM docker:${DOCKER_VERSION} AS docker-cli

FROM python:3.9.0-slim-buster as build

# RUN apk update \
#     && apk add --no-cache \
# 		ca-certificates \
# 		python3-dev \
# 		python3-pip \
# 		libffi-dev \
# 		openssl-dev \
# 		gcc \
# 		libc-dev \
# 		make \
# 		bash \
# 		git \
# 		curl

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
    zlib1g-dev 
    

COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker

RUN \
  mkdir -p /compose && \
  if [ -z ${COMPOSE_VERSION+x} ]; then \
      COMPOSE_VERSION=$(curl -sX GET "https://api.github.com/repos/docker/compose/releases/latest" \
      | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  git clone https://github.com/docker/compose.git && \
  cd /compose && \
  git checkout "${COMPOSE_VERSION}" && \
  pip3 install virtualenv==20.0.30 && \
  pip3 install tox==3.19.0 && \
  PY_ARG=$(printf "$(python3 -V)" | awk '{print $2}' | awk 'BEGIN{FS=OFS="."} NF--' | sed 's|\.||g' | sed 's|^|py|g') && \
  sed -i "s|envlist = .*|envlist = ${PY_ARG},pre-commit|g" tox.ini && \
  tox --notest && \
  mkdir -p dist && \
  chmod 777 dist && \
  /compose/.tox/${PY_ARG}/bin/pip3 install -q -r requirements-build.txt && \
  echo "$(script/build/write-git-sha)" > compose/GITSHA && \
  export PATH="/compose/pyinstaller:${PATH}" && \
  /compose/.tox/${PY_ARG}/bin/pyinstaller --exclude-module pycrypto --exclude-module PyInstaller docker-compose.spec && \
  ls -la dist/ && \
  ldd dist/docker-compose && \
  mv dist/docker-compose /usr/local/bin && \
  docker-compose version

ARG HELM_VERSION=3.4.1
ARG KUBECTL_VERSION=1.19.0

RUN echo "curl -fsSL -o helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
    && curl -fsSL -o helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && tar xfvz helm.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf linux-amd64

RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o kubectl \
    && mv kubectl /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

RUN pip3 install ansible

FROM python:3.9.0-slim-buster

#COPY --from=build /compose/docker-compose-entrypoint.sh /usr/local/bin/docker-compose-entrypoint.sh
COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=build /usr/local/bin/docker-compose /usr/local/bin/docker-compose
COPY --from=build /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=build /usr/local/bin/helm /usr/local/bin/helm

#RUN pip3 install "backplane${BACKPLANE_VERSION:+==}${BACKPLANE_VERSION}"

RUN groupadd -g 1000 docker \
    && useradd -g docker -u 1000 docker
    #backplane init

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh
#ENTRYPOINT ["sh", "/usr/local/bin/docker-compose-entrypoint.sh"]
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
