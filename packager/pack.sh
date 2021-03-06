#!/bin/bash

base_dir=${1:-".."}
echo "Using base dir $base_dir"
tmp_dir="$TMPDIR/rb-dmf-packager"

fail_tmp_dir() {
    echo "$tmp_dir could not be created."
    exit 1
}

echo "Creating tmp dir: $tmp_dir"

mkdir $tmp_dir || fail_tmp_dir

cat content.def | while read line; do
    
    if [ -n "$line" ]
    then
        dirname=${line%/*}
        filename=${line##*/}
        mkdir -p $tmp_dir/$dirname
        cp $base_dir/$dirname/$filename $tmp_dir/$dirname 
    fi
    
done 

echo "Copied tmp dir: $tmp_dir"
ls -lisaR $tmp_dir

echo "Creating jar file."
jar cvf rbdmf.jar -C $tmp_dir .

echo "Deploying jar to nexus."
mvn deploy:deploy-file -Durl=http://nexus.lichtflut.de/nexus/content/repositories/snapshots/ \
                       -DrepositoryId=lf-snapshots \
                       -Dfile=rbdmf.jar \
                       -DgroupId=de.lichtflut.rh \
                       -DartifactId=domain-model \
                       -Dversion=1.0-SNAPSHOT \
                       -Dpackaging=jar                     
echo "Removing jar"
rm -rf rbdmf.jar

echo "Removing tmp dir: $tmp_dir"
rm -rf $tmp_dir