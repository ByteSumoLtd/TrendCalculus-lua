
# Test TrendCalculus 
# 2015-06
# see LICENSE for details

# for fast multiscale reversal finding, I stack up the reversal finder.

# this will create a B-Tree depth equal to the max value of -pass.
# this is beta code. I noted files over 1.5GB may fail. I'm looking into it.

z=20  # set this to N for the first run. It is the number of first-pass observations to use in the trend identification window

src="data/"    # this is the directory for input data in trendcalculus-public

rm out/*.csv

name="all_DJI"

cp ${src}db_output_${name}.csv db_output.csv

time cat db_output.csv |  lua tcfg_v1.0.lua -F "," -OFS "," -p 1 -h -H -n $z -m 10 -g > out/tcfg_output_${z}.csv

mv db_output.csv out/.
wc -l out/*.csv





