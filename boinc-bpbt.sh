#!/bin/bash

BOINCCMD="/usr/bin/boinccmd"
BOINCPERF="/etc/boinc-client/global_prefs_override.xml"
HOME=/home/aaeon
PATH=$HOME/bin:$PATH

if [ "x$1" == "xbp" ]; then
	echo -n -e "======== Perf ========\ncpu_usage_limit: "
	xml_grep --Text cpu_usage_limit $BOINCPERF
	eval "$BOINCCMD --get_project_status" | sed -e 's/\r//g' | grep -e "master URL" -e "host_*_" -e "------" -e "======" -e "suspended via" -e "don.t request" -e "resource share"

elif [ "x$1" == "xbt" ]; then
	eval "$BOINCCMD --get_tasks" | sed -e 's/\r//g' | grep -e "  name" -e "project URL" -e "fraction done:" -e "active_task_state:" -e "------" -e "deadline" -e "resource" -e "  state:"

elif [ "x$1" == "xbp2" ]; then
	eval "$BOINCCMD --get_simple_gui_info" | sed -e 's/\r//g' | grep -e "master URL" -e "host_*_" -e "WU name" -e "project URL" -e "fraction done:" -e "------" -e "======" -e "suspended via" -e "don.t request" -e "resource" -e "active_task_state:"

elif [ "x$1" == "xbt2" ]; then
	echo "======== Total Tasks ========"
	eval "$BOINCCMD --get_tasks" | sed -e 's/\r//g' | grep -e proj | word_counter `eval "$BOINCCMD --get_project_status" | sed -e 's/\r//g' | grep "master URL:" | cut -d" " -f 6- | paste -sd " " - ` | sed -e "s/https\{0,\}:\/\//project: /g" | column -t
	echo "======== Total Reports (1 day) ========"
	A=`boinc_msg_1d | grep Report | grep -v '====' | sed 's/^.\+\(\[.\+\]\).\+/\1/' | sed 's/ /_/g'`
	B=`echo "$A" | sort | uniq | paste -sd' ' -`
	echo "$A" | word_counter "$B" | sed 's/^\([\[]\)/report: \1/' | column -t
else

	echo -n -e "======== Perf ========\ncpu_usage_limit: "
	xml_grep --Text cpu_usage_limit $BOINCPERF

	echo "======== Total Tasks ========"
	eval "$BOINCCMD --get_tasks" | sed -e 's/\r//g' | grep -e proj | word_counter `eval "$BOINCCMD --get_project_status" | sed -e 's/\r//g' | grep "master URL:" | awk '{ print $3 }' | paste -sd " " - ` | sed -e "s/https\{0,\}:\/\//project: /g" | column -t

	eval "$BOINCCMD --get_simple_gui_info" | sed -e 's/\r//g' | grep -e "master URL" -e "host_*_" -e "WU name" -e "project URL" -e "fraction done:" -e "------" -e "======" -e "resource" -e "suspended via" -e "don't request" -e "deadline";

	echo "======== Total Reports (1/5/10 day) ========"
	A=`boinc_msg_1d5d10d | grep Report | grep -v '====' | sed 's/^.\+\(\[.\+\]\).\+/\1/' | sed 's/ /_/g'`
	B=`echo "$A" | sort | uniq | paste -sd' ' -`
	echo "$A" | word_counter "$B" | sed 's/^\([\[]\)/report (_1d): \1/' | sed 's/\([0-9]\+\)$/\t\1/' | column -t
	A=`boinc_msg_1d5d10d 5 | grep Report | grep -v '====' | sed 's/^.\+\(\[.\+\]\).\+/\1/' | sed 's/ /_/g'`
	B=`echo "$A" | sort | uniq | paste -sd' ' -`
	echo "$A" | word_counter "$B" | sed 's/^\([\[]\)/report (_5d): \1/' | sed 's/\([0-9]\+\)$/\t.\t\1/' | column -t
	A=`boinc_msg_1d5d10d 10 | grep Report | grep -v '====' | sed 's/^.\+\(\[.\+\]\).\+/\1/' | sed 's/ /_/g'`
	B=`echo "$A" | sort | uniq | paste -sd' ' -`
	echo "$A" | word_counter "$B" | sed 's/^\([\[]\)/report (10d): \1/' | sed 's/\([0-9]\+\)$/\t.\t.\t\1/' | column -t
fi
