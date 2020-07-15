# benchmark trend reversal data

I have included a script in the top directory called benchmark.sh
If you execute it, assuming you have lua installed, it will produce the data in this directory.
The purpose of these files is to provide a data quality benchmark, to prove that your implementation of TrendCalculus 
produces the same results as the reference implementation.

The files read in dirty min data for the SPX at a minute level, closing prices on bars only, and passes them through successive 
passes of the trendcalculus algorithm, to stack up reversals into a multi-scale trend ouput.

To test your implementation, try and recreate these files, and test they are equivalent.

```
recordcount filename

  2265047 input_datafile.csv
   391176 rev01.csv
    86059 rev02.csv
    20729 rev03.csv
     5223 rev04.csv
     1285 rev05.csv
      305 rev06.csv
       71 rev07.csv
       20 rev08.csv
        4 rev09.csv
        1 rev10.csv
        1 rev11.csv
        1 rev12.csv
        1 rev13.csv
        1 rev14.csv
```



Andrew
