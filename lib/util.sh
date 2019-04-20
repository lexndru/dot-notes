# Copyright (c) 2019 Alexandru Catrina <alex@codeissues.net>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

export UTILSH_HOMEPAGE=http://github.com/lexndru/util-sh

# Perform a check for user's $HOME environment variable. Returns 0 if found
# otherwise 1
has_home () {
    if [ ! -z "$HOME" ]; then
        return 0
    fi
    return 1
}

# Tests if a given argument is a number or not. It handles missing arguments
# as empty strings and returns 0 if it's a number otherwise 1.
is_number () {
    local num="$1"

    if [ ! -z "$num" ]; then
        case $num in
            ''|*[!0-9]*) return 1 ;;
            *) return 0 ;;
        esac
    fi

    return 1
}

# Transforms all arguments into lowercase strings. Outputs a line per
# argument or nothing if no argument is provided. Always exists with 0.
lowercase () {
    for str in "$@"; do
        echo "$str" | tr '[:upper:]' '[:lower:]'
    done
}

# Prompt a custom question to user and await for a "Yes" or "No"
# answer. At least one argument must be passed (the question message).
# A secondary argument is used as a default choice. If no argument is
# provided an error message is flushed to stderr, otherwise it returns
# 0 for "Yes" and 1 for "No".
question () {
    if [ $# -eq 0 ]; then
        echo "Question message is missing" >&2
        exit 100
    fi

    local message="$1"
    local default="$2"

    while true; do
        if [ "$default" = "y" ] || [ "$default" = "yes" ]; then
            read -p "$message [Yn] " answer
            if [ -z "$answer" ]; then
                answer="yes"
            fi
        elif [ "$default" = "n" ] || [ "$default" = "no" ]; then
            read -p "$message [yN] " answer
            if [ -z "$answer" ]; then
                answer="no"
            fi
        else
            read -p "$message [yn] " answer
        fi

        answer="$(lowercase "$answer")"

        case $answer in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) {
                echo "Cannot understand answer... Please answer with Yes or No"
            } ;;
        esac

    done

    echo "Cannot process answer" >&2
    exit 101
}
