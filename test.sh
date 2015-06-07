# for fast multiscale reversal finding, I run it on an n=5, and stream output back through the algo 3 more times in a stack.
# this will create a B-Tree depth of max 4.
# will it run faster? 

z=5  # set this to N for the first run. it is the number of first pass observations to use in the trend identification window
p=2  # set this to 2 so we can build bottom-up the levelling in the B-Tree of trends

src="data/"    # this is the directory for input data in trendcalculus-public


name="all_DJI"

cp ${src}db_output_${name}.csv db_output.csv


time cat db_output.csv |  luajit trendcalculus.lua -F "," -OFS "," -p 1 -h -H -n $z -r \
	| tee out/rev1.csv |  luajit trendcalculus.lua -F "," -OFS "," -p 2 -h -H -n $p -r \
        | tee out/rev2.csv | luajit trendcalculus.lua -F "," -OFS "," -p 3 -h -H -n $p -r  \
	| tee out/rev3.csv | luajit trendcalculus.lua -F "," -OFS "," -p 4 -h -H -n $p -r > out/rev4.csv

time cat db_output.csv |  luajit trendcalculus.lua -F "," -OFS "," -p 1 -h -H -n $z -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev1.csv |  luajit trendcalculus.lua -F "," -OFS "," -p 2 -h -H -n $p -s| luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev2.csv | luajit trendcalculus.lua -F "," -OFS "," -p 3 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS ","  \
        | tee out/srev3.csv | luajit trendcalculus.lua -F "," -OFS "," -p 4 -h -H -n $p -s | luajit rev.lua -F "," -h -H -s -OFS "," > out/srev4.csv

mv db_output.csv out/.
wc -l out/*.csv
rm out/db_output.csv





