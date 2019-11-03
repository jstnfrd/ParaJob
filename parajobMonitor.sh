#!/bin/sh
# monitorStudyMulti.sh: monitor current progress of a study.
# usage: ./parajobMonitor.sh <StudyParamSet>

case $# in
  1)
    studyset=$1;
    ;;
  0)
    studyset=0;
    ;;
  *)
    echo "usage: $0 [studyset=0]"
    exit 1
    ;;
esac

matlab -r "while 1; clc; pjJobManager($studyset,2);pause(3);end"