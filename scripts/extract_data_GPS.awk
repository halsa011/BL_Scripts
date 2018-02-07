#!/usr/bin/awk

###########################################################################################
# this script extracts data from a NMEA GPGGA Format:									  #
# $GPGGA,215255.60,5002.4567930,N,00832.9888148,E,1,05,1.43,104.2499,M,48.0000,M,,*5A     # 
# outputs this format:                                                                    # 
# TOD;lat_gps;lon_gps;alt_gps;WGS84_Height_gps                                            #  
# 78775.6;50.0409;8.54981;104.2499;48.0000                                                #
###########################################################################################

BEGIN{
	FS=","
	OFS=";"
	print "TOD", "lat_gps", "lon_gps", "alt_gps", "WGS84_Height_gps"
}

{
#extracting date and time
	hh=substr($2,1,2);mm=substr($2,3,2);sec=substr($2,5)
	t=hh":"mm":"sec
	TOD=hh*3600+mm*60+sec
	
	lat=substr($3,1,2)+substr($3,3)/60
	lon=substr($5,1,3)+substr($5,4)/60
	altitude=$10
	height_above_Ellipsoid=$12
	printf("%.1f;",TOD)
	print lat, lon, altitude, height_above_Ellipsoid

}