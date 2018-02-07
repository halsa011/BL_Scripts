#!/usr/bin/awk

#===============================================================================================
# AUTHOR.........Sara Hallouda																						
# DATE...........11.05.2017																						
#
# DESCRIPTION
# ----------- 
# 
# input variables: column numbers MS_Address(add_col),clocktime(T_col),day1_date(date), track, lat, lon, x, y  
#and returns the additional columns:
# TOD: time of detection in seconds and is rounded to a single number after comma (input*1/128), Seconds: continuous seconds counter that goes over midnight, dt: is the update rate in sec and is only valid when data is filtered for a single target.
# output format:
#--------------
# NR;Time;Date;TOD;Seconds;dt;ACAdd;Track;x;y
# 7;21:44:52;2016.03.17;78292;78292;0;3c4420;930;-3597.000000;-417.000000
#For records going overnight, day1 is hard coded line 44 and day2 adds 1 on it
# script is called by:
#--------------------
# awk -f extract_sensordata_generic.awk MS="3965901" test.txt
# where: test.txt is the input file and MS is the selected mode-S Address in hexa
#==============================================================================================

BEGIN{
	##extractor data
	#add_col=15; track_col=14; T_col=1; date="2017.05.10"; lat_col=4; lon_col=5; x_col=2;y_col=3
	
	##MLAT data 
	add_col=6; track_col=10; T_col=1; date="2017.05.10"; lat_col=4; lon_col=5; x_col=2;y_col=3
	
	##ADSB - track_col, x, y, acad is missing
	#add_col=4; T_col=1; date="2017.05.10"; lat_col=2; lon_col=3

	##Header= "NR;Time;Date;TOD;Seconds;dt;ACAdd;Track;lat;lon;x;y"
	Header= "NR;Time;Date;TOD;Seconds;dt;lat;lon;x;y"
	
	print Header
	OFMT="%.4f"
	OFS=";"
	FS=";"
	day1=date
	day2= substr(day1,1,8)(substr(day1,9)+1) 
	dt=0
	flag=0
}


##$0!~/^[^0-9]*$ this line matches empty tabs records, it could have different outcomes for another file then the tested one
## to process the first 100 lines, add && NR<100
##$add_col==MS: use == instead of ~ in case of a numeric MS address  

NR >1 && $add_col==MS{
if (flag==0){
	NR_begin=NR
}	

flag=1

clocktime=$T_col
split(clocktime,time,":")
TOD=time[1]*3600+time[2]*60+time[3]

#storing values from time-1
if (NR>NR_begin){
	seconds_old=seconds
	Track_old=Track
}

#finding midnight record and setting found flag to 1 and incrementing the seconds count
if (time[1]=="00" && time[2]== "00" && time[3]== "00" && found==0){
found=1
seconds=86400
}

#for records after midnight the date is incremented by 1 to day2 and seconds are incremented by TOD
if (found==1){
seconds=86400+TOD
day=day2}

else{
seconds=TOD
day=day1}



#calculating the update time
if (NR>NR_begin){
	dt=seconds-seconds_old
}
else{
	dt=0
}

#extracted fields
accad=$add_col
Track=$track_col
lat=$lat_col
lon=$lon_col
x=$x_col 
y=$y_col

#print NR, clocktime, day, TOD, seconds, dt,accad, lat, lon
#print NR,clocktime,day,TOD,seconds,dt,accad,Track,lat,lon,x,y

printf ("%d;%-12s;%10s;",NR, clocktime, day) 
printf("%.1f;",TOD)
print seconds, dt, lat, lon, x, y
#print seconds, dt, accad, lat, lon, x, y
}
