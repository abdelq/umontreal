#!/bin/sh

USERNAME=""
PASSWORD=""
COURSEID=""

# Authentication
HIDDEN_INPUTS=`curl -s https://identification.umontreal.ca/cas/login.aspx |
    grep hidden`
VIEWSTATE=`grep \"__VIEWSTATE\" <<< $HIDDEN_INPUTS | cut -d'"' -f 8`
EVENTVALIDATION=`grep \"__EVENTVALIDATION\" <<< $HIDDEN_INPUTS | cut -d'"' -f 8`

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

SESSKEY=`curl -s -b /tmp/umontreal https://studium.umontreal.ca |
    grep -oP "(?<=sesskey\":\")\w+"`

# Students
curl -b /tmp/umontreal -o students.csv -d "id=$COURSEID" \
    https://studium.umontreal.ca/grade/export/txt/export.php

# Homework
HOMEWORK=`curl -s -b /tmp/umontreal -G -d "id=$COURSEID" \
    https://studium.umontreal.ca/mod/assign/index.php |
    grep "assign/view" | grep -i "$1" | tail -n1`

HOMEWORK_ID=`grep -oP "(?<=id=)\d+" <<< $HOMEWORK`
HOMEWORK_NAME=`grep -oP "(?<=>)\w+(?=<)" <<< $HOMEWORK`

curl -b /tmp/umontreal -o "$HOMEWORK_NAME.zip" \
    -G -d "id=$HOMEWORK_ID" -d "action=downloadall" \
    https://studium.umontreal.ca/mod/assign/view.php
