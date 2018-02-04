#/bin/bash

FILE="@C$(basename "$1")@0$(sed ':a;N;$!ba;s/\n/@N/g' "$1")@E"
firefox "codeboot.org/query.cgi?REPLAY=$(base64 <<< $FILE)"
