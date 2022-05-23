#This script translates "GENE"_BLAST_to_self_top_4_out.txt to there taxon name (rather than sample number) and adds the column containing closest ncbi nt db best bitscore hits per sample
#It also generates copies of the same files, only showing family+genus names rather than the full taxonomy per sample
#and a copy with only family names per sample
for TAX in `find ./* -maxdepth 0 -type d`; do
    cd $TAX
    
    #Create correct output file name
    GENE=$(pwd | cut -d '/' -f 7)
    echo $GENE
    FILEIN="${GENE}_BLAST_to_self_top_4_out.txt"
    FILEIN2="${GENE}_BLAST_out_with_taxonomy.txt"
    FILEOUT="${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_taxon_names.txt"
    FILEOUT2="${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_taxon_names_duplicates_only.txt"
    #translate sample id's into taxonomy
    for i in {1..5}; do
        sort ${FILEIN} |sed 's/_..... / /g' |  sed 's/_.....$//g' | sed 's/  / /g' | cut -d' ' -f$i | sed 's/^/^/g' > column_untranslated.txt
        (while read ptn; do grep $ptn ../Latnja_chloroplast_sample_full_taxonomy.tsv; done < column_untranslated.txt) | cut -d$'\t' -f2 > "column_${i}.txt"
    done
    paste ${FILEIN2} column_[1-5].txt | awk -F'\t' '{ print $1,FS,$11,FS,$10,FS,$12,FS,$13,FS,$14,FS,$15}' > ${FILEOUT}
    
    #extract just sequences with duplicates
    grep -v $'[[:blank:]]1 ' ${GENE}_dubplicate_counts.txt | cut -d' ' -f8 | sed 's/^/^/g' > "duplicate_sample_names_for_grep.txt"
    grep -f duplicate_sample_names_for_grep.txt $FILEOUT > ${FILEOUT2}
    
    #Exract Family + genus for both full and duplicate only datasets
    perl -pe  's/\s\w+;\w+;\w+;\w+;//g' < $FILEOUT | perl -pe  's/;[\w-\.?]+[ \t]//g' |  perl -pe  's/;[\w-\.?]+$//g' > "${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family_genus.txt"
    perl -pe  's/\s\w+;\w+;\w+;\w+;//g' < $FILEOUT2 | perl -pe  's/;[\w-\.?]+[ \t]//g' |  perl -pe  's/;[\w-\.?]+$//g' > "${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family_genus_duplicates_only.txt"
    #Exract Family + genus for both full and duplicate only datasets
    perl -pe  's/\s\w+;\w+;\w+;\w+;//g' < $FILEOUT | perl -pe  's/;[\w-\.?]+;[\w-\.?]+[ \t]//g' |  perl -pe  's/;[\w-\.;?]+$//g' > "${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family.txt"
    perl -pe  's/\s\w+;\w+;\w+;\w+;//g' < $FILEOUT2 | perl -pe  's/;[\w-\.?]+;[\w-\.?]+[ \t]//g' |  perl -pe  's/;[\w-\.;?]+$//g' > "${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family_duplicates_only.txt"
    
    
    #remove intermediate files
    rm column_[1-5].txt
    rm column_untranslated.txt
    rm duplicate_sample_names_for_grep.txt
    cd ..
done
