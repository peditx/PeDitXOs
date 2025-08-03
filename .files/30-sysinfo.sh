#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LANG=en_US.UTF-8

THIS_SCRIPT="sysinfo"
MOTD_DISABLE=""

SHOW_IP_PATTERN="^[ewr].*|^br.*|^lt.*|^umts.*"

DATA_STORAGE=/userdisk/data
MEDIA_STORAGE=/userdisk/snail


# don't edit below here
function display()
{
	# $1=name $2=value $3=red_limit $4=minimal_show_limit $5=unit $6=after $7=asc/desc
	# battery red color logic is opposite, lower number is critical
	if [[ "$1" == "Battery" ]]; then
		local great="<";
	else
		local great=">";
	fi
	if [[ -n "$2" && "$2" > "0" && (( "${2%.*}" -ge "$4" )) ]]; then
		printf "%-14s%s" "$1:"
		if awk "BEGIN{exit ! ($2 $great $3)}"; then
			echo -ne "\e[0;91m $2";
		else
			echo -ne "\e[0;92m $2";
		fi
		printf "%-1s%s\x1B[0m" "$5"
		printf "%-11s%s\t" "$6"
		return 1
	fi
} # display


function get_ip_addresses()
{
	local ips=()
	for f in /sys/class/net/*; do
		local intf=$(basename $f)
		# match only interface names starting with e (Ethernet), br (bridge), w (wireless), r (some Ralink drivers use ra<number> format)
		if [[ $intf =~ $SHOW_IP_PATTERN ]]; then
			local tmp=$(ip -4 addr show dev $intf | awk '/inet/ {print $2}' | cut -d'/' -f1)
			# add both name and IP - can be informative but becomes ugly with long persistent/predictable device names
			#[[ -n $tmp ]] && ips+=("$intf: $tmp")
			# add IP only
			[[ -n $tmp ]] && ips+=("$tmp")
		fi
	done
	echo "${ips[@]}"
} # get_ip_addresses


function storage_info()
{
	# storage info
	RootInfo=$(df -h /)
	root_usage=$(awk '/\// {print $(NF-1)}' <<<${RootInfo} | sed 's/%//g')
	root_total=$(awk '/\// {print $(NF-4)}' <<<${RootInfo})
} # storage_info


# query various systems and send some stuff to the background for overall faster execution.
# Works only with ambienttemp and batteryinfo since A20 is slow enough :)
storage_info
critical_load=$(( 1 + $(grep -c processor /proc/cpuinfo) / 2 ))

# get uptime, logged in users and load in one take
UptimeString=$(uptime | tr -d ',')
time=$(awk -F" " '{print $3" "$4}' <<<"${UptimeString}")
load="$(awk -F"average: " '{print $2}'<<<"${UptimeString}")"
case ${time} in
	1:*) # 1-2 hours
		time=$(awk -F" " '{print $3" hours"}' <<<"${UptimeString}")
		;;
	*:*) # 2-24 hours
		time=$(awk -F" " '{print $3" hours"}' <<<"${UptimeString}")
		;;
	*day) # days
		days=$(awk -F" " '{print $3" days"}' <<<"${UptimeString}")
		time=$(awk -F" " '{print $5}' <<<"${UptimeString}")
		time="$days "$(awk -F":" '{print $1" hours "$2" minutes"}' <<<"${time}")
		;;
esac


# memory and swap
mem_info=$(LC_ALL=C free -w 2>/dev/null | grep "^Mem" || LC_ALL=C free | grep "^Mem")
memory_usage=$(awk '{printf("%.0f",(($2-($4+$6))/$2) * 100)}' <<<${mem_info})
memory_total=$(awk '{printf("%d",$2/1024)}' <<<${mem_info})
swap_info=$(LC_ALL=C free -m | grep "^Swap")
swap_usage=$( (awk '/Swap/ { printf("%3.0f", $3/$2*100) }' <<<${swap_info} 2>/dev/null || echo 0) | tr -c -d '[:digit:]')
swap_total=$(awk '{print $(2)}' <<<${swap_info})

c=0
while [ ! -n "$(get_ip_addresses)" ];do
	[ $c -eq 3 ] && break || let c++
	sleep 1
done
ip_address="$(get_ip_addresses)"

# display info
display "System Load" "${load%% *}" "${critical_load}" "0" "" "${load#* }"
printf "Uptime:  \x1B[92m%s\x1B[0m\t\t" "$time"
echo "" # fixed newline


display "Memory Used" "$memory_usage" "70" "0" " %" " of ${memory_total}MB"
display "Swap Used" "$swap_usage" "10" "0" " %" " of $swap_total""MB"
printf "IP Address:  \x1B[92m%s\x1B[0m" "$ip_address"
echo "" # fixed newline

display "Disk Usage" "$root_usage" "90" "1" "%" " of $root_total"
if [ -x /sbin/cpuinfo ]; then
	printf "CPU Info: \x1B[92m%s\x1B[0m\t" "$(echo `/sbin/cpuinfo | cut -d ' ' -f -4`)"
fi
echo ""
echo ""
