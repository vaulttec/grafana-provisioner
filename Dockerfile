FROM alpine:3.17

LABEL org.opencontainers.image.title="Grafana Provisioner" \
      org.opencontainers.image.description="Ansible playbook for provisioning a Grafana server running in Kubernetes" \
      org.opencontainers.image.authors="torsten.juergeleit@gmail.com" \
      org.opencontainers.image.url="https://hub.docker.com/repository/docker/tjuerge/grafana-provisioner" \
      org.opencontainers.image.source="https://github.com/vaulttec/grafana-provisioner" \
      org.opencontainers.image.license="Apache 2.0"

ARG ANSIBLE_VERSION=2.15.0
ARG UID=1000
ARG GID=1000

RUN apk add --update --no-cache \
        curl \
        python3 \
        py3-pip \
        py3-yaml && \
    pip3 install --upgrade pip wheel && \
    pip3 install ansible-core==${ANSIBLE_VERSION} kubernetes && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache/pip && \
    rm -rf /root/.cargo

RUN mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

RUN addgroup -g $GID ansible && \
    adduser -D -u $UID -G ansible ansible && \
    mkdir /ansible && \
    chown ansible:ansible /ansible

USER ansible
WORKDIR /ansible

RUN ansible-galaxy collection install \
        kubernetes.core \
        community.grafana

COPY --chown=ansible:ansible ansible /ansible

CMD [ "ansible-playbook", "--version" ]