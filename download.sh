#!/bin/bash

# Usage: download.sh [assignment]

USERNAME=""
PASSWORD=""
COURSEID=

IDENTIFICATION=https://identification.umontreal.ca
STUDIUM=https://studium.umontreal.ca

# Verification
: ${USERNAME:?Required} # XXX
: ${PASSWORD:?Required} # XXX
: ${COURSEID:?Required} # XXX

# Authentication
HIDDENINPUTS=`curl -s $IDENTIFICATION/cas/login.aspx | grep hidden`
VIEWSTATE=`grep -oP 'VIEWSTATE" value="\K.*(?=")' <<< $HIDDENINPUTS`
EVENTVALIDATION=`grep -oP 'EVENTVALIDATION" value="\K.*(?=")' <<< $HIDDENINPUTS`

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

SESSKEY=`curl -s -b /tmp/umontreal $STUDIUM | grep -om 1 -P 'sesskey=\K\w+'`
: ${SESSKEY:?Invalid USERNAME or PASSWORD} # XXX

# Students
curl -b /tmp/umontreal -o students.csv -d "id=$COURSEID" \
    $STUDIUM/grade/export/txt/export.php

# Assignment
ASSIGNMENT=`curl -s -b /tmp/umontreal -G -d "id=$COURSEID" \
    $STUDIUM/mod/assign/index.php |
    grep "assign/view" | grep -i "$1" | tail -n1`

ASSIGNMENTID=`grep -oP "id=\K\d+" <<< $ASSIGNMENT`
ASSIGNMENTNAME=`grep -oP ">\K[\w\s]+(?=<)" <<< $ASSIGNMENT`

curl -b /tmp/umontreal -o "$ASSIGNMENTNAME.zip" \
    -G -d "id=$ASSIGNMENTID" -d "action=downloadall" \
    $STUDIUM/mod/assign/view.php
