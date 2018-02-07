#!/usr/bin/awk

BEGIN{
FS=";"
sum_misses=0
update_rate_col
}

(NR>1){
	if ($update_rate_col<=1){misses=0} 
	else {misses=int($update_rate_col)-1}
	
	##Calculating PD
	if (misses>0 && misses<=2){
	sum_misses=misses+sum_misses}
	#print misses

	print gap_start_tod, gap_end_tod, gap_size,x_start, y_start, x_end, y_end
	} 

END{
print sum_misses, ((NR-1)/(NR-1+sum_misses)*100), NR
}