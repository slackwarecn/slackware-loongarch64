# Toss redundant sample files:
for file in wireplumber.desktop ; do
  cmp -s etc/xdg/autostart/${file} etc/xdg/autostart/${file}.sample && rm etc/xdg/autostart/${file}.sample
done
