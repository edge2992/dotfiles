#!/usr/bin/zsh

basename pwd
cd $1
g++ template.cpp -I /mnt/H/MYWORK/cpplib && oj test
