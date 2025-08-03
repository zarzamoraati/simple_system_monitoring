#!/bin/bash


## NEW SIMPLIFIED VERSION OF ITER1 

threshold_path=/home/polo/Documentos/VSCode/VSCode/Projects/linux/bash/resource_monitoring/iter_1/threshold.txt
resource_log_path=/home/polo/Documentos/VSCode/VSCode/Projects/linux/bash/resource_monitoring/iter_1/resource_log.log

## TODO define service name list

get_service_name(){
	
	echo "nginx mysqld elastic-agent postgresql"

}


resource_monitoring(){
## TODO get cpu usage  as int 

cpu_usage=$(top -b n1 | grep "%Cpu" | awk '{print 100 - $8}')
echo "${cpu_usage}"

cpu_usage_int=${cpu_usage%.*}

echo ${cpu_usage_int}


## TODO get hreshold
threshold=$(cat "$threshold_path")

echo "${threshold}"

## TODO check threshold 

if [[ "${cpu_usage_int}" -ge "${threshold}" ]]; then 
	echo "CPU usage excedeed threshold limit "
	echo "Prioritizing services ...."
	## TODO get list of services 
	service_list=$(get_service_name) 
	echo "${service_list}"
	
	##  TODO check  service list is not empty 
	if [[ "${service_list}" == 0 ]]; then 

		echo "Any service was founded, nothing to stop ...."
		exit 0
	else
		## TODO disabled services
		echo "CPU usage before disabled services ${cpu_usage}% " >> "${resource_log_path}"
		for name in ${service_list[@]}; do 
			echo "${name}"
			if [[ ${name}  == mysqld ]]; then 
			
			service_name="mysql"
			else
			service_name="${name}"
			fi
			echo "${service_name}"
			systemctl stop "${service_name}" >> "${resource_log_path}"
			echo "${service_name} succesfully disabled"  >> "${resource_log_path}"
		
		done
		cpu_usage_update=$(top -b n1 | grep "%Cpu" | awk '{print 100 - $8}') 
		sleep 2
		echo "CPU usage after stop services: ${cpu_usage_update}%" >> "${resource_log_path}"
		exit 0
	fi


else
	echo "CPU usage operate under threshold , nothing to do..."
	exit 0 
fi


}

resource_monitoring



