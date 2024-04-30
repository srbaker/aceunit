#!/bin/sh

hasBash5() {
    command -v bash >/dev/null 2>&1 && [ "$(bash --version | head -n1 | cut -d" " -f4 | cut -d"." -f1)" -ge 5 ]
}

case "$1" in
    "")
        if [ "$(uname)" = "Darwin" ]; then
            SHELL_TO_SET=zsh
        elif [ "$(uname)" = "Linux" ]; then
            SHELL_TO_SET=bash
        elif hasBash5 >/dev/null 2>&1; then
            SHELL_TO_SET=bash
        elif command -v zsh >/dev/null 2>&1; then
            SHELL_TO_SET=zsh
        else
            SHELL_TO_SET=bash
        fi
        ;;
    bash|zsh)
        SHELL_TO_SET=$1
        ;;
    *)
        echo "Unsupported shell '$1', aborting"
        exit 1
        ;;
esac

#if sed --version >/dev/null 2>/dev/null && sed --version 2>&1 | grep GNU >/dev/null; then
#    sed -i '1s|.*|#!/usr/bin/env '"$SHELL_TO_SET"'|' bin/aceunit
#else
#    sed -i .bak '1s|.*|#!/usr/bin/env '"$SHELL_TO_SET"'|' bin/aceunit
#fi

echo "Selecting $SHELL_TO_SET to run aceunit" 1>&2

ed -s bin/aceunit <<EOF
1s|#!/usr/bin/env [[:alnum:]]*|#!/usr/bin/env $SHELL_TO_SET|
w
q
EOF
