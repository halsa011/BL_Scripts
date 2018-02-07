reset
reset session
input_file="RXTX2_IRE2_extracted.csv"
updaterate_col=6
time_col=2
set datafile separator ';'
set multiplot layout 1,2 title "Detection Analysis"

#plot 1 
set grid 
unset key
set xrange [0:6]
set xlabel "Update Rate (s)"; set ylabel "Häufigkeit"
plot input_file u (int(column(updaterate_col))+0.5):(1) smooth frequency w boxes lc rgb "black"

set xdata time
set timefmt "%H:%M:%S"
set format x "%H:%M:%S"

#plot 2
set grid
unset key
set xrange [*:*]
set xlabel "Time of Detection"; set ylabel "Update Rate (s)"
plot input_file u time_col:updaterate_col w impulse lc rgb "black"

set xdata
stats input_file u (((column(updaterate_col) >=0) && (column(updaterate_col)<1))? 0 :(column(updaterate_col)<5?(int(column(updaterate_col)-1)):1/0)) name "misses"
stats input_file u updaterate_col name "detections"
print (detections_records/(detections_records+misses_sum))

unset multiplot