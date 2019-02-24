#!/bin/bash

cd /home

for file in /data/*.ipa; do
  buffer+=$( echo -e "**** Data for $file ****")
  cp $file working.zip
  unzip -q working.zip
  rm working.zip
  find -name "* *" -type d | rename 's/ /_/g'    # do the directories first
  find -name "* *" -type f | rename 's/ /_/g'

  JSONFILE=$(find /home -name *.json 	)

  buffer+="\nJSON files:\n-----------"
  for f in ${JSONFILE[@]}
  do
    buffer+=$(echo -e "\n$f\n")
    buffer+=$(cat $f)
  done

  CertListCer=$(find . -name *.cer)
  CertListCrt=$(find . -name *.crt)

  buffer+="\n\nCertificates:\n-------------"
  for c in ${CertListCer[@]} ; do
    buffer+=$(echo  -e "\n$c")
    test=$(grep BEGIN $c | wc -l)
    if [ $test -eq 0 ]
    then
      cert=$(echo "-----BEGIN CERTIFICATE-----\n")
      cert+=$(base64 $c)
      cert+=$(echo "\n-----END CERTIFICATE-----")
	  d=$( echo -e $cert | openssl x509 -noout -enddate 2>&1  | sed 's/^.*=\(.*\)$/\1/g')
	  endDate=$(date -d "$d" +%Y-%m-%d)
	  buffer+=$( echo -e " - $endDate")
      buffer+=$( echo -e $cert | openssl x509 -noout -subject 2>&1 | sed 's/^.*=\(.*\)$/ - \1/g')
    else 
	  d=$(cat $c | openssl x509 -noout -enddate 2>&1  | sed 's/^.*=\(.*\)$/\1/g')
	  endDate=$(date -d "$d" +%Y-%m-%d)
	  buffer+=$( echo -e " - $endDate")
      buffer+=$(cat $c | openssl x509 -noout -subject 2>&1  | sed 's/^.*=\(.*\)$/ - \1/g')
    fi
  done

  for c in ${CertListCrt[@]} ; do
    buffer+=$(echo  -e "\n$c - ")
    test=$(grep BEGIN $c | wc -l)
    if [ $test -eq 0 ]
    then
      cert=$(echo "-----BEGIN CERTIFICATE-----\n")
      cert+=$(base64 $c)
      cert+=$(echo "\n-----END CERTIFICATE-----")
	  d=$( echo -e $cert | openssl x509 -noout -enddate 2>&1 | sed 's/^.*=\(.*\)$/\1/g')
	  endDate=$(date -d "$d" +%Y-%m-%d)
	  buffer+=$( echo -e " - $endDate")
      buffer+=$( echo -e $cert | openssl x509 -noout -subject 2>&1 | sed 's/^.*=\(.*\)$/ - \1/g')
    else 
	  d=$(cat $c | openssl x509 -noout -enddate 2>&1  | sed 's/^.*=\(.*\)$/\1/g')
	  endDate=$(date -d "$d" +%Y-%m-%d)
	  buffer+=$( echo -e " - $endDate")
      buffer+=$(cat $c | openssl x509 -noout -subject 2>&1  | sed 's/^.*=\(.*\)$/ - \1/g')
    fi
  done

  buffer+="\n\nProvisioning Profiles:\n----------------------"
  ProvList=$(find . -name "*.mobileprovision")
  for p in ${ProvList[@]} ; do
    buffer+=$(echo  -e "\n$p")
    buffer+=$(cat $p | sed -n '/<key>ExpirationDate<\/key>/{n;p;}' | sed  "s/.*>\(.*\)T.*/ - \1/g" )
    buffer+=$(cat $p | sed -n '/<key>AppIDName<\/key>/{n;p;}' | sed  "s/.*>\(.*\)<.*/ - \1/g" )
    buffer+=$(cat $p | sed -n '/<key>application-identifier<\/key>/{n;p;}' | sed  "s/.*>\(.*\)<.*/ - \1/g" )
    buffer+=$"\n***********************************************************\n"
  done
  rm -rf *
done

echo -e  "$buffer"
