# Send SIGTERM to any running kscreenlocker_greet after installing
# kcheckpass. This will trigger a restart of kscreenlocker_greet
# which prevents deadlock when migrating Plasma 5.9 -> 5.10.
# See email to distributions@kde.org by Martin Graesslin on Wed, 08 Mar 2017.
killall -TERM kscreenlocker_greet 1>/dev/null 2>/dev/null
