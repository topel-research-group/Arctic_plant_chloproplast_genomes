#This script, removes comtaminated samples which did not contain any material from the target species from the analysis
for TAX in `find ./* -maxdepth 0 -type d`; do
    cd $TAX
    #extraxt GENE name for file naming
    GENE=$(pwd | cut -d '/' -f 7)

    #Prepare samples for grep searches of sample names for each of the files
    perl -pe  's/\^/^>/g' < ../samples_to_remove.txt > samples_to_remove_temp1.txt
    perl -pe  's/\^//g' < ../samples_to_remove.txt | perl -pe  's/\n/\$\n/g' > samples_to_remove_temp2.txt

    #prepare filtered files
    grep -v -f ../samples_to_remove.txt ${GENE}_BLAST_out.txt > temp_BLAST_out.txt
    grep -v -f ../samples_to_remove.txt ${GENE}_BLAST_out_with_taxonomy.txt > temp_BLAST_out_with_taxonomy.txt
    grep ">" ${GENE}_all_seq.fa | grep -v -f samples_to_remove_temp1.txt | cut -f1 -d' ' > samples_to_remove_temp3.txt
    grep -A 1 -f samples_to_remove_temp3.txt ${GENE}_all_seq.fa > temp_all_seq.fa
    grep -v -f ../samples_to_remove_temp2.txt ${GENE}_dubplicate_counts.txt > temp_dubplicate_counts.txt
    grep -v -f ../samples_to_remove.txt ${GENE}_missing_samples.txt > temp_missing_samples.txt

    #overwrite original files
    cat temp_BLAST_out.txt > ${GENE}_BLAST_out.txt
    cat	temp_BLAST_out_with_taxonomy.txt > ${GENE}_BLAST_out_with_taxonomy.txt
    cat temp_all_seq.fa > ${GENE}_all_seq.fa
    cat temp_dubplicate_counts.txt > ${GENE}_dubplicate_counts.txt
    cat temp_missing_samples.txt > ${GENE}_missing_samples.txt

    #remove all temporary files
    rm samples_to_remove_temp1.txt
    rm samples_to_remove_temp2.txt
    rm samples_to_remove_temp3.txt
    rm temp_BLAST_out.txt
    rm temp_BLAST_out_with_taxonomy.txt
    rm temp_all_seq.fa
    rm temp_dubplicate_counts.txt
    rm temp_missing_samples.txt
    cd ..
done
