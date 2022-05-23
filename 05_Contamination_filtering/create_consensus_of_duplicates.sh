####################################################################################################

#This script loops over all gene folders. Then, for samples that contain multiple sequences per gene, it first removes short sequences (<60% of longest duplicate sequence).
#Then it creates a consensus sequence, which replaces the originals if less than 20 sites are ambiguous.
#then it creates an updated fasta file (${GENE}_post_contig_contamination_filer_v2.fasta) 
#Creates a file that logs duplicate sequencece id, number of ambiguous bases in consesus, number of duplicates remaining duplicates, gene name (${GENE}_duplicates_post_contig_contamination_filter_consensus_quality.txt)

for TAX in `find ./* -maxdepth 0 -type d`; do

perl -pe '$. > 1 and /^>/ ? print "\n" : chomp' < rbcL_post_contig_contamination_filer_alighned.fasta > placeholder.fasta
cat placeholder.fasta > rbcL_post_contig_contamination_filer_alighned.fasta
rm placeholder.fasta
rm rbcL_duplicates_post_contig_contamination_filter_consensus_quality.txt


cat rbcL_duplicates_post_contig_contamination_filter.txt | cut -d ' ' -f2 | sed -n '1,1p' | grep -A1 -f - rbcL_post_contig_contamination_filer_alighned.fasta | sed 's/-/./g' > duplicate.txt
#Create variable SETCASE to only show capital letters when all sequences are in agreement
#SETCASE="$(cat rbcL_duplicates_post_contig_contamination_filter.txt | cut -d ' ' -f7 | sed -n '1,1p' | awk '{print $1-1}')"
#echo $SETCASE
#cons test.txt -outseq test2.txt -setcase $SETCASE
NUMBER_OF_DUPLICATES="$(cat rbcL_duplicates_post_contig_contamination_filter.txt | cut -d ' ' -f7 | sed -n '1,1p')"
DUPLICATE_NAME="$(cat rbcL_duplicates_post_contig_contamination_filter.txt | cut -d ' ' -f8 | sed -n '1,1p' | sed 's/>//g')"
echo $DUPLICATE_NAME
GENE=$(pwd | cut -d '/' -f 7)

consambig duplicate.txt -outseq duplicate_consensus.txt -name ${DUPLICATE_NAME}_00000
perl -pe '$. > 1 and /^>/ ? print "\n" : chomp' < duplicate_consensus.txt | sed 's/n/-/g' | tr a-z A-Z > duplicate_consensus.fasta
AMBBASES="$(perl -pe '$. > 1 and /^>/ ? print "\n" : chomp' < duplicate_consensus.txt | sed 's/n/-/g' | tr a-z A-Z | sed -n '2,2p' | sed 's/[ATGC-]//g'| wc -m)"
echo $DUPLICATE_NAME $AMBBASES $NUMBER_OF_DUPLICATES $GENE >> rbcL_duplicates_post_contig_contamination_filter_consensus_quality.txt




for MARKER in `find ./* -maxdepth 0 -type d`; do
    cd $MARKER
    GENE=$(pwd | cut -d '/' -f 7)
    perl -pe '$. > 1 and /^>/ ? print "\n" : chomp' < ${GENE}_post_contig_contamination_filer_alighned.fasta > placeholder.fasta
    cat placeholder.fasta > ${GENE}_post_contig_contamination_filer_alighned.fasta
    rm placeholder.fasta
    rm -f ${GENE}_duplicates_post_contig_contamination_filter_consensus_quality.txt
    while read p; do
        echo "$p" | cut -d ' ' -f2 | sed -n '1,1p' | grep -A1 -f - ${GENE}_post_contig_contamination_filer_alighned.fasta > duplicate.txt
        NUMBER_OF_DUPLICATES="$(echo "$p"  | cut -d ' ' -f1)"
        DUPLICATE_NAME="$(echo "$p" | cut -d ' ' -f2 | sed 's/>//g')"
        #echo $DUPLICATE_NAME
        consambig duplicate.txt -outseq duplicate_consensus.txt -name ${DUPLICATE_NAME}_00000 -auto
        perl -pe '$. > 1 and /^>/ ? print "\n" : chomp' < duplicate_consensus.txt | sed 's/n/-/g' | tr a-z A-Z > duplicate_consensus.fasta
        AMBBASES="$(perl -pe '$. > 1 and /^>/ ? print "\n" : chomp' < duplicate_consensus.txt | sed 's/n/-/g' | tr a-z A-Z | sed -n '2,2p' | sed 's/[ATGC-]//g'| wc -m)"
        echo $DUPLICATE_NAME $AMBBASES $NUMBER_OF_DUPLICATES $GENE >> ${GENE}_duplicates_post_contig_contamination_filter_consensus_quality.txt
        #rm duplicate.txt
        rm duplicate_consensus.txt
        rm duplicate_consensus.fasta
      done < ${GENE}_duplicates_post_contig_contamination_filter.txt
    cd ..
done


for MARKER in `find ./* -maxdepth 0 -type d`; do
    cd $MARKER
    echo $MARKER
    GENE=$(pwd | cut -d '/' -f 7)
    rm -f ${GENE}_duplicates_post_contig_contamination_filter_consensus_quality.txt
    rm -f multi_sample_duplicate_consensus.fasta
    perl -pe '$. > 1 and /^>/ ? print "\n" : chomp' < ${GENE}_post_contig_contamination_filer_alighned.fasta > placeholder.fasta
    cat placeholder.fasta > ${GENE}_post_contig_contamination_filer_alighned.fasta
    rm placeholder.fasta
    rm -f multi_sample_duplicate_consensus.fasta
    rm -f ${GENE}_duplicates_post_contig_contamination_filter_consensus_quality.txt
    while read p; do
        #p="$(sed -n '7,7p' ${GENE}_duplicates_post_contig_contamination_filter.txt | cut -d' ' -f7,8)"
        #echo $p
        echo "$p" | cut -d ' ' -f2 | sed -n '1,1p' | grep -A1 -f - ${GENE}_post_contig_contamination_filer_alighned.fasta > duplicate.txt
        NUMBER_OF_DUPLICATES_OLD="$(echo "$p"  | cut -d ' ' -f1)"
        DUPLICATE_NAME="$(echo "$p" | cut -d ' ' -f2 | sed 's/>//g')"
        MAXLENGTH="$(sed 's/-//g' duplicate.txt | grep -v ">" | awk '{print length}'|sort -nr| sed -n '1,1p')"
        sed 's/-//g' duplicate.txt | grep -v ">" | awk '{print length}' > duplicate_lengths.txt
        sed 's/-//g' duplicate.txt | grep ">" | cut -d' ' -f1 > seqidentifier.txt
        rm -f duplicate_length_percentage.txt
        while read d; do
            #expr $d / $MAXLENGTH
            echo "scale=2;$d / $MAXLENGTH" | bc >> duplicate_length_percentage.txt
        done < duplicate_lengths.txt
        paste seqidentifier.txt duplicate_length_percentage.txt > seqidentifier_duplicate_length_percentage.txt
        rm seqidentifier.txt
        rm duplicate_length_percentage.txt
        grep -e "\s1" -e "\s.[7-9]" seqidentifier_duplicate_length_percentage.txt | cut -d$'\t' -f1 > seq_over_treshold.txt
        rm seqidentifier_duplicate_length_percentage.txt
        grep -A1 -f seq_over_treshold.txt ${GENE}_post_contig_contamination_filer_alighned.fasta > duplicate2.txt
        #sed -i -e '$a\' duplicate2.txt
        #consambig duplicate2.txt -outseq duplicate_consensus.txt -name ${DUPLICATE_NAME}_00000 -auto
        LINECHECK="$(grep ">" duplicate2.txt | wc -l)"
        if [ $LINECHECK = "1" ];then
            cat duplicate2.txt > duplicate_consensus.txt
        else
            consambig duplicate2.txt -outseq duplicate_consensus.txt -name ${DUPLICATE_NAME}_00000 -auto
        fi
        perl -pe '$. > 1 and /^>/ ? print "\n" : chomp' < duplicate_consensus.txt | sed 's/n/-/g' | tr a-z A-Z > duplicate_consensus.fasta #check
        AMBBASES="$(perl -pe '$. > 1 and /^>/ ? print "\n" : chomp' < duplicate_consensus.txt | sed 's/n/-/g' | tr a-z A-Z | sed -n '2,2p' | sed 's/[ATGC\-\.]//g'| sed 's/-//g' | wc -m)"
        if (( $AMBBASES > 20 ));then #fix if statement and check
            #echo $AMBBASES
            cat duplicate2.txt > duplicate_consensus.fasta
        fi
        NUMBER_OF_DUPLICATES_new="$(grep ">" duplicate_consensus.fasta | wc -l)"
        cat duplicate_consensus.fasta >> multi_sample_duplicate_consensus.fasta #create one of these at the start and remove at the end
        sed -i -e '$a\' multi_sample_duplicate_consensus.fasta
        echo $DUPLICATE_NAME $AMBBASES $NUMBER_OF_DUPLICATES_new $GENE >> ${GENE}_duplicates_post_contig_contamination_filter_consensus_quality.txt
        rm duplicate_consensus.fasta
        rm duplicate2.txt
        rm duplicate.txt
        rm seq_over_treshold.txt
        rm duplicate_lengths.txt
#now remove all duplicates from fasta and add all new consensus files
    done < ${GENE}_duplicates_post_contig_contamination_filter.txt
    #now remove all duplicates from fasta and add all new consensus files
    grep ">" ${GENE}_post_contig_contamination_filer_alighned.fasta | cut -d' ' -f1 > sequences_to_match_against.txt
    cat ${GENE}_duplicates_post_contig_contamination_filter.txt | cut -d' ' -f8 | grep -v -f - sequences_to_match_against.txt > sequences_to_keep.txt
    grep -A1 -f sequences_to_keep.txt ${GENE}_post_contig_contamination_filer_alighned.fasta | sed 's/-*//g' > ${GENE}_post_contig_contamination_filer_v2.fasta
    sed -i -e '$a\' ${GENE}_post_contig_contamination_filer_v2.fasta
    cat multi_sample_duplicate_consensus.fasta | sed 's/-*//g' >> ${GENE}_post_contig_contamination_filer_v2.fasta
    #rm remove_contaminated_contigs_grep.txt
    rm sequences_to_match_against.txt
    rm sequences_to_keep.txt
    rm multi_sample_duplicate_consensus.fasta
    cd ..
done
