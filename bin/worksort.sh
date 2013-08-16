#! /bin/bash
## Sorts the output from worktime -r by time.
sed -r 's/:([0-9]{2}):([0-9]{2})$/\1\2/' | sort -nk2 | sed -r 's/([0-9]{2})([0-9]{2})$/:\1:\2/'
