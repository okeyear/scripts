# get the latest version
function get_github_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}
compose_ver=$(get_github_latest_release docker/compose)

# download latest
compose_url="https://github.com/docker/compose/releases/download/${compose_ver}/docker-compose-linux-$(arch)"
# compose_url="https://github.com/docker/compose/releases/download/${compose_ver}/docker-compose-$(uname -s)-$(uname -m)"
curl -SLO $compose_url

# install
sudo install docker-compose-linux-$(arch) /usr/bin/docker-compose

# install docker-compose bash command completion
sudo curl \
    -L https://raw.githubusercontent.com/docker/compose/${compose_ver}/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose
    
# check version
docker-compose version
