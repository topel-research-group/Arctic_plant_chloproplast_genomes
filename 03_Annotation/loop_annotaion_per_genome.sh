for BLAST in `find ./P00* -maxdepth 0 -type d`; do
 cd $BLAST
 ./../annotate_by_genome_list.sh
 cd ..
done
