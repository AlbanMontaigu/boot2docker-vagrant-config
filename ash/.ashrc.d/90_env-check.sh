
# =====================================================
# Various check regarding environment
#
# NOTE: need to occur lately in the bootstrap process
# =====================================================


# ------------------------------------------------------------
# Display information regarding versions
# ------------------------------------------------------------
version_check(){

    # Need to wait to be sure that user see that on the shell
    sleep 5

    # Get remote version (latest)
    B2D_EXT_LATEST_VERSION=$(curl -m15 -skL https://raw.githubusercontent.com/AlbanMontaigu/boot2docker-vagrant-extension/latest/VERSION)

    # Error management
    if [ $? != 0 ]; then
        return 1
    fi

    # Display information
    if ([[ "${B2D_EXT_LATEST_VERSION}" == "${B2D_EXTENSION_VERSION}" ]]); then
        echo "[INFO] Congratulations ! You have the last version of boot2docker extension (${B2D_EXTENSION_VERSION})"
        return 0
    else
        echo "[INFO] You may consider checking your boot2docker extension version (yours=${B2D_EXTENSION_VERSION}, latest=${B2D_EXT_LATEST_VERSION})"
        return 2
    fi
}

# Do the check but not blocking
version_check&
