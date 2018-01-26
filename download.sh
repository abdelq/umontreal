#!/bin/sh

# TODO Better explanation
# Syntax: ./download.sh NomExercice
# Si le nom de l'exercice n'est pas inclus, chercher le dernier

USERNAME=""
PASSWORD=""
HOMEWORKS_ID=""

# Authentication
HIDDEN_INPUTS=`curl -s https://identification.umontreal.ca/cas/login.aspx | grep hidden`
VIEWSTATE=`grep \"__VIEWSTATE\" <<< $HIDDEN_INPUTS | cut -d'"' -f 8` # XXX
EVENTVALIDATION=`grep \"__EVENTVALIDATION\" <<< $HIDDEN_INPUTS | cut -d'"' -f 8` # XXX

curl -s -o /dev/null -c /tmp/umontreal \
    --data-urlencode "txtIdentifiant=$USERNAME" \
    --data-urlencode "txtMDP=$PASSWORD" \
    --data-urlencode "__VIEWSTATE=$VIEWSTATE" \
    --data-urlencode "__EVENTVALIDATION=$EVENTVALIDATION" \
    --data-urlencode "btnValider=Valider" \
    https://identification.umontreal.ca/cas/login.aspx

curl -s -o /dev/null -c /tmp/umontreal -b /tmp/umontreal \
    -LG -d "service=https://studium.umontreal.ca/login/index.php" \
    https://identification.umontreal.ca/cas/login.ashx

# Homework
HOMEWORK=`curl -s -b /tmp/umontreal -G -d "id=$HOMEWORKS_ID" \
    https://studium.umontreal.ca/mod/assign/index.php |
    grep "assign/view" | grep -i "$1" | tail -n1`

HOMEWORK_ID=`grep -oP "(?<=id=)\d+" <<< $HOMEWORK`
HOMEWORK_NAME=`grep -oP "(?<=>)\w+(?=<)" <<< $HOMEWORK`

curl -b /tmp/umontreal -G -d "id=$HOMEWORK_ID" -d "action=downloadall" \
    https://studium.umontreal.ca/mod/assign/view.php > "$HOMEWORK_NAME.zip"

unzip "$HOMEWORK_NAME" -d "$HOMEWORK_NAME" && rm "$HOMEWORK_NAME.zip"
