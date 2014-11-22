#! /bin/sh
echo "+++++++++++++++++++ $@ +++++++++++++++++++"
set -x
TMP_BUILD=$1
srpm=$2
php=$3
yum -y install ant
yum -y reinstall glibc-common
localedef -v -c -i en_US -f UTF-8 en_US.UTF-8
export LANG=en_US.UTF-8
rpmbuild --target noarch --define "_topdir $TMP_BUILD" --define "php_base $php" --rebuild $srpm
