---
- hosts: ${ansible_host}
  become: yes
  gather_facts: yes
  tasks:
    - import_tasks: update_and_install_packages.yml
    - import_tasks: setup_docker.yml
    - import_tasks: setup_yace.yml