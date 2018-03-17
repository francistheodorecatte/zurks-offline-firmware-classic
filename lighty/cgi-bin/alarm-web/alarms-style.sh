#!/bin/sh
echo "Content-Type: text/css"
echo ""
cat $(dirname ${SCRIPT_FILENAME})/style.css
