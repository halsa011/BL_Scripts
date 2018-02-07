#!/usr/bin/awk

#=====================================================================================================================
# AUTHOR.........Sara Hallouda																						
# DATE...........20.10.2016																							
#
# DESCRIPTION
# ----------- 
# this script extracts data from the following txt file format:
# mytime	acaddr	tracknum	X	Y	trdsensor1sensor2sensor3sensor4status 
# 21:44:52	400663	380	-2527.000000	496.000000	0xa10320	TrackUpdatedWithMLAT				0x01011110
#
# sensor notation: SSR(FFS),PSR(FFS),SMR, MLAT
# and returns the additional columns:
# TOD: time of detection in seconds, Seconds: continuous seconds counter that goes over midnight, dt: is the update rate in sec 
# output format:
# NR;Time;Date;TOD;Seconds;dt;ACAdd;MLAT;SMR;SSR;PSR;n_sensors;Track;x;y
# 7;21:44:52;2016.03.17;78292;78292;0;3c4420;1;0;0;0;1;930;-3597.000000;-417.000000

# For records going overnight, day1 is hard coded line 46 and day2 adds 1 on it
# script is called by:
# awk -f extract_data1.awk MS="3c4420" test.txt
# where: test.txt is the input file and MS is the selected mode-S Address in hexa
#=====================================================================================================================

function fillSen(word){
	if (word ~ /TrackUpdatedWithSSR/){
		SSR = 1
	}
	if (word ~ /TrackUpdatedWithPSR/){
		PSR = 1
	}
	if (word ~ /TrackUpdatedWithSMR/){
		SMR = 1
	}
	if (word ~ /TrackUpdatedWithMLAT/){
		MLAT = 1
	}

}

BEGIN{
	Header= "NR;Time;Date;TOD;Seconds;dt;ACAdd;MLAT;SMR;SSR;PSR;n_sensors;Track;x;y"
	print Header
	OFS=";"
	FS="\t"
	day1="2016.03.17"
	day2= substr(day1,1,8)(substr(day1,9)+1) 
	dt=0
	flag=0
}


##$0!~/^[^0-9]*$ this line matches empty tabs records, it could have different outcomes for another file then the tested one
## add to process the first 100 lines  

NR >1 && $0!~/^[^0-9]*$/ && $2==MS {

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

Track=$3

#calculating the update time
if (NR>NR_begin){
	dt=seconds-seconds_old
}
else{
	dt=0
}

# Extracting Sensor Data
MLAT=0;PSR=0;SMR=0;SSR=0;n_sen=0
for (i=7; i<NF; i=i+1){
fillSen($i)}

n_sensors=MLAT+SMR+SSR+PSR

x=$4
y=$5

print NR, $1, day, TOD, seconds, dt, $2, MLAT, SMR, SSR, PSR, n_sensors, Track, x, y

}
