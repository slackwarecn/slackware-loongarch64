config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

# See if we need to backup an existing login.defs:
if [ -r etc/login.defs ]; then
  # First, check for PAM:
  if [ -r etc/pam.d/login.new ]; then
    # If there's an existing /etc/login.defs that contains an obsolete option
    # intended for a non-pam system, rename it to back it up and allow the
    # pam-enabled login.defs to be installed automatically:
    if grep -q "^LASTLOG_ENAB" etc/login.defs 1> /dev/null 2> /dev/null ; then
      mv etc/login.defs etc/login.defs.non-pam.backup
    fi
  else # Same thing, but in reverse for a non-pam system:
    if ! grep -q "^LASTLOG_ENAB" etc/login.defs 1> /dev/null 2> /dev/null ; then
      mv etc/login.defs etc/login.defs.pam.backup
    fi
  fi
fi

config etc/default/useradd.new
config etc/login.defs.new
config var/log/faillog.new
rm -f var/log/faillog.new
if [ -r etc/login.access.new ]; then
  config etc/login.access.new
fi
for configfile in chage.new chgpasswd.new chpasswd.new groupadd.new groupdel.new groupmems.new groupmod.new newusers.new other.new passwd.new postlogin.new su.new su-l.new system-auth.new useradd.new userdel.new usermod.new ; do
  if [ -r etc/pam.d/$configfile ]; then
    config etc/pam.d/$configfile
  fi
done
