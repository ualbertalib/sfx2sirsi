#!/bin/ksh

date
# to set sirsi environmental varibles ###
config=/u/sirsi/Unicorn/Config
. ${config}/environ
for env_var in `cat ${config}/environ | awk -F'=' '{print $1}'`
do
  export ${env_var}
done
########################################################################


cd /u/sirsi/NonWFcustom/MarcIt/Process/Deleted

marcprint -t000,940 <d.mrc >d.txt

./deletedMarcIt.pl
cp records objID940 ObjID

cd ObjID
./objID.pl
cat ckeyMatch940 | catalogdump -oF -h >dump
./findDeletes.pl
cat delSFX856 | editmarc -frem856.txt >keys.856 2>keys.856.log
cat keys.856.log
mailx -s"Catkeys of 856 tags that would be removed" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` <keys.856

cat delSFX856 | editmarc -frem090.txt >keys.090 2>keys.090.log
mailx -s"Catkeys of 090 tags that would be removed" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` <keys.090
cat keys.090.log

cat setDiscard |selitem -iB -oK >ikeys 2>ikeys.log
mailx -s"Item IDs that will be set to DISCARD" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` <setDiscard

mailx -s"Object IDs that Did Not Match" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` <noMatch

cd ..
date
translate deletedMarcIt.log >deletedMarcItT.log
mailx -s"MarcIt Deleted Records - has finished" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` < deletedMarcItT.log
exit

