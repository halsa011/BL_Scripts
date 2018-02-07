#!/usr/bin/awk

BEGIN{
FS=";"
OFS=";"
print"NR;Time;Date;TOD;Seconds;dt;ACAdd;Track;lat;lon;x;y"
}
NR>1{
split($2,time,":")
TOD=time[2]*3600+time[3]*60+time[4]
printf ("%d;%s;%s;",NR,"NA","NA") 
printf("%.1f;",TOD)
print "NA", "NA", "NA", "NA", $3, $4, "NA", "NA"
}