# Grafana Provisioner [![Build Status](https://github.com/vaulttec/grafana-provisioner/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/vaulttec/grafana-provisioner/actions/workflows/docker-publish.yml) [![Docker Image](https://img.shields.io/docker/pulls/tjuerge/grafana-provisioner.svg)](https://hub.docker.com/r/tjuerge/grafana-provisioner)

This project provides an Ansible playbook for provisioning a Grafana server running in Kubernetes. The playbook will provision
- Grafana organizations (defined in `tenants.yml`) with Loki data source
- Grafana LDAP configuration (stored in k8s secret `config-toml') with the organization's group mappings

The playbook can be executed manually or executed as a one-off job in Kubernetes via the provided Helm chart (e.g. for GitOps via ArgoCD).


## Requirements
- Ansible v2.9+
- [Grafana community collection](https://docs.ansible.com/ansible/latest/collections/community/grafana) v1.5.4+
- [Kubernetes core](https://docs.ansible.com/ansible/latest/collections/kubernetes/core) v2.4.0+
- [Python client for Kubernetes](https://pypi.org/project/kubernetes/)
- URL and admin userid/password for Grafana instance
- `KUBECONFIG` referring to the corresponding Kubernetes where cluster Grafana is running 


## Configuration
- List of tenants with LDAP group mappings (group cn and org role) in `tenants.yml` (sym-linked to `ansible/vars/tenants.yml` to included in Ansible playbook and `helm/tenants.yml` to be imported in k8s ConfigMap)
- Grafana URL and username / password (as command-line parameters or Helm values)
- LDAP bind username / password (as command-line parameters or Helm values)
- Kubernetes cluster in `KUBECONFIG`


## Usage

### Manual
The folder `ansible/` holds an Ansible playbook which can be executed manually from a command-line:
- Change directory
  ```
  cd ansible
  ```
- Install required dependencies (Kubernetes client, Grafana community collections) via
  ```
  pip install kubernetes
  ansible-galaxy collection install -r requirements.yml
  ```
- Execute playbook (configuration is defined in `ansible/vars/configuration.yml` or can be specified as command-line arguments)
  ```
  ansible-playbook provision-grafana.yml \
   -e k8s_namespace=<Kubernetes namespace with Grafana> \
   -e grafana_url=<grafana url> \
   -e grafana_username=<Grafana username> \
   -e grafana_password=<Grafana password> \
   -e grafana_environment=<name of environment: 'test' or 'prod'> \
   -e ldap_host=<LDAP host> \
   -e ldap_bind_dn=<LDAP bind user dn> \
   -e ldap_bind_password=<LDAP bind user password> \
   -e ldap_base_dn=<LDAP base dn>
  ```

### Kubernetes Job
The folder `helm/` holds a Helm chart for executing the Ansible playbook as a one-off job in Kubernetes:
- Create a values file with your configuration, e.g.
  ```yaml
  grafana:
    url: http://grafana/
    username: admin
    password: admin
    environment: "test"
  
    ldap:
      host: directory.acme.com
      bind_dn: cn=LDAP,OU=Users,DC=acme,DC=com
      bind_password: changeme
      base_dn: OU=Tenants,DC=acme,DC=com
  ```
- Use Helm to deploy the provisioner job to Kubernetes, e.g.
  ```
  helm install -f myvalues.yaml grafana-provisioner ./helm
  ```
