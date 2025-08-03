#!/bin/bash

# TODO get a list of process names to kill

get_process_names() {

        echo "nginx elastic-agent postgres mysqld"
	#echo "mysqld"
}


get_id_process(){

for process_name in "$@"; do
        echo $(pidof $process_name)
        done
}



#while true; do 
# TODO get CPU usage

CPU_usage=$(top -b n1 | grep "Cpu" | awk '{print 100 - $8}')

echo "$CPU_usage"

#  TODO  get threshold 

resource_log=/home/polo/Documentos/VSCode/VSCode/Projects/linux/bash/resource_monitoring/iter_1/resource_log.log

threshold_path=/home/polo/Documentos/VSCode/VSCode/Projects/linux/bash/resource_monitoring/iter_1/threshold.txt

threshold_value=$(cat "$threshold_path")

echo "$threshold_value"

## TODO Asses  if threshoold value is  == to CPU usage

## TODO transfom cpu usage to integer

cpu_usage_int=${CPU_usage%.*}

echo ${cpu_usage_int}


if [[ "$cpu_usage_int" -ge "$threshold_value"  ]]; then 

	echo "CPU usage excedeed threshold value"
	echo "Prioritizing process started...."
	
	## TODO get process_id list 
	id_process_list=$(get_id_process $(get_process_names))
	
	# TODO Check list is not empty 
	
	if [[ "${#id_process_list[@]}" -eq  0  ]] ; then 
		echo "Any process to kill was founded" >> "${resource_log}"
		exit 0 
	else
		## TODO kill process 
		
		for process_id in  "${id_process_list[@]}"; do
			echo "${process_id}"	
			process_name=$(ps -p "${process_id}" -o comm=)
			
			echo "${process_name}"

			if [[ ${process_name} =~  ^mysqld$ ]]; then 

				service_name=mysql
			else
				service_name="${process_name}"
			fi
			
			systemctl stop "${service_name}"
			echo "Process "${service_name}" is inactive now"
		done
	fi
else
	
	echo "CPU usage under normal limits"
	exit 0 


fi 


#sleep 5 
#done 
