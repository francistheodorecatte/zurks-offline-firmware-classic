#!/bin/bash
# base64.sh -- Bash implementation of the Base64 encoding and decoding
# scheme
#
# Copyright (C) 2011 vladz <vladz@devzero.fr>
#
# Encode or decode original Base64 (and also Base64url) from standard input
# to standard output
#
# Usage:
#
#    Encode and decode a binary file:
#    $ ./base64.sh < binary-file > binary-file.base64
#    $ ./base64.sh -d < binary-file.base64 > binary-file
#
# Reference:
#
#    [1]  RFC4648 - "The Base16, Base32, and Base64 Data Encodings"
#         http://tools.ietf.org/html/rfc4648#section-5

# base64_charset[] array contains entire base64 charset and the complement
# character "="
base64_charset=( {A..Z} {a..z} {0..9} + / = )

# uncomment the following line to use base64url encoding instead of
# original base64
#base64_charset=( {A..Z} {a..z} {0..9} - _ = )

# output text width when encoding (64 characters is like openssl's output)
text_width=64

# convert a 6-bit number (between 0 and 63) into its corresponding values
# in Base64, and display the result with the predefined text width
function display_base64_char {

  printf "${base64_charset[$1]}"; (( width++ ))
  (( width % text_width == 0 )) && printf "\n"
}

# encode three 8-bit hexadecimal codes into four 6-bit numbers
function encode_base64 {

  # need two local int array variables:
  # c8[]: to store the codes of the 8-bit characters to encode
  # c6[]: to store the corresponding encoded values on 6-bit
  declare -a -i c8 c6

  # convert hexadecimal to decimal
  c8=( $(printf "ibase=16; ${1:0:2}\n${1:2:2}\n${1:4:2}\n" | bc) )

  # let's play with bitwise operators (3x8-bit into 4x6-bits conversion)
  (( c6[0] = c8[0] >> 2 ))
  (( c6[1] = ((c8[0] &  3) << 4) | (c8[1] >> 4) ))

  # next operations depends on c8's elements number
  case ${#c8[*]} in
    3) (( c6[2] = ((c8[1] & 15) << 2) | (c8[2] >> 6) ))
       (( c6[3] = c8[2] & 63 )) ;;
    2) (( c6[2] = (c8[1] & 15) << 2 ))
       (( c6[3] = 64 )) ;;
    1) (( c6[2] = c6[3] = 64 )) ;;
  esac

  for char in ${c6[@]}; do
    display_base64_char ${char}
  done
}

# decode four base64 characters into three hexadecimal ASCII characters
function decode_base64 {

  # c8[]: to store the codes of the 8-bit characters
  # c6[]: to store the corresponding Base64 values on 6-bit
  declare -a -i c8 c6

  # find decimal value corresponding to the current base64 character
  for current_char in ${1:0:1} ${1:1:1} ${1:2:1} ${1:3:1}; do
     [ "${current_char}" = "=" ] && break

     position=0
     while [ "${current_char}" != "${base64_charset[${position}]}" ]; do
        (( position++ ))
     done

     c6=( ${c6[*]} ${position} )
  done

  # let's play with bitwise operators (4x8-bit into 3x6-bits conversion)
  (( c8[0] = (c6[0] << 2) | (c6[1] >> 4) ))

  # next operations depends on c6's elements number
  case ${#c6[*]} in
    3) (( c8[1] = ( (c6[1] & 15) << 4) | (c6[2] >> 2) ))
       (( c8[2] = (c6[2] & 3) << 6 )); unset c8[2] ;;
    4) (( c8[1] = ( (c6[1] & 15) << 4) | (c6[2] >> 2) ))
       (( c8[2] = ( (c6[2] &  3) << 6) |  c6[3] )) ;;
  esac

  for char in ${c8[*]}; do
     printf "\x$(printf "%x" ${char})"
  done
}

# main
if [ $# -eq 0 ]; then   # encode

  # make a hexdump of stdin and reformat in 3-byte groups
  content=$(cat - | xxd -ps -u | sed -r "s/(\w{6})/\1 /g" | \
            tr -d "\n")

  for chars in ${content}; do encode_base64 ${chars}; done; echo

elif [ "$1" = "-d" ]; then   # decode

  # reformat stdin in pseudo "4x6-bit" groups
  content=$(cat - | tr -d "\n" | sed -r "s/(.{4})/\1 /g")

  for chars in ${content}; do decode_base64 ${chars}; done

else   # display usage

  printf "usage: $0 [-d]\n\n  -d\tdecode instead of encode\n\n"
fi

