# syntax=docker/dockerfile-upstream:master-labs

ARG BUILDER_IMAGE
ARG RUNTIME_IMAGE

FROM quay.io/vexxhost/bindep-loci:latest AS bindep

FROM ${BUILDER_IMAGE} AS builder
COPY --from=bindep --link /runtime-pip-packages /runtime-pip-packages

FROM ${RUNTIME_IMAGE} AS runtime
COPY --from=bindep --link /runtime-dist-packages /runtime-dist-packages
COPY --from=builder --link /var/lib/openstack /var/lib/openstack
RUN <<EOF /bin/bash
  set -xe
  apt-get update
  apt-get install -y --no-install-recommends wget
  wget --no-check-certificate \
    https://github.com/zmartzone/mod_auth_openidc/releases/download/v2.4.12.1/libapache2-mod-auth-openidc_2.4.12.1-1.$(lsb_release -sc)_amd64.deb
  apt-get -y --no-install-recommends install \
    ./libapache2-mod-auth-openidc_2.4.12.1-1.$(lsb_release -sc)_amd64.deb
  rm -rfv \
    ./libapache2-mod-auth-openidc_2.4.12.1-1.$(lsb_release -sc)_amd64.deb
  apt-get purge -y wget
  apt-get clean
  rm -rf /var/lib/apt/lists/*
EOF
