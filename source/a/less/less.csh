# Set profile variables for less and lesspipe.sh.

# Setting a default $LESS was something inherited from SLS many years ago,
# but apparently the previous setting of "-M" causes display issues with
# some programs (i.e. git log). Adding "-R" as well fixes this, but some
# folks have concerns about the security of this option (I think it's
# actually "-r" that's the dangerous one). Anyway, it might be best to just
# leave this unset by default. Uncomment it if you like, or set up your
# own definition or aliases on a per-account basis.
#setenv LESS "-M -R"

# Use lesspipe.sh (see man lesspipe):
setenv LESSOPEN "|lesspipe.sh %s"

# Suppress the "informal messages" in the first line of the lesspipe output.
# If you like these, comment this line out.
setenv LESSQUIET true

