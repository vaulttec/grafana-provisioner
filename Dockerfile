FROM alpine:3.17

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

COPY ansible /ansible

CMD [ "ansible-playbook", "--version" ]