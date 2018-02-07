#!/usr/bin/awk

BEGIN{
FS=";"
OFS=";"
print "TOD", "lat_gps", "lon_gps", "alt_gps", "WGS84_Height_gps"
}

NR>1{
split($5,time,":")
TOD=time[2]*3600+time[3]*60+time[4]

printf("%.1f;",TOD)
print $6, $7, "NA", "NA","NA", "NA"
}