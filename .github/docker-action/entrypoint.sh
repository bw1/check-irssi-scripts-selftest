#!/bin/sh -l
#
#  begin
#
echo "Hello $1"
time=$(date)
echo "::set-output name=time::$time"
