#! /bin/bash
## Replaces all entries "project.subproject" by "project" only.

worktime -w | sed 's/\(.*\)\..*/\1/'
