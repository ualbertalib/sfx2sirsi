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


cd /u/sirsi/NonWFcustom/MarcIt/Process/Updated

marcprint -t000,940 <c.mrc >c.txt

./updatedMarcIt.pl
cp records objID940 ObjID

cd ObjID
./objID.pl
cp recordsMatched ../../Reports/Upgrade/recMatchAll
cp noMatch940     ../../Reports/UpdatedNoMatch

########
cd ../../Reports/Upgrade
./upgrade.pl

cat header upgradeReport >upgradeReport.txt

mailx -s"Upgraded - Report Sirsi || MarcIt" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` < upgradeReport.txt

cat ckeys2Upgrade | catalogdump -om -kf >upgrade.mrc 2>upgrade.mrc.log
translate upgrade.mrc.log >upgrade.mrc.T.log
if [[ -s upgrade.mrc ]] then
  uuencode upgrade.mrc upgrade.mrc |mailx -s"Upgraded - Marc Records File" `cat /u/sirsi/dist1`
else
  mailx -s"Upgraded - Marc Records File is Empty" `cat /u/sirsi/dist1` < upgrade.mrc.T.log
fi

#######
cd ../UpdatedNoMatch
awk -F\^ '{print $1}' noMatch940 >noMatchbutShouldBe
cat header noMatchbutShouldBe >noMatch
mailx -s"Updated record - no Symphony record exists" `cat /u/sirsi/dist1` < noMatch

########
cd ../../Updated
date
translate updatedMarcIt.log >updatedMarcItT.log
mailx -s"MarcIt Updated Records - has finished" `cat /u/sirsi/dist1` < updatedMarcItT.log
exit

