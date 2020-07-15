
# this script uses a little known option in the trendcalculus code, that outputs FHLS summary information for your timeseries, dependent on your window size set by option  -n 
# Like in the training PDF presentation, it generates the correct information for the "bars" used in trendcalculus that replace OHLC.

# First High Low Close FirstDate LastDate
# << bars are not created with fixed timewindows in trendcalculus, but on N observations. So be mindful of that. If you read in data having a fixed time window, TC will output accordingly, but it doesnt require it.

# notice these bars can be drawn if you'd like, using ANY charting program accepting OHLC, just rename these colums to First=Open Second=Close, and load the data. Note: you may need to remove rows where split = 0
# and you might need to drop some of the columns 

# Below is an example of calling the lua based code to generate this data.
# use this data to doublecheck that you are generating FHLS data correctly, including the "split bars" that accomodate edge cases.

cat ../data/db_output_allDJI.csv | lua ../trendcalculus.lua -F "," -OFS "," -h -H -n 10 -s > test_n10_FHLS_bar_creation.csv
cat test_n10_FHLS_bar_creation.csv | head -10 | column -s, -t

#  below is an example of the output you should see.

# notice carefully the dates, where the split field  is 0 in this example. Notice the offsetdate is the same for both of those rows, on 0 and just after. They were generated on the same offset.
# this is the "splitbar" that outputs a non-standard timewindow allowing us to correctly calculate trend, seen in the last column 


# [andrew@gzet]$ cat ../data/db_output_allDJI.csv | lua ../trendcalculus.lua -F "," -OFS "," -h -H -n 10 -s | head -10 | column -s, -t
# ts_id  opendate    closedate   offsetdate  offset  split  timeframe  measure  first  high   low    second  high_date   low_date    first_date  second_date  trend
# .DJI   1896-05-29  1896-06-06  1896-06-06  10      1      10         40.34    40.63  40.63  39.77  39.77   1896-05-29  1896-06-03  1896-05-29  1896-06-03   -1
# .DJI   1896-06-08  1896-06-18  1896-06-18  20      1      10         39.76    38.41  40.54  38.41  40.54   1896-06-17  1896-06-10  1896-06-10  1896-06-17   -1
# .DJI   1896-06-19  1896-06-30  1896-06-30  30      1      10         36.15    40.03  40.03  35.53  35.53   1896-06-19  1896-06-29  1896-06-19  1896-06-29   -1
# .DJI   1896-07-01  1896-07-11  1896-07-11  40      1      10         35.6     34.59  35.6   34.59  35.6    1896-07-11  1896-07-01  1896-07-01  1896-07-11   -1
# .DJI   1896-07-13  1896-07-23  1896-07-23  50      1      10         32.29    34.69  34.69  30.5   30.5    1896-07-13  1896-07-20  1896-07-13  1896-07-20   -1
# .DJI   1896-07-20  1896-07-28  1896-08-04  60      0      10         30.99    30.5   30.82  30.5   30.82   1896-07-28  1896-07-20  1896-07-20  1896-07-28   -1
# .DJI   1896-07-28  1896-08-04  1896-08-04  60      1      10         30.99    30.82  32.02  30.82  32.02   1896-07-31  1896-07-28  1896-07-28  1896-07-31   1
# .DJI   1896-08-05  1896-08-15  1896-08-15  70      1      10         30.61    30.93  30.93  28.48  28.48   1896-08-05  1896-08-08  1896-08-05  1896-08-08   -1
