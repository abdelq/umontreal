#!/bin/bash

# Usage: generate.sh assignment

for dir in "$1"/*
do
    STUDENTID=`basename $dir` # XXX
    grep '*' $dir/grade.md | awk -F/ 'BEGIN { GRADE=0 } { GRADE = GRADE + $1 } END { print $GRADE }' # XXX
done
