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


cd /u/sirsi/NonWFcustom/MarcIt/Process/Edited

marcprint -t000,008,022,035,245,337,776,856,940,941 <e.mrc >e.txt

