#/bin/bash

for image in $(docker images --format "{{.Repository}}:{{.Tag}}")
do
  while true; do
    read -p "${image} : delete? (y/n/a):" yn
    case $yn in
      [yY]*) docker rmi ${image}; echo "deleted"; break ;;
      [nN]*) echo "not deleted"; break ;;
      [aA]*) echo "abort"; exit ;;
    esac
  done
done
