#!/bin/bash
sudo labauto ansible
ansible-pull -i localhost, -U https://github.com/nikkaushal/wmp-ansible-rds-v4.git main.yml -e env=${ENV} -e COMPONENT=${COMPONENT} -e postres_rds_address=${postres_rds_address}
