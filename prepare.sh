#!/bin/bash

# Usage: prepare.sh assignment[.zip]

if [[ $# -eq 0 ]] ; then
    echo "Besoin de l'archive .zip comme argument"
    exit 1
fi

ASSIGNMENT="${1/.zip/}"

# Extract
unzip "$1" -d "$ASSIGNMENT" # && rm "$ASSIGNMENT.zip"

STUDENTS=`cat *.csv | tr -d \'\" | awk -F, '{ print $3, $1, $2 }'`
for dir in "$ASSIGNMENT"/*
do
    # Rename directory to ID number
    STUDENT_NAME=`basename "${dir/_*/}"` # XXX
    STUDENT_ID=`grep "$STUDENT_NAME" <<< "$STUDENTS" | awk '{ print $1 }'` # XXX
    mv "$dir" "$ASSIGNMENT/$STUDENT_ID"
done

find "$ASSIGNMENT" -name "*.zip" | while read filename; do unzip -o -d "`dirname "$filename"`" "$filename" && rm "$filename"; done;
find "$ASSIGNMENT" -name "*.rar" | while read filename; do unrar e "$filename" "`dirname "$filename"`" && rm "$filename"; done;
