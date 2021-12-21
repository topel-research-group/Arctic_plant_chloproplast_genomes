for BLAST in `find ./P00* -maxdepth 0 -type d`; do
 cd $BLAST
 ./../annotate_by_genome_list.sh
 cd ..
done

grep ">" P*/*_named_CDS.fa |cut -f3 -d" " | sort | uniq -c |sort -nr > source_genome_count.txt
grep ">" P*/*_named_CDS.fa |cut -f4 -d" " | sort | uniq -c |sort -nr > gene_count.txt
grep ">" P*/*_named_CDS.fa |cut -f5 -d" " | sort | uniq -c |sort -nr > locus_tag_count.txt
