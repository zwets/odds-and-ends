#!/bin/sh
#
#  assembly-coverage - quickly compute coverage from contig headers
#  Copyright (C) 2017  Marco van Zwetselaar <io@zwets.it>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Function to exit this script with an error message on stderr
err_exit() {
    echo "$(basename "$0"): $*" >&2
    exit 1
}

# Function to show usage information and exit
usage_exit() {
    echo "
Usage: $(basename $0) [FILE ...]

  For each FILE compute the weighted average coverage from the length
  and coverage fields in the contig headers produced by SPAdes.  If no
  FILE, or FILE is '-', read from standard input.
" >&2
    exit ${1:-1}
}

# Do the work

printf "Sample\tBases\tLength\tCoverage\n"

if [ $# -eq 0 -o "$1" = "-" ]; then
    awk -b -O -v OFS='\t' -v S="-" -F'_' '
        /^>/ { L=$4; C=$6; B=L*C; TB=TB+B; TL=TL+L }
        END  { if (TB<1E7||TL<1E6) TC="***"; else TC=TB/TL; 
	       print S, TB, TL, TC 
             }'
else
    for f in "$@"; do
        S="$(basename "$f")"
        S="${f%.*}"
        awk -b -O -v OFS='\t' -v S="$S" -F'_' '
            /^>/ { L=$4; C=$6; B=L*C; TB=TB+B; TL=TL+L }
            END  { if (TB<1E7||TL<1E6) TC="***"; else TC=TB/TL; 
                   print S, TB, TL, TC 
             }
        ' "$f" 
    done
fi

# vim: sts=4:sw=4:et:si:ai
