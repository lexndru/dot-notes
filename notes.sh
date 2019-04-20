#!/bin/bash
#
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

source lib/util.sh

export NOTES_BIN=$HOME/bin
export NOTES_SCRIPT=notes
export HOMEPAGE=http://github.com/lexndru/dot-notes

# check env
if ! has_home; then
    echo "Cannot find user home directory as \$HOME"
    echo "Please fix this and try again"
    exit 1
fi

# check license
if [ ! -f LICENSE ]; then
    echo "Cannot find LICENSE file..."
    echo "Please fix this and try again"
    exit 1
fi

# prepare env
if [ ! -d "$NOTES_BIN" ]; then
    echo "A new \"bin\" directory will be created in your $HOME directory"
    if question "Continue?" y; then
        if ! mkdir -p "$NOTES_BIN"; then
            echo "Cannot create directory... Please create $NOTES_BIN and try again"
            exit 1
        else
            echo "Successfully created directory $NOTES_BIN"
            if ! (echo $PATH | grep $NOTES_BIN); then
                if [ -f "$HOME/.profile" ]; then
                    echo "export PATH=\"\$PATH:\$HOME/bin\"" >> $HOME/.profile
                    echo "Updated \$PATH with $NOTES_BIN"
                else
                    echo "Cannot update \$PATH... Please add $NOTES_BIN to \$PATH and try again"
                fi
                source $HOME/.profile
            fi
        fi
    else
        echo "Install cannot continue"
        echo "Closing... Bye"
        exit 0
    fi
fi

# build script
cat > $NOTES_SCRIPT <<EOF
#!/bin/bash
#
EOF

# append license to wrapper
cat LICENSE | while read line; do
    echo "# $line" >> $NOTES_SCRIPT
done

# main script
cat >> $NOTES_SCRIPT <<EOF

known_editors="nano vim vi emacs ed"

# output help message
help_message () {
    echo "A simple command line application to take notes"
    echo ""
    echo "It stores your data in a local hidden file called \".notes\" and"
    echo "it uses an existing text editor to open and edit data. If editor"
    echo "is not available on system then it fallbacks to a read-only view"
    echo ""
    echo "  Homepage: $HOMEPAGE"
    echo ""
    echo "  Usage:"
    echo "   notes \"message here\"      - adds new note"
    echo "   notes --help              - this message"
    echo "   notes .                   - open for view/edit"
    echo ""
}

# try to edit notes or just display on screen
open_notes () {

    # fallback to view only
    if [ -z "\$EDITOR" ]; then
        echo "You have \$(wc -l .notes | cut -f1 -d ' ') notes (read-only)"
        EDITOR=cat
    fi

    # open notes
    \$EDITOR .notes

    # successfully saved?
    if [ \$? -eq 0 ]; then
        echo "Saved notes"
        return 0
    else
        echo "Failed to save notes!"
        return 1
    fi
}

# help user ...
if [ \$# -eq 0 ] || [ "x\$1" = "x--help" ]; then
    help_message && exit 0
fi

# check for notes file and create if not exists
if [ ! -f .notes ]; then
    touch .notes
fi

# find user's favorite editor
if [ -z "\$EDITOR" ]; then
    # if user doesn't have a favorite editor
    # lookup whatever exists on system and
    # get first one found
    for each in \$(echo \$known_editors); do
        editor="\$(command -v \$each)"
        if [ \$? -eq 0 ]; then
            EDITOR="\$editor"
            break
        fi
    done
fi

if [ "x\$1" = "x." ]; then
    if ! open_notes; then
        echo "Text editor has exit with non-zero status code"
        echo "Your changes may be lost..."
        exit 1
    else
        exit 0
    fi
else
    echo "\$@" >> .notes
    echo "Saved new note"
    exit 0
fi

# unsupported arguments...
help_message
EOF

# move script to $HOME
if ! mv $NOTES_SCRIPT $NOTES_BIN/$NOTES_SCRIPT; then
    echo "Cannot install script"
    echo "Please check permissions and try again"
    exit 1
fi

# make executable
if ! chmod +x $NOTES_BIN/$NOTES_SCRIPT; then
    echo "Cannot make script executable"
    echo "Please check permissions and try again"
    exit 1
fi

# end of install
echo "Successfully installed $NOTES_SCRIPT script"
