\rm 0.txt
\rm 1.txt
\rm 2.txt
\rm 3.txt
\rm 4.txt
\rm 5.txt
\rm 6.txt
\rm 7.txt
\rm 8.txt
\rm 9.txt
\rm 10.txt
\rm 11.txt
\rm 12.txt
\rm 13.txt
\rm 14.txt
\rm 15.txt
\rm 16.txt
./parse_data.pl DilliDurAst.txt > /dev/null
./cut_r.pl r_script.r
./parse_data.pl PM0India.txt > /dev/null
./cut_r.pl r_script.r
./parse_data.pl amishra77.txt > /dev/null
./cut_r.pl r_script.r
./parse_data.pl auldtimer.txt > /dev/null
./cut_r.pl r_script.r
./parse_data.pl bdutt.txt > /dev/null
./cut_r.pl r_script.r
./parse_data.pl offstumped.txt > /dev/null
./cut_r.pl r_script.r
./parse_data.pl prasannavishy.txt > /dev/null
./cut_r.pl r_script.r
./parse_data.pl realitycheckind.txt > /dev/null
./cut_r.pl r_script.r
./parse_data.pl sagarikaghose.txt > /dev/null
./cut_r.pl r_script.r
./parse_data.pl swamy39.txt > /dev/null
./cut_r.pl r_script.r
./parse_data.pl swaraj_india.txt > /dev/null
./cut_r.pl r_script.r
cat r_header.r > master_r_script.r
cat 0.txt >> master_r_script.r 
cat 1.txt >> master_r_script.r 
cat 2.txt >> master_r_script.r 
cat 3.txt >> master_r_script.r 
cat 4.txt >> master_r_script.r 
cat 5.txt >> master_r_script.r 
cat 6.txt >> master_r_script.r 
cat 7.txt >> master_r_script.r 
cat 8.txt >> master_r_script.r 
cat 9.txt >> master_r_script.r 
cat 10.txt >> master_r_script.r 
cat 11.txt >> master_r_script.r 
cat 12.txt >> master_r_script.r 
cat 13.txt >> master_r_script.r 
cat 14.txt >> master_r_script.r 
cat 15.txt >> master_r_script.r 
cat 16.txt >> master_r_script.r 
R --no-save < master_r_script.r > output.txt
