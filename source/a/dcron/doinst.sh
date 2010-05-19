if [ ! -r var/spool/cron/crontabs/root ]; then
  mv var/spool/cron/crontabs/root.new var/spool/cron/crontabs/root
else
  rm -f var/spool/cron/crontabs/root.new
fi
