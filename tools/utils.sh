#!/bin/bash

# Wait until server health endpoint shows ready. Sets WAIT_RET to 0 on
# success, 1 on failure
function wait_for_server_ready() {
    local spid="$1"; shift
    local wait_time_secs="${1:-30}"; shift

    WAIT_RET=0

    local wait_secs=$wait_time_secs
    until test $wait_secs -eq 0 ; do
        if ! kill -0 $spid; then
            echo "=== Server not running."
            WAIT_RET=1
            return
        fi

        sleep 1;

        set +e
        code=`curl -s -w %{http_code} localhost:8000/v2/health/ready`
        set -e
        if [ "$code" == "200" ]; then
            return
        fi

        ((wait_secs--));
    done

    echo "=== Timeout $wait_time_secs secs. Server not ready."
    WAIT_RET=1
}
