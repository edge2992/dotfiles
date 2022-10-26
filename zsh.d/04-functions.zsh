# atcoder testing script
function act() {
  pushd $1
  g++ --std=c++17 -O2 template.cpp \
    -I /mnt/H/MYWORK/Algorithm/ac-library \
    -I /mnt/H/MYWORK/cpplib && oj test
  popd
}


# atcoder submiting script
function acs() {
  pushd $1
  oj-bundle -I /mnt/H/MYWORK/cpplib template.cpp > submit.cpp
  acc submit submit.cpp
  popd
}

