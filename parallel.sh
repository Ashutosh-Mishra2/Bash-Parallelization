#!/bin/bash
declare -a pid
declare -i count
count=0
declare -i count1
count1=0
declare -i max_threads
max_threads=2

for line in $(cat names.txt)
do
	if [ $count -lt $max_threads ]
	then
		sleep 10
		bash test.sh $line &
		pid+=($!)
		count=$count+1
		echo "Pid = " ${pid[*]}
	else
		count1=$count
		while true
		do
		for i in ${pid[*]}
		do 
			if ps -p $i > /dev/null
			then
				echo "Still running ..."
			else
				pid=(${pid[*]/$i})
				echo "Pid = " ${pid[*]}
				count1=$count1-1
			fi
		done
		if [ $count1 -eq $count ]
		then 
			sleep 60
		else
			sleep 10
			bash test.sh $line &
			count=$count1+1
			pid+=($!)
			echo "Pid = " ${pid[*]}
			break
		fi 
		done
	fi
	 
done
