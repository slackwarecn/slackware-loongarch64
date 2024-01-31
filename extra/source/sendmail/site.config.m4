APPENDDEF(`confMAPDEF', `-DNEWDB')
APPENDDEF(`confLIBS', `-lnsl -lssl -lcrypto -lsasl2 -lwrap -lm -ldb -lresolv -licuuc -licui18n -licudata')
APPENDDEF(`conf_libmilter_ENVDEF', `-DMILTER')
APPENDDEF(`conf_sendmail_ENVDEF', `-DMILTER')
APPENDDEF(`confENVDEF', `-DNETINET6 -DIPV6_FULL -DNEWDB -DSTARTTLS -DDANE -DSASL=2 -DTCPWRAPPERS -DNIS -DMAP_REGEX -DSOCKETMAP -DTLS_EC -DUSE_EAI')dnl
