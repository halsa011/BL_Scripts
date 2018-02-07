#!/bin/bash

for i in $(find  ~/Documents/HAM/Fahrt2_RXTX2/accuracy/0.2smatch_RXTX2/ -name '*.csv' -type f)
do 
#i=~/Documents/HAM/Fahrt1_RXTX1/accuracy/0.2sMatch_RXTX1/RXTX1_ERE1_acc_0.2smatch.csv
	infile=$(basename $i)
	pdffilename=${infile:0:${#infile}-13}_0.2s
	outfile=${infile:0:${#infile}-13}_0.2smatch.csv
	#echo $i $infile $pdffilename $outfile
	for j in $(find ~/Documents/filters/run_polygones -name '*.csv')
	do
		polyfile=$(basename $j)
		filtername=${polyfile:0:${#polyfile}-15}
		echo $filtername
		~/Documents/filters/4point_poly_filter.sh $i $filtername $j
	done
#awk -f ~/Documents/accuracy_interval_matching.awk ../RXTX1_MLAT_extracted.csv  $i> $outfile

#gnuplot -p -c ~/Documents/acc_modified.gp ~/Documents/HAM/layout.CSV $outfile $pdffilename
#awk -f ../../extract_sensordata_generic.awk MS="KW6" $i> $outfile
done
for k in $(find  ~/Documents/filters/ -name '*_filtered*')
do
	gnufile=$(basename $k)
	gnuoutfile=${gnufile:0:${#gnufile}-4}acc_0.2smatch
	gnuplot -p -c ~/Documents/acc_modified.gp ~/Documents/HAM/layout.CSV $k $gnuoutfile
done