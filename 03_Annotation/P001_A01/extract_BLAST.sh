GENOME_USED=$(tail -1  ../genometouse.txt)
mkdir -p $GENOME_USED
SUBJECTSTEM=$( pwd |cut -d '/' -f 7)
FILESTEM=$(pwd |cut -d '/' -f 8|cut -d '.' -f 1)
echo $FILESTEM
echo $GENOME_USED

blastn -db "../reference_genomes/${GENOME_USED}.fa" -query *[0-9].ffn -task dc-megablast -outfmt '6 qseqid sseqid slen pident length mismatch bitscore' -perc_identity 75 -qcov_hsp_perc 50 -num_threads 4 | sort -uk1,1 > ${GENOME_USED}/genome_blast.txt

#move to the right subfolder
cd $GENOME_USED

#get the blast query and subject names out of the results
cat genome_blast.txt | awk '{print $2}' > query_names_blast.txt
cat genome_blast.txt | awk '{print $1}' > subject_names_blast.txt
cat genome_blast.txt | awk '{print $4}' > percent_identity.txt

#get the blast query and subject names out of the results
rm -f query_names_matched.txt
while read -r line; do grep $line ../../reference_genomes/Betula_nana_coding_sequence.fa; done < "query_names_blast.txt" >> query_names_matched.txt #using while here to keep the original order

#Create the corect discriptors for fasta file, first cut of the locations of the genes on the original genome
GENOME_USED=$(tail -1 ../../genometouse.txt)
sed -r 's/ \[location=.*[^]]\]//' query_names_matched.txt | cut -f 1 -d ' ' --complement | sed -r "s/^/\[query=${GENOME_USED}\] /"> gene_genbank_information.txt
#prepare seq identity to paste and infront of discriptor
sed -r 's/^/\[perc_ident=/' percent_identity.txt|sed -r "s/$/\]/" > percent_identity_prepared.txt
#paste subject id in front of discriptor
paste -d' ' subject_names_blast.txt percent_identity_prepared.txt gene_genbank_information.txt > new_fasta_discriptors.txt

#linearize fasta file  and extract the matched sequences
cat ../*[0-9].ffn | awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}'| grep -w -A 1 -f subject_names_blast.txt | sed -r 's/--//' > subject_seqs.txt 
cat ../*[0-9].ffn | awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}'| grep -w -v -A 1 -f subject_names_blast.txt | sed -r 's/--//' > unmatched_subjects.fa

#get folder name for naming outputfile
FILESTEM=$(pwd |cut -d '/' -f 7|cut -d '.' -f 1)

#put in new headers every other line
cat subject_seqs.txt | awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' | awk 'NR%2==1' |awk '{if(NR>1)print}' > subject_seqs_no_names.txt
paste -d'\n' new_fasta_discriptors.txt subject_seqs_no_names.txt >> ../${FILESTEM}_named_CDS.fa

#remove intermittend files
rm -f query_names_blast.txt
rm -f query_names_matched.txt
rm -f gene_genbank_information.txt
rm -f percent_identity.txt
rm -f percent_identity_prepared.txt
rm -f new_fasta_discriptors.txt
rm -f subject_seqs.txt
rm -f subject_names_blast.txt
rm -f subject_seqs.txt
rm -f subject_seqs_no_names.txt
rm -f genome_blast.txt

cd ..
