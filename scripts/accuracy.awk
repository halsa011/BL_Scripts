#!/usr/bin/awk
# input file order, first GPS/reference sensor  file followed by MLAT/measurement_sensor file 
# x_meas und y_meas sind die x y daten vom MLAT System nach der transormation vom system Lat Lon daten, und so unterscheiden sie sich
# von dem x y daten die bereits im system transformiert worden sind.
# if the reference sensor does not deliver a height, the ARP height should be taken instead height_s

function localcarth(lat,lon,height_g){


	#constants
	pi = 3.14159265359
	a = 6378137 #Meter Semi major axis
	e = 0.0818191908426 #Eccentricity
	#ARP Reference Point

	##FRA
	#lon_s = 8.57045555*pi/180 #ARP 1 s: smgcs, umwandlung grad in rad
	#lat_s = 50.03330555*pi/180 #ARP 1
	#height_s = 99.9744 #meter

	##DUS
	#lat_s=51.280925*pi/180
	#lon_s = 6.75731111*pi/180
	#height_s = 44.8056
	##HAM
	lat_s=53.63039*pi/180
	lon_s = 9.988227*pi/180
	height_s = 16.1544

	lat_g = lat*pi/180
	lon_g = lon*pi/180

	n_g = a/(sqrt(1-e*e*sin(lat_g)))
	n_s = a/(sqrt(1-e*e*sin(lat_s)))
	
	#the geocentric coordinates of the input point
	x_g = (n_g + height_g) * cos(lat_g) * cos(lon_g)
	y_g = (n_g + height_g) * cos(lat_g) * sin(lon_g)
	z_g = (n_g * (1-e*e) + height_g) * sin(lat_g)

	#the geocentric coordinates of the reference point
	x_s = (n_s + height_s) * cos(lat_s) * cos(lon_s)
	y_s = (n_s + height_s) * cos(lat_s) * sin(lon_s)
	z_s = (n_s * (1-e*e) + height_s) * sin(lat_s)

	#the local cartesian coordinates of the input point by translating and rotating
	x_c = -sin(lon_s)*(x_g-x_s) + cos(lon_s)*(y_g-y_s)
	y_c = -sin(lat_s) * cos(lon_s) * (x_g-x_s) - sin(lat_s)*sin(lon_s)*(y_g-y_s) + cos(lat_s)*(z_g-z_s)
	z_c = cos(lat_s)*cos(lon_s)*(x_g-x_s) + cos(lat_s)*sin(lon_s)*(y_g-y_s) + sin(lat_s)*(z_g-z_s)
}
BEGIN{
FS=";"
OFS=";"
Header= "NR;x_meas;y_meas;x_ref;y_ref;accuracy(m)"
print Header

#data structure for reference sensor
ref_TOD_col=4; ref_Lat_col=8; ref_Lon_col=9; #ref_height_col=5
#data structure for sensor under analysis
NR_col=1; TOD_col=4; Lat_col=7; Lon_col=8
} 
# NR is the global record number, and the condition is to perform array filling with first input (GPS/reference traj) file only
FNR==NR {
LAT[$ref_TOD_col]=$ref_Lat_col;LON[$ref_TOD_col]=$ref_Lon_col
#height[$ref_TOD_col]=$ref_height_col

next
}

{
if ($TOD_col in LAT && FNR>1 && $Lat_col!=0 && $Lon_col!=0){
#Debug: print out lines with non matching time GPS-MLAT
# 	{}
# else
# print FNR, NR
localcarth(LAT[$TOD_col],LON[$TOD_col], height_s)
x_ref=x_c;y_ref=y_c;z_ref=z_c

localcarth($Lat_col,$Lon_col, height_s)
#localcarth($9,$10, height[$4] )
x_meas=x_c;y_meas=y_c;z_meas=z_c

acc=sqrt((x_ref-x_meas)^2+(y_ref-y_meas)^2)
line=$NR_col
print line, x_meas, y_meas, x_ref, y_ref, acc

#print $0, x_mlat, y_mlat, x_gps, y_gps, acc
#print $0,LAT[$4],LON[$4],alt[$4],height[$4] 
}
}
