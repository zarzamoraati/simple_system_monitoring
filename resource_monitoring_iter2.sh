#!/bin/bash


## NEW SIMPLIFIED VERSION OF ITER1 

threshold_path=/home/polo/Documentos/VSCode/VSCode/Projects/linux/bash/resource_monitoring/iter_1/threshold.txt
resource_log_path=/home/polo/Documentos/VSCode/VSCode/Projects/linux/bash/resource_monitoring/iter_1/resource_log.log

## TODO define service name list

get_service_name(){
	
	#echo "nginx mysqld elastic-agent postgresql"
	local services=("mysqld" "nginx" "elastic-agent" "postgresql")
	echo "${services[@]}"
}




resource_monitoring(){
## TODO get cpu usage  as int 

if ! cpu_usage=$(top -b n1 | grep "%Cpu" | awk '{print 100 - $8}'); then
	echo "Error failed to get CPU usage at $(date)" >> "${resource_log_path}"
	return 1
fi
echo "${cpu_usage}"

cpu_usage_int=${cpu_usage%.*}

echo "CPU usage: ${cpu_usage_int}" >> "${resource_log_path}"


## TODO get hreshold
threshold=$(cat "$threshold_path")

echo "${threshold}"

## TODO check threshold 

if [[ "${cpu_usage_int}" -ge "${threshold}" ]]; then 
	echo "CPU usage excedeed threshold limit "
	echo "Prioritizing services ...."
	## TODO get list of services 
	#service_list=$(get_service_name) 
	read -r -a service_list <<< "$(get_service_name)"
	echo "${service_list}"
	
	##  TODO check  service list is not empty 
	if [[ "$#{service_list[@]}" -eq 0 ]]; then 

		echo "Any service was founded, nothing to stop ...."
		return 0
		#exit 0
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
		#exit 0
	fi


else
	echo "CPU usage operate under threshold , nothing to do..."
	#exit 0 
fi


}

while true; do

resource_monitoring 

sleep 5

done



