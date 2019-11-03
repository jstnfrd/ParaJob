#!/bin/sh
# parajobLauncher.sh: run multiple instances of matlab for parameter studies

# modes: 0=slave, 1=re-start all jobs, 2=restart pending and failed jobs

max_inst_default=8;
mode_default=1; 

case $# in
  3)
    studyset=$1;
    max_inst=$2;
    curr_mode=$3;
    ;;
  2)
    studyset=$1;
    max_inst=$2;
    curr_mode=$mode_default
    ;;
  1)
    studyset=$1;
    max_inst=$max_inst_default
    curr_mode=$mode_default
    ;;
  *)
    echo "usage: $0 studyset [max_inst=$max_inst_default] [mode=$mode_default]"
    exit 1
    ;;
esac

echo "max: $max_inst, mode: $mode_default, studyset: $studyset"

logpath=Modules/ParaJob/Res/Logs
errorpath=Modules/ParaJob/Res
curr_inst=0


rm $logpath/*.*
rm $errorpath/Error_*.txt
mkdir -p $logpath

while [ $curr_inst -lt $max_inst ]
do

	cmd='matlab -nodisplay -nosplash -singleCompThread -r parajobRunner('$curr_mode','$studyset','$curr_inst');exit();' #'
	outfile=`printf $logpath/inst_%02d.log $curr_inst` #'

  #echo $cmd 
	nohup $cmd > $outfile 2>&1 & 
	sleep .5

	curr_inst=`expr $curr_inst + 1`
	curr_mode='0'
done
