cd /Users/andrewmorgan/trendcalculus-public ; export PATH=~/torch/install/bin:$PATH ; luajit trendcalculus.lua -h -H -p 1 -r -n 2 -f /Users/andrewmorgan/trendcalculus-public/data/r_in.csv |tee /Users/andrewmorgan/trendcalculus-public/out/r_out.csv | luajit trendcalculus.lua -h -H -p 2 -r -n 2 |tee -a /Users/andrewmorgan/trendcalculus-public/out/r_out.csv | luajit trendcalculus.lua -h -H -p 3 -r -n 2 |tee -a /Users/andrewmorgan/trendcalculus-public/out/r_out.csv | luajit trendcalculus.lua -h -H -p 4 -r -n 2 |tee -a /Users/andrewmorgan/trendcalculus-public/out/r_out.csv | luajit trendcalculus.lua -h -H -p 5 -r -n 2 |tee -a /Users/andrewmorgan/trendcalculus-public/out/r_out.csv | luajit trendcalculus.lua -h -H -p 6 -r -n 2 |tee -a /Users/andrewmorgan/trendcalculus-public/out/r_out.csv | luajit trendcalculus.lua -h -H -p 7 -r -n 2 |tee -a /Users/andrewmorgan/trendcalculus-public/out/r_out.csv ; head -1 out/r_out.csv > out/fread.csv; cat out/r_out.csv | grep -v pass >> out/fread.csv