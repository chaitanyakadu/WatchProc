#!/bin/bash

# verify pid
function verify_pid {
  # collect pid
  pid=$1
  if [[ -z $pid ]]; then 
    tput setaf 1; printf "The verify_pid function is called without providing the pid\n"; tput sgr0;
  fi

  if [[ ! -d "/proc/$pid" ]]; then
    tput setaf 1; printf "The pid($pid) is invalid!\n"; tput sgr0;
    exit 1
  fi 
}

# get pid using process name
function get_pid {
  # collect proc name
  proc_name=$1
  if [[ -z $proc_name ]]; then 
    tput setaf 1; printf "The get_pid function is called without providing the process name\n"; tput sgr0;
  fi

  # is there any active process
  active_count=$(pgrep -c "$proc_name")
  if [[ $active_count -eq 0 ]]; then
    tput setaf 3; printf "There is no $proc_name process currently active\n"; tput sgr0;
    exit 1
  fi 

  # are there multiple active process
  # then seek for pid instead
  if [[ $active_count -gt 1 ]]; then
    printf "Currently there are multiple $proc_name processes active. Try again with pid instead!\n"
    echo 
    printf "Check out all the $proc_name pid's:\n"
    printf "$(pgrep $proc_name -l)\n"
    printf "For more details checkout "; tput setaf 4; printf "pgrep $proc_name -a "; tput sgr0; printf "for pid and full command line\n"
    exit 0
  fi

  # set the pid if active process is 1
  if [[ $active_count -eq 1 ]]; then
    pid=$(pgrep $proc_name)
  else 
    tput setaf 2; printf "Unknown Error! The $proc_name process has unexpected active count\n"; tput sgr0;
    exit 1
  fi
}

# display help data
function help_data {
  printf "Usage: watchproc process_name/pid [OPTION...]\n"
  echo 
  printf "  -i, set refresh interval(default 2)\n"
  printf "  -h, get the help list\n"
  echo 
  printf "The process name/id is mandetory wheras all the options are optional.\n"
}


# Start..
value=$1 

if [[ $value =~ [a-zA-Z] ]]; then
  get_pid $value
  verify_pid $pid
  shift
elif [ ! -z $value ]; then
  verify_pid $value
  shift
else 
  tput setaf 3; printf "Process name or PID is missing!\n"; tput sgr0;
  help_data
  exit 1
fi

interval=2 # default

while getopts ":i:h" option; do 
  case $option in 
    i) 
      interval="$OPTARG"
      ;;
    h) 
      help_data
      exit 0
      ;;
    \?)
      tput setaf 3; printf "Invalid option: $OPTARG \n"; tput sgr0;
      help_data
      exit 1
      ;;
  esac
done

# print metrics
function print_metrics {
  read cpu mem cmd < <(ps -p $pid -o %cpu,%mem,cmd --no-headers)
  read user_time kernel_time total_threads start_time < <(cat "/proc/$pid/stat" | awk -F' ' '{print $14, $15, $20, $22}')
  read read_bytes < <(sudo cat "/proc/$pid/io" | awk -F':' '/^read_bytes/ {print $2}')
  read write_bytes < <(sudo cat "/proc/$pid/io" | awk -F':' '/^write_bytes/ {print $2}')
  read name < <(cat "/proc/$pid/status" | awk -F':' '/^Name/ {print $2}')
  read state < <(cat "/proc/$pid/status" | awk -F':' '/^State/ {print $2}')
  read vctx < <(cat "/proc/$pid/status" | awk -F':' '/^voluntary_ctxt_switches/ {print $2}')
  read nvctx < <(cat "/proc/$pid/status" | awk -F':' '/^nonvoluntary_ctxt_switches/ {print $2}')
  read sum_exec_runtime < <(cat "/proc/$pid/sched" | awk -F':' '/^se.sum_exec_runtime / {print $2}')
  read nr_switches < <(cat "/proc/$pid/sched" | awk -F':' '/^nr_switches / {print $2}')

  declare -A metrics_arr
  metrics_arr["PID"]="$pid"
  metrics_arr["%CPU"]="$cpu"
  metrics_arr["%MEM"]="$mem"
  metrics_arr["CMD"]="$cmd"

  metrics_arr["USER_TIME"]="$user_time"
  metrics_arr["KERNEL_TIME"]="$kernel_time"
  metrics_arr["THREADS"]="$total_threads"
  metrics_arr["START_TIME"]="$start_time"

  metrics_arr["READ_BYTES"]="$read_bytes"
  metrics_arr["WRITE_BYTES"]="$write_bytes"

  metrics_arr["NAME"]="$name"
  metrics_arr["STATE"]="$state"
  metrics_arr["VOLUNTARY_CTX"]="$vctx"
  metrics_arr["NONVOLUNTARY_CTX"]="$nvctx"

  metrics_arr["SUM_EXEC_RUNTIME"]="$sum_exec_runtime"
  metrics_arr["NR_SWITCHES"]="$nr_switches"

  printf "Last Updated: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  for i in "${!metrics_arr[@]}"; do 
    printf "\033[34m%-20s\033[0m %-20s\n" "$i" "${metrics_arr[$i]}"
  done
}

while true; do 
  tput clear
  print_metrics

  sleep $interval
done
