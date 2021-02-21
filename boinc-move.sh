#!/bin/bash

colour_support=true
/usr/bin/tput sgr0 >/dev/null 2>&1 || colour_support=false
/usr/bin/tput setaf 2 >/dev/null 2>&1 || colour_support=false

if $colour_support; then
        RED=$(/usr/bin/tput setaf 1)
        GREEN=$(/usr/bin/tput setaf 2)
        YELLOW=$(/usr/bin/tput setaf 3)
        BLUE=$(/usr/bin/tput setaf 4)
        MAGENTA=$(/usr/bin/tput setaf 5)
        CYAN=$(/usr/bin/tput setaf 6)
        WHITE=$(/usr/bin/tput setaf 7)
        CLEAR=$(/usr/bin/tput sgr0)
        /usr/bin/tput sgr0
else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        MAGENTA=""
        CYAN=""
        WHITE=""
        CLEAR=""
fi

sleepseconds=5
[ "x$1" != "x" ] && sleepseconds=`echo $1 | awk '{printf "%d", $1}'`
declare -a arrsub
declare -a arr
IFS=$'\n'

declare -a arrproj
declare -a arrname
declare -A arrrevnameid
declare -a arrcurtime
declare -a arrestrmtime
declare -a arrcurday
declare -a arrestrmday
declare -a arrduedate

declare -A myArray

now=`date +%s`

myArray=(\
	['milkyway.cs.rpi.edu/milkyway/']='MilkyWay' \
	['einstein.phys.uwm.edu/']='Einstein' \
	['boinc.bakerlab.org/rosetta/']='Rosetta' \
	['setiathome.berkeley.edu/']='SETI' \
	['lhcathome.cern.ch/lhcathome/']='LHC' \
	['www.worldcommunitygrid.org/']='WCG')

j=0
for i in `boinccmd --get_simple_gui_info | grep -e fract -e 'project URL' -e '  name:' -e current -e estimate -e "report de" | grep -B 5 fract`; do
	[ ${i:3:2} == "pr" ] && UU=`/bin/echo ${i:16} | /bin/sed -e 's/[^:]*:\/\///g'` && arrproj[$j]=${myArray[$UU]}
	[ ${i:3:2} == "na" ] && arrname[$j]=${i:9} && arrrevnameid["${i:9}"]=$j
	[ ${i:3:2} == "cu" ] && SECS=`echo ${i:20} | awk '{printf "%d", $1}'` && arrcurday[$j]=$((SECS/86400)) && arrcurtime[$j]=$(date -d "1970-01-01 + $SECS seconds" "+%H:%M:%S")
	[ ${i:3:2} == "es" ] && SECS=`echo ${i:32} | awk '{printf "%d", $1}'` && arrestrmday[$j]=$((SECS/86400)) && arrestrmtime[$j]=$(date -d "1970-01-01 + $SECS seconds" "+%H:%M:%S")
	[ ${i:3:2} == "re" ] && thennn=`date +"%s" --date="${i:20}"` && SECS=$((thennn - now)) && arrduedate[$j]="$((SECS/86400))d." && arrduedate[$j]+=$(date -d "1970-01-01 + $SECS seconds" "+%H:%M:%S")
	[ ${i:3:2} == "fr" ] && arrsub[$j]=0 && j=$((j+1));
done;

[ $j -eq 0 ] && exit 0

for k in {1..2}; do 
	j=0
	for i in `boinccmd --get_simple_gui_info | grep -e fract -e "  name:" | grep -B 1 -e fract`; do
		if [ ${i:3:2} == "na" ]; then
			if [ "${arrname[$j]}" != "${i:9}" ]; then
				echo "Active WU changed... ${arrname[$j]} != ${i:9}" 1>&2
				wuidx1=${arrrevnameid["${arrname[$j]}"]}
				wuidx2=${arrrevnameid["${i:9}"]}
				[ -z "$wuidx2" ] && wuidx2=$j
				echo ">>> Index before of $((wuidx1+1)) != Index after of $((wuidx2+1)) ..." 1>&2
				echo ">>> Abort now..."  1>&2
				exit 255
			fi
		fi
		if [ ${i:3:2} == "fr" ]; then
			i=`echo $i | awk '{print $3}'`
			arr[$j]=$i; arrsub[$j]=`echo ${arr[$j]} ${arrsub[$j]} | awk '{print $1-$2}'`; 
			j=$((j+1));
		fi
	done; 
	[ $k == 1 ] && echo -n "Interval sleep ${sleepseconds}s " 1>&2 && for c in $(seq 1 $sleepseconds); do echo -n '.' 1>&2; sleep 1s; done && echo 1>&2
done;

echo 1>&2
echo "Verified WU name and order in active list..." 1>&2
for i in "${!arrrevnameid[@]}"; do 
	j=${arrrevnameid["$i"]}
	j=$((j+1))
	echo "$ "$i" @ "$j 
done | sort -n -k 4 1>&2
echo 1>&2

j=0
for i in `boinccmd --get_simple_gui_info |  grep resources | cut -d' ' -f5-`; do
	echo -n ${CLEAR}${WHITE}
	if [ ${arrsub[$j]} != 0 ]; then
		echo -n $j ${arr[$j]} ${arrsub[$j]} | awk '{printf "[%2d:%8.4f%%] %7.4f%%", $1 + 1, $2 * 100, $3 * 100}'; 
	else
		echo -n $j ${arr[$j]} "${CYAN}" | awk '{printf "[%2d:%8.4f%%]  %s-------", $1 + 1, $2 * 100, $3}'; 
	fi
	echo -n ${RED}" >"
	[ $((arrcurday[$j])) != 0 ] && echo -n "${arrcurday[$j]}d."
	echo -n "${arrcurtime[$j]} "${YELLOW}
	[ $((arrestrmday[$j])) != 0 ] && echo -n "${arrestrmday[$j]}d."
	echo -n "${arrestrmtime[$j]}>"
	echo -n ${GREEN}" ${arrduedate[$j]}^"

	iii=$i
	ii=`echo $i | awk '{printf "%2d", $1}'`
	grep -q "NVIDIA" <<< $i && ii="G+"
	grep -q "AMD" <<< $iii && ii="g+"
	echo -n ${WHITE}" $ii (${arrproj[$j]})"${BLUE}; 
	if [ ${#arrname[$j]} -gt 80 ]; then echo " ${arrname[$j]:0:80}"; else echo " ${arrname[$j]}"; fi
	
	j=$((j+1)); 
done
echo -n ${CLEAR}
