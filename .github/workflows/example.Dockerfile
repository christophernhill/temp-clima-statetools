FROM jupyter/datascience-notebook

apt-get -y update
apt-get -y install openmpi-'*' libopenmpi-'*'
apt-get -y install ssh
