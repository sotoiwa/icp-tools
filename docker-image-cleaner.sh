#/bin/bash

for image_str in $(docker images --format "{{.Repository}}:{{.Tag}}_{{.ID}}")
do
  while true
  do
    id=${image_str#*_}
    image=${image_str%_*}
    tag=${image##*:}
    read -p "${image}    delete? (y/n/a):" yn
    case $yn in
      [yY]*)
        if [ ${tag} = "<none>" ]; then
          docker rmi ${id}
        else
          docker rmi ${image}
        fi
        echo "deleted"; echo ""; break ;;
      [nN]*)
        echo "not deleted"; echo ""; break ;;
      [aA]*)
        echo "abort"; echo ""; exit ;;
    esac
  done
done
