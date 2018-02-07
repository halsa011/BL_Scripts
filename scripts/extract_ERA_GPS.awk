#!/usr/bin/awk

###########################################################################################
# this script extracts data from a ERA Format:									          #
# Index;Surv_Time:Short;LatWGS84;LongWGS84;HeightWGS84                                    #
# 1;14.2.2017 22:12:49;51.27364616;6.7557099;83.491                                       # 
# outputs this format:                                                                    # 
# TOD;lat_gps;lon_gps;alt_gps;WGS84_Height_gps                                            #  
# 78775.6;50.0409;8.54981;104.2499;48.0000                                                #
###########################################################################################

BEGIN{
	FS=";"
	OFS=";"
	OFMT="%.6f"
	print "TOD", "lat_gps", "lon_gps", "alt_gps", "WGS84_Height_gps"
}

NR>1 {
#extracting date and time
	split($2,t_out,":")

	hh=substr(t_out[1],11);mm=t_out[2];sec=t_out[3]
	t=hh":"mm":"sec
	TOD=hh*3600+mm*60+sec
	
	lat=$3
	lon=$4
	#altitude=$10
	height_above_Ellipsoid=$5
	#printf("%.1f;",TOD)
	print TOD, lat, lon,"NA", height_above_Ellipsoid

}