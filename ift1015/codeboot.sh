#!/bin/bash

CODEBOOT="http://www-labs.iro.umontreal.ca/~codeboot/codeboot"

FILE="@C$(basename "$1")@0$(sed ':a;N;$!ba;s/@/@@/g;s/\r//g;s/\n/@N/g' "$1")@E"
xdg-open "$CODEBOOT/query.cgi?REPLAY=$(base64 <<< $FILE)"
