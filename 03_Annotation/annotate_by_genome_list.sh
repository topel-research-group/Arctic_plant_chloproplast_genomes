# Modules used
module load blast/v2.8.1

#Renew the output fasta file
FILESTEM=$(pwd |cut -d '/' -f 7|cut -d '.' -f 1)
>${FILESTEM}_named_CDS.fa
#loop everything over all genomes
for GENOME in `sort -n -r -k1,1 ../best_genome_count.txt | awk '{print $2}'`; do
GENOME_USED=$GENOME
mkdir -p $GENOME
SUBJECTSTEM=$( pwd |cut -d '/' -f 7)
FILESTEM=$(pwd |cut -d '/' -f 7|cut -d '.' -f 1)
echo $FILESTEM
echo $GENOME

blastn -db "../reference_genomes/${GENOME_USED}.fa" -query *[0-9].ffn -task dc-megablast -outfmt '6 qseqid sseqid slen pident length mismatch bitscore' -perc_identity 75 -qcov_hsp_perc 50 -num_threads 4 | sort -uk1,1 > ${GENOME_USED}/genome_blast.txt

#move to the right subfolder
cd $GENOME_USED

#get the blast query and subject names out of the results
cat genome_blast.txt | awk '{print $2}' > query_names_blast.txt
cat genome_blast.txt | awk '{print $1}' > subject_names_blast.txt
cat genome_blast.txt | awk '{print $4}' > percent_identity.txt

#get the blast query and subject names out of the results
rm -f query_names_matched.txt
while read -r line; do grep $line ../../reference_genomes/${GENOME_USED}.fa; done < "query_names_blast.txt" >> query_names_matched.txt #using while here to keep the original order

#Create the corect discriptors for fasta file, first cut of the locations of the genes on the original genome
GENOME_USED=$GENOME
sed -r 's/ \[location=.*[^]]\]//' query_names_matched.txt | cut -f 1 -d ' ' --complement | sed -r "s/^/\[query=${GENOME_USED}\] /"> gene_genbank_information.txt
#prepare seq identity to paste and infront of discriptor
sed -r 's/^/\[perc_ident=/' percent_identity.txt|sed -r "s/$/\]/" > percent_identity_prepared.txt
#prepare subject name to match the fasta format
sed -r 's/^/>/' subject_names_blast.txt > subject_names_blast_fasta_format.txt

#paste subject id in front of discriptor
paste -d' ' subject_names_blast_fasta_format.txt percent_identity_prepared.txt gene_genbank_information.txt > new_fasta_discriptors.txt

#linearize fasta file  and extract the matched sequences
cat ../*[0-9].ffn | awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}'| grep -w -A 1 -f subject_names_blast.txt | sed -r 's/-//' > subject_seqs.txt 
cat ../*[0-9].ffn | awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}'| grep -w -v -A 1 -f subject_names_blast.txt | sed -r 's/-//' > unmatched_subjects.fa

#get folder name for naming outputfile
FILESTEM=$(pwd |cut -d '/' -f 7|cut -d '.' -f 1)

#put in new headers every other line
cat subject_seqs.txt | awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' | awk 'NR%2==1' |awk '{if(NR>1)print}' > subject_seqs_no_names.txt
paste -d'\n' new_fasta_discriptors.txt subject_seqs_no_names.txt > ${FILESTEM}_${GENOME_USED}_named_CDS.fa
#paste all subject sequences not named prior by other genomes into the general fasta
grep '>' ../*_named_CDS.fa | awk '{print $1}' > prior_annotated_sequences.txt
grep -v -f prior_annotated_sequences.txt subject_names_blast_fasta_format.txt > sequence_names_to_add.txt
grep -A1 -f sequence_names_to_add.txt *_named_CDS.fa >> ../${FILESTEM}_named_CDS.fa


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
rm -f subject_names_blast_fasta_format.txt
rm -f sequences_to_add.txt
rm -f prior_annotated_sequences.txt
rm -f sequence_names_to_add.txt

cd ..
done

#grep '>*' P001_A01_named_CDS.fa |wc -l
