#! /bin/bash
## Draws a histogram of all the subprojects of the given project.

tmp=$(mktemp) || exit 1
proj=$1

worktime -w | grep $proj'\.' | sed 's/;//' | worktime -r | worksort.sh > "$tmp"
works=$(cut -f1 -d' ' "$tmp" | sed "s/$proj\.//" )
perl -i -pe'/([0-9]+):([0-9]+):([0-9]+)/;$_=(($1*60*60+$2*60+$3)/3600)." ";' "$tmp"
sum=$(sed 's/ /+/g;s/+$/\n/' $tmp | bc -l)
perl -i -ane '$_ /= '$sum'/100 for @F; print join " ",@F' "$tmp"
percent=($(<"$tmp"))
{
    cat <<EOF
set term png size 1200,1024
set output '2.png'
set style data histogram
set style histogram rowstacked
set style fill solid border -1
set boxwidth 0.9
unset xtics
set yrange [0:100]
set key invert
EOF

color=(light-green red gray20 green blue gray75 cyan dark-yellow dark-magenta yellow brown pink white navy orange dark-cyan dark-green golden magenta beige purple salmon black)
colornum=${#color[@]}

for work in $works ; do
    if ((i)) ; then
        echo -n \\$'\n'" , ''"
    else
        echo -n plot '"'$tmp'"'
    fi
    echo -n ' 'using $((++i)) title '"'$work "$(printf '% 6.2f' ${percent[$i-1]})"'"' lc rgbcolor '"'${color[i%colornum]}'"'
done
} |gnuplot
rm "$tmp"
