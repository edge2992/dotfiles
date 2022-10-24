#!/bin/bash
contest=$(basename $(pwd))
cd $1
oj-bundle -I /mnt/H/MYWORK/cpplib template.cpp > submit.cpp
oj s "https://atcoder.jp/contests/${contest}/tasks/${contest}_$1" submit.cpp
