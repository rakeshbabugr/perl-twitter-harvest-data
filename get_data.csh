perl -i -pe "s/handle\s*:\s*\w*/handle : realitycheckind/g" get_data.conf
./get_data.pl
mv temp_write realitycheckind.txt
perl -i -pe "s/handle\s*:\s*\w*/handle : prasannavishy/g" get_data.conf
./get_data.pl
mv temp_write prasannavishy.txt
perl -i -pe "s/handle\s*:\s*\w*/handle : PM0India/g" get_data.conf
./get_data.pl
mv temp_write PM0India.txt
perl -i -pe "s/handle\s*:\s*\w*/handle : offstumped/g" get_data.conf
./get_data.pl
mv temp_write offstumped.txt
perl -i -pe "s/handle\s*:\s*\w*/handle : amishra77/g" get_data.conf
./get_data.pl
mv temp_write amishra77.txt
perl -i -pe "s/handle\s*:\s*\w*/handle : swaraj_india/g" get_data.conf
./get_data.pl
mv temp_write swaraj_india.txt
perl -i -pe "s/handle\s*:\s*\w*/handle : DilliDurAst/g" get_data.conf
./get_data.pl
mv temp_write DilliDurAst.txt
perl -i -pe "s/handle\s*:\s*\w*/handle : sagarikaghose/g" get_data.conf
./get_data.pl
mv temp_write sagarikaghose.txt
perl -i -pe "s/handle\s*:\s*\w*/handle : swamy39/g" get_data.conf
./get_data.pl
mv temp_write swamy39.txt
