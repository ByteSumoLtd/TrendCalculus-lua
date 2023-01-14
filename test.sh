
# Test TrendCalculus 
# 2015-06
# see LICENSE for details

# for fast multiscale reversal finding, I stack up the reversal finder.

# this will create a B-Tree depth equal to the max value of -pass.
# this is beta code. I noted files over 1.5GB may fail. I'm looking into it.

z=5  # set this to N for the first run. It is the number of first-pass observations to use in the trend identification window
p=2  # set this to 2 so we can build, bottom-up, the levelling in the B-Tree of trends

src="data/"    # this is the directory for input data in trendcalculus-public

rm out/*rev*.csv
name="all_DJI"

cp ${src}db_output_${name}.csv db_output.csv

time cat db_output.csv |  lua trendcalculus.lua -F "," -OFS "," -p 1 -h -H -n $z -r \
	| tee out/${name}_rev01.csv |  lua trendcalculus.lua -F "," -OFS "," -p 2 -h -H -n $p -r \
        | tee out/${name}_rev02.csv | lua trendcalculus.lua -F "," -OFS "," -p 3 -h -H -n $p -r  \
        | tee out/${name}_rev03.csv | lua trendcalculus.lua -F "," -OFS "," -p 4 -h -H -n $p -r  \
        | tee out/${name}_rev04.csv | lua trendcalculus.lua -F "," -OFS "," -p 5 -h -H -n $p -r  \
        | tee out/${name}_rev05.csv | lua trendcalculus.lua -F "," -OFS "," -p 6 -h -H -n $p -r  \
        | tee out/${name}_rev06.csv | lua trendcalculus.lua -F "," -OFS "," -p 7 -h -H -n $p -r  \
        | tee out/${name}_rev07.csv | lua trendcalculus.lua -F "," -OFS "," -p 8 -h -H -n $p -r  \
        | tee out/${name}_rev08.csv | lua trendcalculus.lua -F "," -OFS "," -p 9 -h -H -n $p -r  \
        | tee out/${name}_rev09.csv | lua trendcalculus.lua -F "," -OFS "," -p 10 -h -H -n $p -r  \
        | tee out/${name}_rev10.csv | lua trendcalculus.lua -F "," -OFS "," -p 11 -h -H -n $p -r  \
        | tee out/${name}_rev11.csv | lua trendcalculus.lua -F "," -OFS "," -p 12 -h -H -n $p -r  \
        | tee out/${name}_rev12.csv | lua trendcalculus.lua -F "," -OFS "," -p 13 -h -H -n $p -r  \
	| tee out/${name}_rev13.csv | lua trendcalculus.lua -F "," -OFS "," -p 14 -h -H -n $p -r > out/${name}_rev14.csv

 time cat db_output.csv |  lua trendcalculus.lua -F "," -OFS "," -p 1 -h -H -n $z -s | lua rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/${name}_srev01.csv |  lua trendcalculus.lua -F "," -OFS "," -p 2 -h -H -n $p -s| lua rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/${name}_srev02.csv | lua trendcalculus.lua -F "," -OFS "," -p 3 -h -H -n $p -s | lua rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/${name}_srev03.csv | lua trendcalculus.lua -F "," -OFS "," -p 4 -h -H -n $p -s | lua rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/${name}_srev04.csv | lua trendcalculus.lua -F "," -OFS "," -p 5 -h -H -n $p -s | lua rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/${name}_srev05.csv | lua trendcalculus.lua -F "," -OFS "," -p 6 -h -H -n $p -s | lua rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/${name}_srev06.csv | lua trendcalculus.lua -F "," -OFS "," -p 7 -h -H -n $p -s | lua rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/${name}_srev07.csv | lua trendcalculus.lua -F "," -OFS "," -p 8 -h -H -n $p -s | lua rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/${name}_srev08.csv | lua trendcalculus.lua -F "," -OFS "," -p 9 -h -H -n $p -s | lua rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/${name}_srev09.csv | lua trendcalculus.lua -F "," -OFS "," -p 10 -h -H -n $p -s | lua rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/${name}_srev10.csv | lua trendcalculus.lua -F "," -OFS "," -p 11 -h -H -n $p -s | lua rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/${name}_srev11.csv | lua trendcalculus.lua -F "," -OFS "," -p 12 -h -H -n $p -s | lua rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/${name}_srev12.csv | lua trendcalculus.lua -F "," -OFS "," -p 13 -h -H -n $p -s | lua rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/${name}_srev13.csv | lua trendcalculus.lua -F "," -OFS "," -p 14 -h -H -n $p -s | lua rev.lua -F "," -h -H -s -OFS "," > out/${name}_srev14.csv


mv db_output.csv out/.
wc -l out/*.csv





