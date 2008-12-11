#!/bin/bash
JABBIT='ruby lib/jabbit.rb'
if [ $# -eq 0 ]; then
  echo 'usage ./jabbit.sh [start, stop, status]'
else
  if [ $1 = 'start' ]; then
      $JABBIT > jabbit.log 2>&1 &
  elif [ $1 = 'stop' ]; then
     ps aux | grep -v 'grep' | grep "$JABBIT" | awk '{ print $2 }' | xargs kill -9
  elif [ $1 = 'status' ]; then
     ps aux | grep -v 'grep' | grep "$JABBIT"
  elif [ $1 = '-h' ]; then
     echo 'usage ./jabbit.sh [start, stop, status]'
  else
     echo 'usage ./jabbit.sh [start, stop, status]'
  fi
fi
