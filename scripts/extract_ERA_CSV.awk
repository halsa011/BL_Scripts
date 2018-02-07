#!/usr/bin/awk

#=====================================================================================================================
# AUTHOR.........Sara Hallouda																						
# DATE...........03.04.2017																						
#
# DESCRIPTION
# ----------- 
# this script extracts data from the following csv file format (ERA asterix to csv converter output):
#
#IDENT;head_time;010_SAC;010_SIC;020_SSR;020_MS;020_HF;020_VDL4;020_UAT;020_DME;020_OT;020_FX1;020_RAB;020_SPI;020_CHN;020_GBS;
#020_CRT;020_SIM;020_TST;020_FX2;041_Latitude_in_WGS_84;041_Longitude_in_WGS_84;042_X;042_Y;050_V;050_G;050_L;050_Mode_2;055_V;055_G;
#055_L;055_Mode_1;070_V;070_G;070_L;070_Mode_3_A;090_V;090_G;090_Flight_Level;100_V;100_G;100_Mode_C;100_Mode_C_Code_Confidence_Indicator;
#105_Geometric_Altitude_WGS_84;110_Measured_Height;140_TIME_OF_DAY;161_TRACK_NUMBER;170_CNF;170_TRE;170_CST;170_CDM;170_MAH;170_STH;170_FX1;
#170_GHO;170_FX2;202_Vx;202_Vy;210_Ax;210_Ay;220_Target_Address;230_COM;230_STAT;230_MSSC;230_ARC;230_AIC;230_B1A;230_B1B;245_STI;245_target_identification;
#250_MBDATA_REP;260_ACAS_MB_DATA_1;260_ACAS_MB_DATA_2;260_ACAS_MB_DATA_3;260_ACAS_MB_DATA_4;260_ACAS_MB_DATA_5;260_ACAS_MB_DATA_6;260_ACAS_MB_DATA_7;300_VFI;
#310_TRB;310_MSG;400_REP;500_DOP;500_SDP;500_SDA;500_DOP_DOP_x;500_DOP_DOP_y;500_DOP_DOP_xy;500_SDP_Sigma_x;500_SDP_Sigma_y;500_SDP_Ro_xy;500_SDA_Sigma_GA;RE;SP;
# this command was used to filter out the single asterix items column number, below for example item 070
#awk -F ';' 'NR==1 {for (i=1;i<=NF;i=i+1){if ($i~/070/) {print i,$i}}}'
#
#and returns the additional columns:
# TOD: time of detection in seconds and is rounded to a single number after comma (input*1/128), Seconds: continuous seconds counter that goes over midnight, dt: is the update rate in sec 
# output format:
#--------------
# NR;Time;Date;TOD;Seconds;dt;ACAdd;Track;x;y
# 7;21:44:52;2016.03.17;78292;78292;0;3c4420;930;-3597.000000;-417.000000
#For records going overnight, day1 is hard coded line 44 and day2 adds 1 on it
# script is called by:
#--------------------
# awk -f extract_ERA_CSV.awk MS="3965901" test.txt
# where: test.txt is the input file and MS is the selected mode-S Address in hexa
#=====================================================================================================================


BEGIN{
	Header= "NR;Time;Date;TOD;Seconds;dt;ACAdd;Track;lat;lon;x;y"
	print Header
	OFMT="%.6f"
	OFS=";"
	FS=";"
	day1="2017.02.14"
	day2= substr(day1,1,8)(substr(day1,9)+1) 
	dt=0
	flag=0
}


##$0!~/^[^0-9]*$ this line matches empty tabs records, it could have different outcomes for another file then the tested one
## add to process the first 100 lines && NR<100  

NR >1 && $61==MS{

if (flag==0){
	NR_begin=NR
}	

flag=1


TOD=$46/128
h=int(TOD/3600); m= int((TOD%3600)/60); s=((TOD%3600)%60)/60
clocktime= h ":" m ":" s
split(clocktime,time,":")

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

#extracted asterix items
accad=$61
Track=$47
lat=$21*180/(2^25)
lon=$22*180/(2^25)
x=$23*0.5 # LSB 0.5
y=$24*0.5

#printf ("%5d;%-14s;%10s;",NR, clocktime, day) 
#printf("%.1f;",TOD)
print NR, clocktime, day, TOD, seconds, dt, accad, Track, lat, lon, x, y

}
