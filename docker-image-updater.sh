#/bin/bash

for image in $(docker images --format "{{.Repository}}:{{.Tag}}")
do
  tag=${image##*:}
  if [ ${tag} = "<none>" ]; then
    continue
  else
    docker pull ${image}
  fi
done
