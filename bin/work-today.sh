#! /bin/bash

## Counts the work for today, or for any partial date given as
## parameter, i.e. 2013/05.

now=$(date +%Y/%m/%d)

if [[ $1 == -s || $2 == -s ]] ; then
    SIMPLE=1
    if [[ $1 == -s ]] ; then shift ; fi
fi

if [[ $1 ]] ; then date=$1 ; else date=$now ; fi

table=$(worktime -w | grep -v '^;' | grep $date)
if [[ $now == $date* ]] ; then
    endtime=$(date +%H:%M:%S)
    enddate=$now
else
    endtime=23:59:59
    enddate=$(tail -n1 <<< "$table" | cut -f2 -d' ')
fi

startdate=$(head -n1 <<< "$table" | cut -f2 -d' ')
projects=( $(cut -f4 -d' ' <<< "$table" | sort -u) )

for ((i=0;i<${#projects[@]};i++)); do
    if grep -m1 ${projects[i]}'\( \|$\)' <<< "$table" | grep -q ^o ; then
        table="i $startdate 00:00:00 ${projects[i]}"$'\n'"$table"
    fi

    if tac <<< "$table" | grep -m1 ${projects[i]}'\( \|$\)' | grep -q ^i ; then
        table="$table"$'\n'"o $enddate $endtime ${projects[i]}"
    fi

done
if [[ $table ]] ; then
    worktime -r <<< "$table"
    if [[ $SIMPLE ]] ; then
        echo '  'Simplified
        worktime -w <<< "$table" | work-simplify.pl | worktime -r
    fi

else
    echo No information for today found.
fi
