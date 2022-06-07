#!/bin/bash

# set context
zed context set poc localhost:50051 "authzedpoc" --insecure

# vars
NUM_SUPERUSER=100
NUM_STAFF=1000
NUM_FILES_IN_ROOT=10
FOLDER_DEPTH=10

if [ $1 ]
then
  NUM_ENTITIES=$1
else
  NUM_ENTITIES=10
fi

if [ $2 ]
then
  OFFSET=$2
else
  OFFSET=0
fi

if [ $OFFSET == 0 ]
then
  # create superuser group - cds/carta_user:1-5 are superusers
  for (( i=1; i<=NUM_SUPERUSER; i++)) 
    do
      zed relationship create cds/usergroup:superuser member cds/carta_user:superuser_$i
      echo "Added cds/carta_user:superuser_$i member cds/usergroup:superuser"
  done 

  # create staff group - cds/carta_user:1-100 are staff users
  for (( i=1; i<=NUM_STAFF; i++)) 
    do
      zed relationship create cds/carta_group:staff member cds/carta_user:staff_$i
      echo "Added cds/carta_user:staff_$i member cds/carta_group:staff"
  done
fi 

# create CDS entities
for (( i=1+OFFSET; i<=NUM_ENTITIES+OFFSET; i++)) 
  do
    zed relationship create cds/content:trash_$i administrator cds/usergroup:superuser#member
    zed relationship create cds/content:staff_$i administrator cds/usergroup:superuser#member
    zed relationship create cds/content:root_$i administrator cds/usergroup:superuser#member
    echo "Added cds:usergroup:superuser#member administrator cds/content:trash_$i, cds/content:staff_$i, cds/content:root_$i"

    zed relationship create cds/content:trash_$i editor cds/carta_group:staff#member
    zed relationship create cds/content:staff_$i editor cds/carta_group:staff#member
    zed relationship create cds/content:root_$i editor cds/carta_group:staff#member
    echo "Added cds/carta_group:staff#member editor cds/content:trash_$i, cds/content:staff_$i, cds/content:root_$i"

    zed relationship create cds/content:root_$i viewer cds/carta_user:$i
    echo "Added cds/carta_user:$i viewer cds/content:root_$i"

    # root folder has some files
    for (( j=1; j<=NUM_FILES_IN_ROOT; j++)) 
    do
      FILE_ID="file_${i}_${j}"

      zed relationship create cds/content:$FILE_ID parent cds/content:root_$i
      echo "Added cds/content:root_$i parent cds/content:$FILE_ID"
    done

    # some files with file structure root->folder->folder->...->folder
    if [ `expr $i % 1000` == 1 ]
    then
      PARENT=cds/content:root_$i
      for (( j=1; j<=FOLDER_DEPTH; j++)) 
      do
        FOLDER_ID="folder_${i}_${j}"
        zed relationship create cds/content:$FOLDER_ID parent $PARENT
        echo "Added $PARENT parent cds/content:$FOLDER_ID"
        PARENT=cds/content:$FOLDER_ID
      done
    fi
done 
