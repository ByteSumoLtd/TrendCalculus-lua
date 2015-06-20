
# Test TrendCalculus 
# 2015-06
# see LICENSE for details

# for fast multiscale reversal finding, I stack up the reversal finder.

# this will create a B-Tree depth equal to the max value of -pass.
# this is beta code. I noted files over 1.5GB may fail. I'm looking into it.

z=5  # set this to N for the first run. It is the number of first-pass observations to use in the trend identification window
p=2  # set this to 2 so we can build, bottom-up, the levelling in the B-Tree of trends

src="data/"    # this is the directory for input data in trendcalculus-public

rm out/*.csv

name="all_DJI"

cp ${src}db_output_${name}.csv db_output.csv

time cat db_output.csv |  luajit trendcalculus.lua -F "," -OFS "," -p 1 -h -H -n $z -r \
	| tee out/rev01.csv |  luajit trendcalculus.lua -F "," -OFS "," -p 2 -h -H -n $p -r \
        | tee out/rev02.csv | luajit trendcalculus.lua -F "," -OFS "," -p 3 -h -H -n $p -r  \
        | tee out/rev03.csv | luajit trendcalculus.lua -F "," -OFS "," -p 4 -h -H -n $p -r  \
        | tee out/rev04.csv | luajit trendcalculus.lua -F "," -OFS "," -p 5 -h -H -n $p -r  \
        | tee out/rev05.csv | luajit trendcalculus.lua -F "," -OFS "," -p 6 -h -H -n $p -r  \
        | tee out/rev06.csv | luajit trendcalculus.lua -F "," -OFS "," -p 7 -h -H -n $p -r  \
        | tee out/rev07.csv | luajit trendcalculus.lua -F "," -OFS "," -p 8 -h -H -n $p -r  \
        | tee out/rev08.csv | luajit trendcalculus.lua -F "," -OFS "," -p 9 -h -H -n $p -r  \
        | tee out/rev09.csv | luajit trendcalculus.lua -F "," -OFS "," -p 10 -h -H -n $p -r  \
        | tee out/rev10.csv | luajit trendcalculus.lua -F "," -OFS "," -p 11 -h -H -n $p -r  \
        | tee out/rev11.csv | luajit trendcalculus.lua -F "," -OFS "," -p 12 -h -H -n $p -r  \
        | tee out/rev12.csv | luajit trendcalculus.lua -F "," -OFS "," -p 13 -h -H -n $p -r  \
	| tee out/rev13.csv | luajit trendcalculus.lua -F "," -OFS "," -p 14 -h -H -n $p -r > out/rev14.csv

 time cat db_output.csv |  luajit trendcalculus.lua -F "," -OFS "," -p 1 -h -H -n $z -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev01.csv |  luajit trendcalculus.lua -F "," -OFS "," -p 2 -h -H -n $p -s| luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev02.csv | luajit trendcalculus.lua -F "," -OFS "," -p 3 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev03.csv | luajit trendcalculus.lua -F "," -OFS "," -p 4 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev04.csv | luajit trendcalculus.lua -F "," -OFS "," -p 5 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev05.csv | luajit trendcalculus.lua -F "," -OFS "," -p 6 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev06.csv | luajit trendcalculus.lua -F "," -OFS "," -p 7 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev07.csv | luajit trendcalculus.lua -F "," -OFS "," -p 8 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev08.csv | luajit trendcalculus.lua -F "," -OFS "," -p 9 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev09.csv | luajit trendcalculus.lua -F "," -OFS "," -p 10 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev10.csv | luajit trendcalculus.lua -F "," -OFS "," -p 11 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev11.csv | luajit trendcalculus.lua -F "," -OFS "," -p 12 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev12.csv | luajit trendcalculus.lua -F "," -OFS "," -p 13 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev13.csv | luajit trendcalculus.lua -F "," -OFS "," -p 14 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS "," > out/srev14.csv


mv db_output.csv out/.
wc -l out/*.csv





