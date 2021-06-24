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


cd /u/sirsi/NonWFcustom/MarcIt/Process/New

marcprint -t000,008,022,035,245,337,776,856,940,941 <n.mrc >n.txt

./newMarcIt.pl
cp records objID940 ObjID

cd ObjID
./objID.pl
cat recordsMatched > ../../Reports/Upgrade/recMatchAll
cat recordsMatched > ../SFX856/recMatchAll
cat ckeyMatch940 > ../SFX856/ckeyMatchAll
cat ckeyMatch940 > ../HasItem/ckeyMatchAll
cp noMatch940 ../ISSN

cd ../ISSN
./issn.pl
cat match022a >> ../../Reports/Upgrade/recMatchAll
cat diffObjID > ../../Reports/DiffObjID/diffObjID
cp multiMatch022 ../../Reports/MultiMatches
cat ckeyMatch022a >> ../HasItem/ckeyMatchAll
cat ckeyMatch022a >> ../SFX856/ckeyMatchAll
cat match022a >> ../SFX856/recMatchAll
cp noMatch022a ../OCLC

cd ../OCLC
./oclc.pl
cat match035a >> ../../Reports/Upgrade/recMatchAll
cat diffObjID >> ../../Reports/DiffObjID/diffObjID
cp multiMatch035 ../../Reports/MultiMatches
cat ckeyMatch035a >> ../HasItem/ckeyMatchAll
cat ckeyMatch035a >> ../SFX856/ckeyMatchAll
cat match035a >> ../SFX856/recMatchAll
cp noMatch035a ../../Reports/NewRecords

cd ../HasItem
./hasItem.pl
sort -nu ckeyHasUAINT >ckeyHasUAINTu
cp ckeyHasUAINTu ../SFX856
mailx -s"Items That Would be Added" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` < addCopy.trans

cd ../SFX856
cat ckeyMatchAll | catalogdump -oF >dump 2>dump.log
echo END >>dump
./sfx856.pl
cp noResolver ../../Reports/HoldingAdded
mailx -s"856 & 090 that would be added" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` < add856

#######
cd ../../Reports/Upgrade
./upgrade.pl

cat header upgradeReport >upgradeReport.txt

mailx -s"Upgraded - Report Sirsi || MarcIt" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` < upgradeReport.txt

cat ckeys2Upgrade | catalogdump -om -kf >upgrade.mrc 2>upgrade.mrc.log
translate upgrade.mrc.log >upgrade.mrc.T.log
if [[ -s upgrade.mrc ]] then
  uuencode upgrade.mrc upgrade.mrc |mailx -s"Upgraded - Marc Records File" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist`
else
  mailx -s"Upgraded - Marc Records File is Empty" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` < upgrade.mrc.T.log
fi

#######
cd ../../Reports/HoldingAdded
mailx -s"Holding added - UAL holding exists" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` < noResolver

cd ../MultiMatches
mailx -s"Multiple Matches (022|a)" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` < multiMatch022

mailx -s"Multiple Matches (035|a)" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` < multiMatch035

######
cd ../NewRecords
awk -F\^ '{print $1"^"$2"^"$3"^"}' noMatch035a >noMatchSirsi
mailx -s"New Records" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` < noMatchSirsi

######
cd ../DiffObjID
cat header diffObjID >diffObjID.txt
mailx -s"Different Object ID exists" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` < diffObjID.txt

######
cd ../../New
date
translate newMarcIt.log >newMarcItT.log
mailx -s"MarcIt New Records - has finished" `cat /u/sirsi/NonWFcustom/MarcIt/Process/dist` < newMarcItT.log
exit

