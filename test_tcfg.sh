
# Test TrendCalculus 
# 2015-06
# see LICENSE for details

# for fast multiscale reversal finding, I stack up the reversal finder.

# this will create a B-Tree depth equal to the max value of -pass.
# this is beta code. I noted files over 1.5GB may fail. I'm looking into it.

z=20  # set this to N for the first run. It is the number of first-pass observations to use in the trend identification window
m=480 # when you add this to z, this is how many timeframes you'll generate features for

src="data/"    # this is the directory for input data in trendcalculus-public

rm out/*.csv

name="all_DJI"

cp ${src}db_output_${name}.csv db_output.csv

# the paramter to call to generate trend feature is -g, which uses hindsight and rewind to generate z+m timeframes of features against trend labels found on window z
time cat db_output.csv |  lua tcfg_v1.0.lua -F "," -OFS "," -p 1 -h -H -n $z -m ${m} -g > out/tcfg_output_${z}.csv

mv db_output.csv out/.
wc -l out/*.csv

# NOTES
# this script will generate trend features on z+m timeframes. A trend label is generated for timeframe z.
# use this data to train machine learning algorithms to guess the trend! 
# then when you have the model, stream the data into a function (which you'll need to implement yourself) to generate the trend features that are most predictive
# and use that to guess the predicted trend of the timeseries.
# then you can guess the trend as the timeseries changes in real time.

# this is all written up here if you want more explaination:
# https://github.com/bytesumo/TrendCalculus/blob/master/HowToStudyTrends_v1.03.pdf



