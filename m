#!/bin/sh

# m
# File ID: 198c1404-9e4c-11e7-812f-f74d993421b0

make clean test valgrind 2>&1 | unbuffer -p grep -v ^ok
