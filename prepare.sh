#!/bin/bash

# Usage: prepare.sh assignment[.zip]

ASSIGNMENT="${1/.zip/}"

# Extract
unzip "$1" -d "$ASSIGNMENT" && rm "$ASSIGNMENT.zip"

STUDENTS=`cat students.csv | tr -d \'\" | awk -F, '{ print $3, $1, $2 }'`
for dir in "$ASSIGNMENT"/*
do
    # Copy grading file
    cp grade.md "$dir"

    # Rename directory to ID number
    STUDENT_NAME=`basename "${dir/_*/}"` # XXX
    STUDENT_ID=`grep "$STUDENT_NAME" <<< "$STUDENTS" | awk '{ print $1 }'` # XXX
    mv "$dir" "$ASSIGNMENT/$STUDENT_ID"
done
