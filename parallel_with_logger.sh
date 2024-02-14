#!/bin/bash
declare -i pid
declare -a pid_list
declare -A process_dict

declare -i logger_pid
declare -A logger_pid_dict

declare -i count
count=0

declare -i count1
count1=0

declare -i max_threads
max_threads=2

log_file="#specify the filename of the log file"

files=(
	# Specify the file names to run
)

wait_time_logger=1 # in seconds
sim_offset_time=10 # in seconds
check_finished_time=5 # in seconds



startProcessLogger() {
	# First Input argument is the PID and the second argument is Name of the code running
	# Log the resource utilization of the processes every 120 seconds
	while true
	do 
		top_out=$(top -n 1 -b | grep $1)
		echo "$2 ${top_out}" >> $log_file
		sleep $wait_time_logger # specify the sleep times
	done
}


for line in "${files[@]}"
do
	if [ $count -eq 0 ]
	then
		python "$line" &
		pid=$!
		pid_list+=($pid)
		count=$count+1
        echo "#################################################" >> $log_file
        echo "Running" "$line" "Pid = " "$pid" >> $log_file
        echo "#################################################" >> $log_file
		process_dict[$pid]="$line"
		
		startProcessLogger $pid "$line" &
		logger_pid=$!
		logger_pid_dict[$pid]=$logger_pid


	elif [ $count -lt $max_threads ]
	then
		sleep $sim_offset_time # Start the simulations at a gap of 10 mins to remove peak RAM usage at the same time
		python "$line" &
		pid=$!
		pid_list+=($pid)
		count=$count+1
		echo "#################################################" >> $log_file
		echo "Running" "$line" "Pid = " "$pid" >> $log_file
		echo "#################################################" >> $log_file
		process_dict[$pid]="$line"

		startProcessLogger $pid "$line" &
		logger_pid=$!
		logger_pid_dict[$pid]=$logger_pid

	else
		count1=$count
		while true
		do
			for i in ${pid_list[*]}
			do 
				if ps -p $i > /dev/null
				then
					echo "Still running ..." "${process_dict[$i]}"
				else
					pid_list=(${pid_list[*]/$i})
					echo "#################################################" >> $log_file
					echo "Finished" "${process_dict[$i]}" "Pid = " "$i" >> $log_file
					echo "#################################################" >> $log_file
					count1=$count1-1

					kill ${logger_pid_dict[$i]}
				fi
			done
		
			if [ $count1 -eq $count ]
			then 
				sleep $check_finished_time # This checks every 5mins whether any program has stopped
		
			else
				sleep $sim_offset_time # Start the simulations at a gap of 10 mins to remove peak RAM usage at the same time
				python "$line" &
				count=$count1+1
				pid=$!
				pid_list+=($pid)
				echo "#################################################" >> $log_file
				echo "Running" "$line" "Pid = " "$pid" >> $log_file
				echo "#################################################" >> $log_file
				process_dict[$pid]="$line"
				
				startProcessLogger $pid "$line" &
				logger_pid=$!
				logger_pid_dict[$pid]=$logger_pid

				break
			fi 
		done
	fi	 
done


#Finally check the rest of processes have stopped and all the loggers are killed
for i in ${pid_list[*]}
do
	while true
	do
		if ps -p $i > /dev/null
		then
			echo "Still running ..." "${process_dict[$i]}"
		else
			pid_list=(${pid_list[*]/$i})
			echo "#################################################" >> $log_file
			echo "Finished" "${process_dict[$i]}" "Pid = " "$i" >> $log_file
			echo "#################################################" >> $log_file

			kill ${logger_pid_dict[$i]}
			break
		fi
		sleep $check_finished_time
	done
done

