
# ============================================================
# Docker custom commands
# ============================================================


# ------------------------------------------------------------
# Docker proxy helper commands
# ------------------------------------------------------------

# Get all proxy flags in a docker cmd line friendly format
dk_proxy_flags(){
    prx_env="-e "$(env | grep HTTP_PROXY)
    prx_env=$prx_env" -e "$(env | grep http_proxy)
    prx_env=$prx_env" -e "$(env | grep NO_PROXY)
    prx_env=$prx_env" -e "$(env | grep no_proxy)
    echo "${prx_env}"
}

# Integrated help for proxy flags
dk_proxy_flags_help(){
    echo "Usage: dk proxy flags"
    echo ""
    echo "Get all proxy flags in a docker cmd line friendly format."
}

# Proxy update for docker daemon with current prx env vars
dk_proxy_update() {
    
    # First Docker before all
    sudo /etc/init.d/docker stop
    sleep 1

    # Apply http_proxy configuration to all directive for docker engine
    for DIRECTIVE in http_proxy https_proxy HTTP_PROXY HTTPS_PROXY; do
        sudo sed -i 's#export '${DIRECTIVE}'=.*$#export '${DIRECTIVE}'='$( eval echo \$${DIRECTIVE})'#g' /var/lib/boot2docker/profile
    done

    # Start Docker to apply change
    sudo /etc/init.d/docker start
    sleep 1
}

# Integrated help for proxy update
dk_proxy_update_help(){
    echo "Usage: dk proxy update"
    echo ""
    echo "Update proxy configuration for docker daemon with current environment proxy."
}

# Direct access for command help
dk_proxy_help(){
    case "$1" in
        flags) dk_proxy_flags_help
            ;;
        update) dk_proxy_update_help
            ;;
        *) dk_proxy_usage
            ;;
    esac
}

# Command usage
dk_proxy_usage(){
    echo
    echo "dk proxy = commands helper to manage proxy concerns for docker."
    echo
    echo "dk proxy commands:"
    echo "    flags     Get all proxy flags in a docker cmd line friendly format"
    echo "    update    Update proxy configuration for docker daemon with current environment proxy"
    echo "    help      Give help including a subcommand"
}

# Proxy command switch
dk_proxy(){
    case "$1" in
        flags) dk_proxy_flags
            ;;
        update) dk_proxy_update
            ;;
        help) dk_proxy_help "$2"
            ;;
        *) dk_proxy_usage
            ;;
    esac
}


# ------------------------------------------------------------
# Docker dk-toolbox command
# ------------------------------------------------------------
dk_toolbox(){

    # Update case
    if [[ "$1" == "update" ]]; then
        sx docker pull amontaigu/docker-toolbox:$DKTB_VERSION
        return
    fi

    # Extension management
    if [[ "$1" == "extension" ]]; then
        dk_toolbox_extension "$2"
        return
    fi

    # Default command
    if [[ "$DKTB_EXTENSION_STATUS" == "ON" ]]; then
        sx docker run -it --rm  \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    -v /vagrant:/vagrant \
                    -w="/vagrant" \
                    -e COMPOSE_PROJECT_NAME="$COMPOSE_PROJECT_NAME" \
                    -e DKTB_EXTENSION_REPO="$DKTB_EXTENSION_REPO" \
                    -e DKTB_EXTENSION_VERSION="$DKTB_EXTENSION_VERSION" \
                    amontaigu/docker-toolbox:$DKTB_VERSION
    else
            sx docker run -it --rm  \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -v /vagrant:/vagrant \
                -w="/vagrant" \
                -e COMPOSE_PROJECT_NAME="$COMPOSE_PROJECT_NAME" \
                amontaigu/docker-toolbox:$DKTB_VERSION
    fi
}

# Extension management for toolbox
dk_toolbox_extension(){
    case "$1" in
        on) export DKTB_EXTENSION_STATUS="ON"
            ;;
        off) export DKTB_EXTENSION_STATUS="OFF"
            ;;
        *) echo "DKTB_EXTENSION_STATUS=$DKTB_EXTENSION_STATUS"
            ;;
    esac
}

dk_toolbox_help(){
    echo "Usage: dk toolbox/tb [update/extension] [if extension change: on/off]"
    echo ""
    echo "Start a container from amontaigu/docker-toolbox image and go into it."
}


# ------------------------------------------------------------
# Show docker usage + information about custom commands
# ------------------------------------------------------------
dk_custom_usage(){
    echo
    echo "dk = docker alias with enhancements."
    echo
    docker | sed 's/docker/dk/g'
    echo
    echo "Custom dk commands:"
    echo "    toolbox   Start a container from amontaigu/docker-toolbox image and go into it"
    echo "    tb        See toolbox subcommand"
    echo "    proxy     Docker proxy management helper"
}


# ------------------------------------------------------------
# Help complements
# ------------------------------------------------------------
dk_help(){
    case "$1" in
        toolbox) dk_toolbox_help
            ;;
        tb) dk_toolbox_help
            ;;
        proxy) dk_proxy_help
            ;;
        "--help") docker
            ;;
        "") docker
            ;;
        *) docker "$@" --help
            ;;
    esac
}


# ------------------------------------------------------------
# Docker command plus new features for it
# ------------------------------------------------------------
dk(){
    eval last_arg=\${$#}
    if [[ "$last_arg" == "--help" ]] ; then
        dk_help "$1"
        return 0
    fi
    case "$1" in
        toolbox) dk_toolbox "$2"
            ;;
        tb) dk_toolbox "$2"
            ;;
        proxy) dk_proxy "$2"
            ;;
        "") dk_custom_usage
            ;;
        *) sx docker "$@"
            ;;
    esac
}
