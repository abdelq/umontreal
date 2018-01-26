#!/bin/sh

rm /tmp/umontreal.json 2> /dev/null

HIDDEN_INPUTS=`http https://identification.umontreal.ca/cas/login.aspx | grep hidden`
VIEWSTATE=`grep id=\"__VIEWSTATE\" <<< $HIDDEN_INPUTS | cut -d'"' -f 8`
EVENTVALIDATION=`grep id=\"__EVENTVALIDATION\" <<< $HIDDEN_INPUTS | cut -d'"' -f 8`

http --session=/tmp/umontreal.json -f POST https://identification.umontreal.ca/cas/login.aspx \
  Content-Type:application/x-www-form-urlencoded \
  __VIEWSTATE="$VIEWSTATE" \
  txtIdentifiant=dsfsdaf \
  txtMDP=adsfasdf \
  btnValider=Valider \
  __EVENTVALIDATION="$EVENTVALIDATION"

http --follow --session=/tmp/umontreal.json https://identification.umontreal.ca/cas/login.ashx \
    service=="https://studium.umontreal.ca/login/index.php" \
    gateway=="true"

# Do whatever here...

http --session=/tmp/umontreal.json "https://studium.umontreal.ca/course/view.php?id=123456789" | htmlfmt