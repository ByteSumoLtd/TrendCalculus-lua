
# Benchmarketing TrendCalculus Reversal logic
# This script generates a clean set of test files from which to test other implementations of TrendCalculus
 
# 2015-06
# see LICENSE for details

# for fast multiscale reversal finding, I stack up the reversal finder.

# this will create a B-Tree of multiscale trend time segments, with a depth equal to the max value of -pass.

# Here we set the WindowSize N, representing the number of observations used to create a FHLS bar, and from there determine trend reversals.
# We set the window size to 3, the minimum sensible size, (although 2 does work) and to push the data through multiple passes.
# We will number each pass, using the parameter -p to label them in the output.

# set our window sizes, for the first pass, and then for all subsequent passes.

z=3  # set this to N for the first run. It is the number of first-pass observations to use in the trend identification window
p=3 # set this to 2 so we can build, bottom-up, the levelling in the B-Tree of trends

src="data/"    # this is the directory for input data in trendcalculus-public

name="SPXUSD_MIN"
# we will write the benchmark files to the benchmark directory

rm benchmark/*.csv

# for ease, we copy the provided data filespec to a named local file
cp ${src}${name}.csv input_datafile.csv

# the options are: -F "input delimeter" -OFS "output delimeter" -h "input has headers" -H "produce ouput headers" -n "set windowsize, in number of observations" -r "produce trend reversal data outputs" 
time cat input_datafile.csv |  lua trendcalculus.lua -F "," -OFS "," -p 1 -h -H -n $z -r \
	| tee benchmark/rev01.csv |  lua trendcalculus.lua -F "," -OFS "," -p 2 -h -H -n $p -r \
        | tee benchmark/rev02.csv | lua trendcalculus.lua -F "," -OFS "," -p 3 -h -H -n $p -r  \
        | tee benchmark/rev03.csv | lua trendcalculus.lua -F "," -OFS "," -p 4 -h -H -n $p -r  \
        | tee benchmark/rev04.csv | lua trendcalculus.lua -F "," -OFS "," -p 5 -h -H -n $p -r  \
        | tee benchmark/rev05.csv | lua trendcalculus.lua -F "," -OFS "," -p 6 -h -H -n $p -r  \
        | tee benchmark/rev06.csv | lua trendcalculus.lua -F "," -OFS "," -p 7 -h -H -n $p -r  \
        | tee benchmark/rev07.csv | lua trendcalculus.lua -F "," -OFS "," -p 8 -h -H -n $p -r  \
        | tee benchmark/rev08.csv | lua trendcalculus.lua -F "," -OFS "," -p 9 -h -H -n $p -r  \
        | tee benchmark/rev09.csv | lua trendcalculus.lua -F "," -OFS "," -p 10 -h -H -n $p -r  \
        | tee benchmark/rev10.csv | lua trendcalculus.lua -F "," -OFS "," -p 11 -h -H -n $p -r  \
        | tee benchmark/rev11.csv | lua trendcalculus.lua -F "," -OFS "," -p 12 -h -H -n $p -r  \
        | tee benchmark/rev12.csv | lua trendcalculus.lua -F "," -OFS "," -p 13 -h -H -n $p -r  \
	| tee benchmark/rev13.csv | lua trendcalculus.lua -F "," -OFS "," -p 14 -h -H -n $p -r > benchmark/rev14.csv

mv input_datafile.csv benchmark/input_datafile.csv
wc -l benchmark/*.csv

