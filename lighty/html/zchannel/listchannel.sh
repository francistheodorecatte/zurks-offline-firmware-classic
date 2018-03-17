#!/bin/bash

find $* -name '*.app' \( -exec ./cat.sh "$PWD"/{} \; -o -print \)

