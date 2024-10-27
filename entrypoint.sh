#!/bin/sh

# Constants
CFG_DIR=/etc/unbound

# Global variables
ENV_VAR_NAMES=$(printenv | sed 's;=.*;;' | sort)


# Update root hints
/usr/bin/update-dns-root-hints


# Create DoT config
touch $CFG_DIR/dot.conf
if [ ! -z ${DOT_ENABLE+x} ]; then
    echo "include: /etc/unbound/default.dot.conf" > $CFG_DIR/dot.conf
fi


# Create forward zone config
touch $CFG_DIR/forward-zone.conf
if [[ "$ENV_VAR_NAMES" == "FORWARD_"* ]]; then
    FORWARD_SNIPPET='forward-zone:\n\tname: "."'
    if [ ! -z ${FORWARD_IS_TLS+x} ]; then
        FORWARD_SNIPPET="$FORWARD_SNIPPET\n\tforward-ssl-upstream: yes"
    fi
    for ENV_VAR_NAME in $ENV_VAR_NAMES; do
        if [[ $ENV_VAR_NAME == FORWARD_ADDR_* ]]; then
            FORWARD_SNIPPET="$FORWARD_SNIPPET\tforward-addr: $(printenv $ENV_VAR_NAME)\n"
        fi
    done
    echo -e "$FORWARD_SNIPPET" > $CFG_DIR/forward-zone.conf
fi


# Create access control config
touch $CFG_DIR/access-control.conf
if [[ "$ENV_VAR_NAMES" == "ACCESS_CONTROL_"* ]]; then
    for ENV_VAR_NAME in $ENV_VAR_NAMES; do
        if [[ $ENV_VAR_NAME == ACCESS_CONTROL_* ]]; then
            ACL_SNIPPET="$ACL_SNIPPET""access-control: $(printenv $ENV_VAR_NAME)\n"
        fi
    done
    echo -e "$ACL_SNIPPET" > $CFG_DIR/access-control.conf
fi


# Start Unbound
exec su-exec $PUID:$PGID /usr/sbin/unbound -d -p
