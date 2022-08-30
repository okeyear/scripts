#!/bin/bash
BASEDIR=$(pwd)
DIRNAME=${BASEDIR##*/}
echo '{' | tee $DIRNAME.code-workspace
echo '  "folders": [' | tee -a $DIRNAME.code-workspace
for folder in $(ls -l | grep "^d" | awk '{print $NF}')
do
    echo '    {' | tee -a $DIRNAME.code-workspace
    echo '      "path": "'$folder'"' | tee -a $DIRNAME.code-workspace
    echo '    },' | tee -a $DIRNAME.code-workspace
done
sed -i '$s/,//' $DIRNAME.code-workspace
echo '  ]' | tee -a $DIRNAME.code-workspace
echo '}' | tee -a $DIRNAME.code-workspace

# bash create-code-workspace.sh 
