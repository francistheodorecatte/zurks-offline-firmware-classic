#!/bin/sh
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""
echo "SSH Server enabled"
/sbin/sshd
