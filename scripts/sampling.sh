#!/usr/bin/sh

# This script samples <number of bases> from a given FASTQ file.
# Requirements: seqkit (https://github.com/shenwei356/seqkit)

if [ $# -ne 3 ]; then
    echo "Usage: $0 <fastq file> <number of bases> <outfile suffix>"
    exit 1
fi

INFILE=$1
BASES=$2
SUFFIX=$3
OUTFILE=${INFILE%.*}_${SUFFIX}.${INFILE##*.}

echo "Sampling $BASES bases from $INFILE"

seqkit stats $INFILE | awk -v b="$BASES" 'FNR == 2 {gsub(/,/, "", $7); print int(b/$7 * 1.25) }' | xargs -I{}  seqkit sample -n {}  $INFILE -o $INFILE.sample

seqkit seq -n $INFILE.sample | awk -v b="$BASES" 'BEGIN { FS = "/"; sum = 0} {split($3, a, "_"); sum+=a[2]-a[1]; if (sum < b + 100000) { print $0 }  }' | seqkit grep  $INFILE.sample -o $OUTFILE -f -

rm -f $INFILE.sample

echo "Output written to $OUTFILE"
