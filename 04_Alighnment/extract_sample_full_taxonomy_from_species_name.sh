#This script extracts the higher level taxonomy for each sample, based on a species name per smaple tsv
module load Anaconda3/v2018.12
OLDIFS=$IFS
IFS=$'\n'       # make newlines the only separator
for ID_SAMPLE in $(cut -d$'\t' -f2 Latnja_chloroplast_sample_names_species_nr.tsv | cut -d$' ' -f1)
do
 #echo $ID_SAMPLE
 echo $ID_SAMPLE | ./full_taxonomy.py --header species - >> Latnja_chloroplast_sample_partial_taxonomy.tsv
done
IFS=$OLDIFS
cut -d$'\t' -f2 Latnja_chloroplast_sample_names_species_nr.tsv | paste -d";" Latnja_chloroplast_sample_partial_taxonomy.tsv - | sed 's/ /_/g' | paste Latnja_chloroplast_sample_names_species_nr.tsv - | cut --complement -f2 > Latnja_chloroplast_sample_full_taxonomy.tsv
rm Latnja_chloroplast_sample_partial_taxonomy.tsv
