#!/bin/bash
scriptdir=$(dirname $0)
if [ -z "$1" ]; then
  echo "title required"
  exit 1
fi

d=$(date "+%Y-%m-%d-")
time=$(date "+%Y-%m-%d %H:%M:%S")
targetfile=${scriptdir}/src/documents/article/${d}${1}.html.md

touch ${targetfile} || exit 1
cat > ${targetfile} <<EOF
---
layout: post
title: 
tags: 
date: '#date#'
udate: '#date#'
category: 
---
EOF
sed -i "s/#date#/${time}/g" ${targetfile} && vi ${targetfile}
exit 0
