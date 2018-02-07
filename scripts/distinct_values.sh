 #!/bin/bash
 #creates a list with distinct values in a column and the count of each value separated with ;
 #input 1 is input file, 2 is output file, 3 is column number with the values to group and count
 filein=$1
 fileout=$2
 col=$3
#$col is the array subscript and the values we want to count, the array element is the count of the value in the subscript.

 awk -F ';' -v col=$col '{a[$col]++} END {for (i in a) print i";"a[i]}' $filein >$fileout