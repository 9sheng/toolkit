#!/bin/bash

RED='\033[31m'
GREEN='\033[32m'
CCLR='\033[0m'

if [ $# -ne 3 ]; then
    echo "Usage: svn-auto-merge BRANCH TRUNK COMMENTS"
    exit 1
fi

BRANCH=$1
TRUNK=$2
COMMENTS=$3

# NOTE: $WORKDIR will be deleted first
WORKDIR=auto-merge-workspace
rm -rf ${WORKDIR}

# if you don't want to input password, alias svn
#alias svn='svn --username liulin --password 123456'

echo "=========================================================================="
echo -e "Checkout files from trunk ${GREEN}${TRUNK}${CCLR}"
svn co ${TRUNK} ${WORKDIR} >/dev/null

echo "=========================================================================="
echo -e "Override trunk with ${GREEN}${BRANCH}${CCLR}"
rm -rf ${WORKDIR}/*
svn export --force ${BRANCH} ${WORKDIR}

echo "=========================================================================="
echo -e "${RED}svn status${CCLR}"
svn status ${WORKDIR}

echo "=========================================================================="
BRANCH_NAME=$(echo ${BRANCH} | awk -F'/' '{print $NF}')
FULL_COMMENTS="merge ${BRANCH_NAME}: ${COMMENTS}"

echo -ne "Commit with comments ${GREEN}${FULL_COMMENTS}${CCLR}, "
read -p "[y/N]? "

if [ "${REPLY}" == 'y' -o "${REPLY}" == 'yes' ]; then
    svn commit ${WORKDIR} -m "${FULL_COMMENTS}"
else
    echo "Please commit manually."
fi
