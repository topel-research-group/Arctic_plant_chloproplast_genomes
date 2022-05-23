#The initial goal of this folder was to check for contamination (sequences belonging to the correct gene but the the wrong species)
#Checks were best blast hit and internal BLAST similarity to sequences with the same gene
#Samples were removed if neither nucleotide blast hit nor internal blast hits matched the expected genus for the sample
For each gene (folder) the following end products were generated:
${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family_genus.txt #table containg columns (seq id, expected genus, best blast result genus, genera of top 4 internal blast hits ) for each sequence
${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family.txt #table containg columns (seq id, expected genus, best blast result genus, genera of top 4 internal blast hits ) for each sequence
${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family_genus_duplicates_only.txt #same as above, though only containing sequences for samples that occur multiple time for a given gene
${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family_duplicates_only.txt #same as above, though only containing sequences for samples that occur multiple time for a given gene
${GENE}_dubplicate_counts.txt # duplicate counts for each sample
${GENE}_missing_samples.txt # missing samples for gene


#shell scripts in order of usages
BLAST_to_self_all_genes.sge #runs Blast within for each gene against itself and save the top 3 non duplicate hits. This find out wether samples with multiple gene models are contaminated (e.g. if they group within the expected order/family)
extract_sample_full_taxonomy_from_BLASTID.sge #extracts the full taxonomy of BLAST hits based on taxonid and affixes it to the end of the blast results
qsub_BLAST.sge #run blast vs NCBI nucleotide db
loop_qsub_BLAST.sh #run blast vs NCBI nucleotide db #loop qsub_blast over all sequences for each gene, and retrieve the top blast hit
extract_sample_full_taxonomy_from_species_name.sh #extracts the higher level taxonomy for each sample, based on a species name per smaple tsv
generate_taxonomy_comparisons.sh # translates "GENE"_BLAST_to_self_top_4_out.txt to there taxon name (rather than sample number) and adds the column containing closest ncbi nt db best bitscore hits per sample
								 #It also generates copies of the same files, only showing family+genus names rather than the full taxonomy per sample
								 #and a copy with only family names per sample



#Files
duplicates_per_sample.txt #sum of all duplicates found over all genes per sample 
Latnja_chloroplast_sample_names_species_nr.tsv #List containing species name belonging two each sample id (two columns 1: sample id 2: species name)
