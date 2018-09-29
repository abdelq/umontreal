#!/bin/bash

# Usage: download.sh course [assignment]
# XXX course corresponds to the course id (see URL of course)
# XXX assignment corresponds to the name of the assignment

IDENTIFICATION=https://identification.umontreal.ca
STUDIUM=https://studium.umontreal.ca

# Authentication
while [ -z "$USERNAME" ]; do
    read -p "Code d'accès : " -r USERNAME
done
while [ -z "$PASSWORD" ]; do
    read -p "UNIP / mot de passe : " -rs PASSWORD
done

HIDDENINPUTS=$(curl -s $IDENTIFICATION/cas/login.aspx | grep hidden)
VIEWSTATE=$(grep -oP 'VIEWSTATE" value="\K.*(?=")' <<< "$HIDDENINPUTS")
EVENTVALIDATION=$(grep -oP 'EVENTVALIDATION" value="\K.*(?=")' <<< "$HIDDENINPUTS")

curl -s -o /dev/null -c /tmp/umontreal \
    --data-urlencode "txtIdentifiant=$USERNAME" \
    --data-urlencode "txtMDP=$PASSWORD" \
    --data-urlencode "__VIEWSTATE=$VIEWSTATE" \
    --data-urlencode "__EVENTVALIDATION=$EVENTVALIDATION" \
    --data-urlencode "btnValider=Valider" \
    $IDENTIFICATION/cas/login.aspx

curl -s -o /dev/null -c /tmp/umontreal -b /tmp/umontreal \
    -LG -d "service=$STUDIUM/login/index.php" \
    $IDENTIFICATION/cas/login.ashx

# TODO Verify the user is logged in

# TODO Allow selecting COURSEID by name
COURSEID=$1

# Students
curl -b /tmp/umontreal -o students.csv -d "id=$COURSEID" \
    $STUDIUM/grade/export/txt/export.php

# Assignment
ASSIGNMENT=$(curl -s -b /tmp/umontreal -G -d "id=$COURSEID" \
    $STUDIUM/mod/assign/index.php |
    grep "assign/view" | grep -i "$2" | tail -n1)

ASSIGNMENTID=$(grep -oP "id=\\K\\d+" <<< "$ASSIGNMENT")
ASSIGNMENTNAME=$(grep -oP "<a href=\".*\">\\K.+(?=<\\/a>)" <<< "$ASSIGNMENT")

echo "$ASSIGNMENTNAME"

curl -b /tmp/umontreal -o "$ASSIGNMENTNAME.zip" \
    -G -d "id=$ASSIGNMENTID" -d "action=downloadall" \
    $STUDIUM/mod/assign/view.php
