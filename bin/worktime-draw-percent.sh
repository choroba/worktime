#! /bin/bash

## Draws a graph for the given project, for each month showing the
## time per subproject. Specify -p as the second parameter to get the
## percentage rather than time.

tmp=$(mktemp) || exit 1
proj=$1
shift

table=$(worktime -w | grep "$proj\." | sed "s/^;//;s/$proj\.//")
dates=$(cut -d' ' -f2 <<< "$table" | cut -f1,2 -d/ | sort -u)
works=$(cut -d' ' -f4 <<< "$table" | sort -u)
datenames=$(for date in $dates ; do echo -n ' "'$date'"' $((++i)), ; done)
out=1.png

echo $works > "$tmp"

for date in $dates ; do
    tab=$(echo "$table" | work-today.sh "$date" | worksort.sh | sed 's%^%'"$date %;s/ \+/ /g" )
    for work in $works ; do
        value=$(grep "$work" <<< "$tab" | cut -f3 -d' ')
        [[ $value ]] || value=0:0:0
        echo -n $value' ' >> "$tmp"
    done
    echo >> "$tmp"
done

if [[ $1 == '-p' ]] ; then
    out=3.png
    perl -i -ane '
print, next if $. == 1;
my $sum;
for my $time (@F) {
    my ($hour, $min, $sec) = split /:/, $time;
    $time = $sec + $min * 60 + $hour * 60 * 60;
    $sum += $time;
}
$_ = 100 * $_ / $sum for @F;
print join " ", @F;
print "\n";
' "$tmp"
fi

{
    cat <<EOF 
set term png size 1200,1024
set output '$out'
set style data histogram
set style histogram rowstacked
set style fill solid border -1
set boxwidth 0.9
set key outside invert
set xrange [0.5:14.5]
EOF
    if [[ $1 != '-p' ]] ; then
        cat <<EOF
set ydata time
set timefmt '%H:%M:%S'
set format y'%j %H:%M'
EOF
else
        cat <<EOF
set yrange [0:100]
EOF
fi

color=(light-green red gray20 green blue gray75 cyan dark-yellow dark-magenta yellow brown pink white navy orange dark-cyan dark-green golden magenta beige purple salmon black)
colornum=${#color[@]}

i=0
for work in $works ; do
    if ((i)) ; then
        echo -n \\$'\n'" , ''"
    else
        echo -n plot '"'$tmp'"'
    fi
    echo -n ' 'using $((++i)) title '"'$work'"' lc rgbcolor '"'${color[i%colornum]}'"'
done
} | gnuplot
rm "$tmp"
