#!/bin/sh
# enable "ps [-p] PID" for /bin/ps from busybox (like Alpine)
# copy this script as /usr/local/bin/ps or /usr/bin/ps, and chmod 755 it.

if [ $# == 1 ]; then
  echo $1 | grep -q -E '^[0-9]+$' # number only argument
  if [ $? == 0 ]; then
    OPT_P=1
    ARG_P=$1
  fi
else
  for OPT in "$@"
  do
    case "$OPT" in
      '-p')
        OPT_P=1
        ARG_P=$2
        shift 2
        ;;
    esac
  done
fi

if [ x$OPT_P == x1 ]; then
  /bin/ps -o pid | grep -q $ARG_P    # grep pid only
  RET=$?
  /bin/ps | egrep "^(PID| *$ARG_P )" # show output like normal ps
  exit $RET
else
  /bin/ps $*
fi
