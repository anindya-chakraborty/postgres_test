#!/bin/bash
cd $HOME
source .bash_profile
APP_HOME="/home/postgres/app"
SCRIPT_NAME="runanalysis.sh"
RUN_INTERVAL=15
datestr1=`date "+%Y%m%d"`
datestr2=`date "+%Hh%Mm"`
mkdir -p $APP_HOME/sql/runanalysis/logs/$datestr1/$datestr2

while true;
do

  while IFS= read -r line; do
          psql "postgresql://$PGUSER@localhost/$PGDATABASE?application_name=$SCRIPT_NAME" -f "$APP_HOME/sql/runanalysis/$line.sql" -o $APP_HOME/sql/runanalysis/logs/$datestr1/$datestr2/$line.txt
  done < "$APP_HOME/config/file_list.cfg"


  timer=$(("$RUN_INTERVAL" * 60))
  sleep $timer

done


