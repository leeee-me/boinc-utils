#!/bin/bash

function asn {
        whois -h whois.cymru.com "-v $1" | grep -v ^Warn
}

function bulkasn {
        netcat whois.cymru.com 43 | grep -v ^Bulk
}

echo

# == external IP address ==
C=`curl -s4 http://ifconfig.co/`

# == established cvmfs2 connections ==
A=`netstat -aunt4 | grep -e ":8000 " -e ":80 " | grep ESTAB | cut -c45- | cut -d':' -f1 | sort -n | uniq | tee /tmp/cvmfs.$$`
X=`cat /tmp/cvmfs.$$ | wc -l`
rm /tmp/cvmfs.$$
[ "$X" != "0" ] && (IFS=$'\n'; for i in `asn $C`; do [ "${i:0:2}" == "AS" ] && echo ". "$i && continue; echo "^ "$i; done | head -n 1) 
B=`IFS=$'\n'; (echo "begin"; echo "verbose"; for i in $A; do echo $i; done; echo "end") | bulkasn`
IFS=$'\n'; for i in $B; do echo "~ "$i; done

[ "$X" != "0" ] && echo

# == external IPv6 address ==
C=`curl -s6 http://ifconfig.co/`
[ -z "$C" ] && D="::1" && D=`asn $D | head -n 1`
[ ! -z "$C" ] && D=`echo $C` && D=`asn $B`

# == established cvmfs2 connections ==
A=`netstat -aunWt6  | grep -e ":8000 " -e ":80 " | grep ESTAB | sed -e 's/^[^ ]\+[ ]\+[^ ]\+[ ]\+[^ ]\+[ ]\+[^ ]\+[ ]\+//g' | cut -d' ' -f1 | sed -e 's/:[0-9]\+$//g' | sort -n | uniq | tee /tmp/cvmfs.$$`
X=`cat /tmp/cvmfs.$$ | wc -l`
rm /tmp/cvmfs.$$
[ "$X" != "0" ] && (IFS=$'\n'; for i in `asn $C`; do [ "${i:0:2}" == "AS" ] && echo ". "$i && continue; echo "^ "$i; done | head -n 1)
B=`IFS=$'\n'; (echo "begin"; echo "verbose"; for i in $A; do echo $i; done; echo "end") | bulkasn`
IFS=$'\n'; for i in $B; do echo "~ "$i; done

