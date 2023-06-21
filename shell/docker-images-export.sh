#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en

# exit shell when error
# set -e

function docker_image_export(){
  docker images | grep -v REPOSITORY | while read line
  do 
    # filename:
    # <repo>:<version>:<image_id>.tar , replace:
    # / --> +
    # : --> @
    # after replace: <repo>@<version>@<image_id>.tar
    local filename=$( echo $line | awk '{print $1":"$2":"$3".tar"}' | sed 's|:|@|g ; s|/|+|g' )
    image_id=$( echo $line | awk '{print $3}' )
    echo "docker save $image_id -o ${filename}"
    docker save $image_id -o ${filename}
  done
}

# For example:
# docker save 4f41f23e6002 -o mcr.microsoft.com+powershell@latest@4f41f23e6002.tar
# docker save 9c7a54a9a43c -o hello-world@latest@9c7a54a9a43c.tar
# docker save cc44224bfe20 -o nginx@alpine@cc44224bfe20.tar
# docker save f9e320b7e19c -o rancher+rancher@latest@f9e320b7e19c.tar



function docker_image_import(){
  ls *@*.tar | while read line
  do 
    # phase filename
    # delete .tar # mcr.microsoft.com+powershell@latest@4f41f23e6002.tar --> mcr.microsoft.com+powershell@latest@4f41f23e6002
    local filename=${line/.tar/}
    image_id=${filename##*@}
    # delete @4f41f23e6002 # mcr.microsoft.com+powershell@latest@4f41f23e6002 --> mcr.microsoft.com+powershell@latest
    filename=${filename/@$image_id/}
    local version=${filename##*@}
    # delete @latest # mcr.microsoft.com+powershell@latest --> mcr.microsoft.com+powershell
    local repo=${filename/@$version/}
    # replace + --> / # mcr.microsoft.com+powershell --> mcr.microsoft.com/powershell
    repo=$( echo ${repo} | sed 's|+|/|g' )
    echo "docker import ${line}"
    docker import ${line}
    docker tag ${image_id} "${repo}:${version}"
    echo "docker tag ${image_id} $repo:$version"
  done
}

# docker import hello-world@latest@9c7a54a9a43c.tar
# docker tag 9c7a54a9a43c hello-world:latest
# docker import mcr.microsoft.com+powershell@latest@4f41f23e6002.tar
# docker tag 4f41f23e6002 mcr.microsoft.com/powershell:latest
# docker import nginx@alpine@cc44224bfe20.tar
# docker tag cc44224bfe20 nginx:alpine
# docker import rancher+rancher@latest@f9e320b7e19c.tar
# docker tag f9e320b7e19c rancher/rancher:latest
