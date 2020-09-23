#!/bin/ksh

echo ec_*${1}.gz
export SSHPASS=01UABC4UOA_rslvr
/bin/sshpass -e /bin/sftp -P 10012 resolver@66.151.7.136 <<-zyxx >fileList
cd /exlibris/sfx_ver/sfx4_1/resolver/export
ls ec_*${1}.gz
quit
zyxx

./findFile.pl ${1}

for filename in `cat getFile`
do
/bin/sshpass -e /bin/sftp -P 10012 resolver@66.151.7.136 <<-zyxx
cd /exlibris/sfx_ver/sfx4_1/resolver/export
get ${filename}
quit
zyxx
gzip -d ${filename}
done

