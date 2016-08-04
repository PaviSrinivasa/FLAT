#!/bin/bash
if [ $# -ne 2 ];then
  echo "Not enough parameters specified"
  echo "Please provide (1) user_bag_dir and (2) bundle"
  exit 1

else
 user_bag_dir=$1
 bundle=$2
fi

nFiles=$(find "$user_bag_dir/" -type f ! -name 'bag-info.txt' ! -name 'bagit.txt' ! -name '*manifest-md5.txt' | wc -l)

if [ $nFiles -eq 0 ];then
  echo "No files found to be zipped at $user_bag_dir/"
  exit 1
fi

# show number of files to be ingested
echo "nFiles to ingest: $nFiles"

#zip all unhidden files
cd "${user_bag_dir}"/..
zip -r ${bundle} ${bundle} -x ".*" -x "*/.*"

exit $?
