#!/bin/sh
#
day=`date '+%d'`
#
cd /home/sfxruby/sfx2sirsi

if [ $day -gt 0 ] && [ $day -lt 8 ]; then
  #echo "This is the first Friday of the month so running Full Extract."
  bundle exec rake full_update --silent
else
  #echo "This is NOT the first Friday of the month so running usual Incr Extract."
  bundle exec rake nightly_update --silent
fi
#
exit
