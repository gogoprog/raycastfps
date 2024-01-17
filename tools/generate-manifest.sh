#!/bin/sh

cd $1
find -type f | cut -c 3- > manifest.txt

