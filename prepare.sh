#!/bin/sh

unzip "$1" -d "${1/.zip/}" && rm "$1"

STUDENTS=`awk -F, '{ gsub(/"/, x); gsub(/\47/, x); print $3, $1, $2 }' students.csv`

for dir in "$1"/*
do
    # Rename to ID number
    STUDENT_NAME=`basename "${dir/_*/}"`
    STUDENT_ID=`grep "$STUDENT_NAME" <<< "$STUDENTS" | awk '{ print $1 }'`
    mv "$dir" "$1/$STUDENT_ID"

    # TODO Copy grading file
done
