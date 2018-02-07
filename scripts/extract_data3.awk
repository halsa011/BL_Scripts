#!/usr/bin/awk

#==============================================================================================================================================================================
# AUTHOR.........Sara Hallouda																						                                                           #
# DATE...........20.10.2016																							                                                           # 
#                                                                                                                                                                              #
# DESCRIPTION
# -----------         
# this script extracts data from the following txt file format:
# mytime	acaddr	tracknum	lat	long	X	Y	trd	bcdfl	height	status	sigmaX	sigmaY	sigmaXY  
# 22:00:0.359375	3949367	2341	50.043224	8.555212	-1092.000000	1103.000000	0x450500		0	0x070100	2.750000	2.750000	0.00000                        #
# and returns the additional columns:                                                                                                                                          #
## TOD: time of detection in seconds and is rounded to a single number after comma, Seconds: continuous seconds counter that goes over midnight, dt: is the update rate in sec #
# output format:
#--------------
# NR;Time;Date;TOD;Seconds;dt;ACAdd;Track;x;y
# 7;21:44:52;2016.03.17;78292;78292;0;3c4420;930;-3597.000000;-417.000000
# this output format does not have individual sensor data as in sensor ID or sac sic
#For records going overnight, day1 is hard coded line 44 and day2 adds 1 on it
# script is called by:
#--------------------
# awk -f extract_data3.awk MS="3949363" test.txt
# where: test.txt is the input file and MS is the selected mode-S Address in hexa
#==============================================================================================================================================================================


BEGIN{
	Header= "NR;Time;Date;TOD;Seconds;dt;ACAdd;Track;lat;lon;x;y"
	print Header
	OFS=";"
	FS="\t"
	day1="2016.03.17"
	day2= substr(day1,1,8)(substr(day1,9)+1) 
	dt=0
	flag=0
}


##$0!~/^[^0-9]*$ this line matches empty tabs records, it could have different outcomes for another file then the tested one
## to process the first 100 lines, add: && NR<100  

NR >1 && $0!~/^[^0-9]*$/ && $2==MS{

if (flag==0){
	NR_begin=NR
}	

flag=1

split($1,time,":")
TOD=time[1]*3600+time[2]*60+time[3]

#storing values from time-1
if (NR>NR_begin){
	seconds_old=seconds
	Track_old=Track
}

#finding midnight record and setting found flag to 1 and incrementing the seconds count
if (time[1]~ 00 && time[2]~ 00 && time[3]~ 00 && found==0){
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

clocktime=$1
accad=$2
Track=$3
lat=$4
lon=$5
x=$6
y=$7

printf ("%5d;%-14s;%10s;",NR, clocktime, day) 
printf("%.1f;",TOD)
print seconds, dt, accad, Track, lat, lon, x, y

}
