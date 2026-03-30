#!/bin/bash
sudo labauto ansible
ansible-pull -i localhost, -U https://github.com/nikkaushal/wmp-ansible-templates-v3.git main.yml -e env=${ENV} -e COMPONENT=${COMPONENT}
