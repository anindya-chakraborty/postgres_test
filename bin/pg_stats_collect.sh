#!/bin/bash
source /home/postgres/.bash_profile
source /home/postgres/app/config/collect_stats.cfg

# Check if the SQL file exists
if [ ! -f "$APP_HOME/sql/$COLLECT_SQL" ]; then
    echo "❌ Error: $COLLECT_SQL not found."
    exit 1
fi

echo "🚀 PostgreSQL Activity Dashboard"
echo "-----------------------------------"
echo " Connecting as user: $PGUSER to database: $PGDATABASE"
echo ""

# Run the Stats collection queries using psql

while true;
do
  psql "postgresql://$PGUSER@localhost/$PGDATABASE?application_name=$COLLECT_SQL" -f "$APP_HOME/sql/$COLLECT_SQL"
  timer=$(("$COLLECT_INTERVAL" * 60))
  sleep $timer
done  

echo ""
echo "✅ Stats collection complete."
