#this script loops over all folders (genes) and removes any sequences derived from contigs that were contaminated then loads the results into a new fasta file (${GENE}_post_contig_contamination_filer.fasta)
for TAX in `find ./* -maxdepth 0 -type d`; do
    cd $TAX
    #Create correct output file name
    GENE=$(pwd | cut -d '/' -f 7)
    echo $GENE
    cat ../contigs_to_remove.txt | sed "s/\t/.*/g" | sed "s/^/^/g" | sed "s/ //g" | sed 's/$/$/g' > remove_contaminated_contigs_grep.txt
    cat ${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family_contig_summary.txt | cut -d $'\t' -f1,11 > contigs_to_match.txt
    grep -v -f remove_contaminated_contigs_grep.txt contigs_to_match.txt | cut -d $'\t' -f1 > sequences_to_keep.txt
    grep -A1 -f sequences_to_keep.txt ${GENE}_all_seq.fa | sed 's/-*//g' > ${GENE}_post_contig_contamination_filer.fasta
    rm remove_contaminated_contigs_grep.txt
    rm contigs_to_match.txt
    rm sequences_to_keep.txt
    cd ..
done
