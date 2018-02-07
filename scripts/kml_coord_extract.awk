#!/usr/bin/awk
#this script extracts the coordinates of the polygone from the kml google earth export file, in a comma separated file with placemark, lat, lon, alt

BEGIN{
OFS=";"
header="placemark;long;lat;height"
print header
}
(NR>1){

if ($1=="<coordinates>")
	{line=NR}

if (NR==line+1){
	n=split($0,coord," ")
	for (i=1;i<n;i=i+1)
	{split(coord[i],xyz,",")
	print "a" i , xyz[1], xyz[2], xyz[3]}
	}
}
