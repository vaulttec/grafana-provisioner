# Ansible playbook to provision Grafana organizations with datasource and LDAP group mapping

## Requirements
- Ansible v2.9+
- [Grafana community collection](https://docs.ansible.com/ansible/latest/collections/community/grafana) v1.5.4+
- [Kubernetes core](https://docs.ansible.com/ansible/latest/collections/kubernetes/core) v2.4.0+
- [Python client for Kubernetes](https://pypi.org/project/kubernetes/)
- URL and admin userid/password for Grafana instance
- `KUBECONFIG` referring to the corresponding Kubernetes cluster 


## Configuration
- List of tenants with LDAP group mappings (group cn and org role) in `tenants.yml` (sym-linked to `ansible/vars/tenants.yml` to included in Ansible playbook and `helm/tenants.yml` to be imported in k8s ConfigMap)
- Grafana URL and username / password as command-line parameters
- LDAP bind username / password as command-line parameters
- Kubernetes cluster in `KUBECONFIG`


## Usage
- Change directory
  ```
  cd ansible
  ```
- Install required dependencies (Kubernetes client, Grafana community collections) via
  ```
  pip install kubernetes
  ansible-galaxy collection install -r requirements.yml
  ```
- Execute playbook
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
