##############################################################################################################################################
#In this directory we further explore and try to deal with the contamination found in 04_Alighnment
#The starting point is the removal of samples that did not contain any sequences belonging to the intendet organism (samples_to_remove.txt: Identefied in 04_Alighnment)
#We start by identifieing the contigs contigs and identify sequences on the basis of the (family level) identity of the whole contig rather than a single BLAST hit (to account for uncertain BLAST results as well as genes that are less represented within the NCBI database) 
#Then we removed sequences from contigs with hybrid identity as well ass complete mismatches.
#consensus sequences were generated for samples with multiple sequences. The consensus was then retained if it contained less then 20 ambiguous sites.
#Remaining duplicates were assesed by hand (and transferd to 06_Concatenation)

For each gene (folder) the following end products were generated: 
The products described in the readme of 04_Alighnment are also present here
${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family_contig_summary.txt
${GENE}_post_contig_contamination_filer_alighned.fasta #gene alighnment prior to contig filter
${GENE}_post_contig_contamination_filer_alighned_v2.fasta #gene alighnment post contig filter and duplicate correction from script

#scripts
remove_unresolvable_comtaminated_samples.sh #removes comtaminated samples which did not contain any material from the target species from the analysis
check_gene_model_with_contig_taxonomy.sh #This script extracts most common family blast hits per contig (helps with taxonomic grouping of lesser sequenced genes genes)
remove_seq_based_on_contaminated_contigs.sh #loops over all folders (genes) and removes any sequences derived from contigs that were contaminated then loads the results into a new fasta file (${GENE}_post_contig_contamination_filer.fasta)
alighn_all_genes.sge #Alighn all genes (Prior to removal of sequences based on the contig filter)
alighn_all_genesv2.sge #(Post removal of sequences based on the contig filter)
create_consensus_of_duplicates.sh #This script loops over all gene folders. Then, for samples that contain multiple sequences per gene, it first removes short sequences (<60% of longest duplicate sequence).
								  #Then it creates a consensus sequence, which replaces the originals if less than 20 sites are ambiguous.
								  #then it creates an updated fasta file (${GENE}_post_contig_contamination_filer_v2.fasta)
								  #Creates a file that logs duplicate sequencece id, number of ambiguous bases in consesus, number of duplicates remaining duplicates, gene name (${GENE}_duplicates_post_contig_contamination_filter_consensus_quality.txt)

#files
samples_to_remove.txt #List of sample names that were removed based on 04_Alighnment
contigs_to_remove.txt #List of hybrid and mismatched contigs that were removed
potential_hybrid_contigs.txt # List of hybrid (70% > family level mismatch) contigs
mismatched_contigs.txt # List of mismatched (70 %< family level mismatch) contigs
