#!/bin/sh

USERNAME="p0000000"
PASSWORD="123456"

# Authentication
HIDDEN_INPUTS=`curl https://identification.umontreal.ca/cas/login.aspx | grep hidden`
VIEWSTATE=`grep \"__VIEWSTATE\" <<< $HIDDEN_INPUTS | cut -d'"' -f 8` # XXX
EVENTVALIDATION=`grep \"__EVENTVALIDATION\" <<< $HIDDEN_INPUTS | cut -d'"' -f 8` # XXX

curl -s -o /dev/null \
    -c /tmp/umontreal \
    --data-urlencode "txtIdentifiant=$USERNAME" \
    --data-urlencode "txtMDP=$PASSWORD" \
    --data-urlencode "__VIEWSTATE=$VIEWSTATE" \
    --data-urlencode "__EVENTVALIDATION=$EVENTVALIDATION" \
    --data-urlencode "btnValider=Valider" \
    https://identification.umontreal.ca/cas/login.aspx

curl -s -o /dev/null \
    -c /tmp/umontreal -b /tmp/umontreal \
    -L -G -d "service=https://studium.umontreal.ca/login/index.php" \
    https://identification.umontreal.ca/cas/login.ashx

# TODO
curl -b /tmp/umontreal \
    -G -d "id=123456" \
    https://studium.umontreal.ca/course/view.php | htmlfmt