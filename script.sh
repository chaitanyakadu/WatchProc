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
function get_proc_id {
  # collect proc name
  proc_name=$1
  if [[ -z $proc_name ]]; then 
    tput setaf 1; printf "The get_proc_id function is called without providing the process name\n"; tput sgr0;
  fi

  # is there any active process
  active_count=$(pgrep -c $proc_name)
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
    echo $pid
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
pid=$1 

if [ ! -z $pid ]; then
  verify_pid $pid
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
  read cpu mem state cmd < <(ps -p $pid -o %cpu,%mem,state,cmd --no-headers)
  printf "%-10s %-10s %-10s\n" "PID" $pid
  printf "%-10s %-10s %-10s\n" "%CPU" $cpu
  printf "%-10s %-10s %-10s\n" "%MEM" $mem
  printf "%-10s %-10s %-10s\n" "State" $state
  printf "%-10s %-10s %-10s\n" "CMD" $cmd
}

tput civis

while true; do 
  tput clear
  print_metrics

  sleep $interval
done

