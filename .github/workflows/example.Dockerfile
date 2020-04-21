FROM jupyter/datascience-notebook

apt-get -y update
apt-get -y install openmpi-'*' libopenmpi-'*'
apt-get -y install ssh

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
