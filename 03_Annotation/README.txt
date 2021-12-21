#Annotated genomes using prokka to get predictive transcipts and blast to chloroplast genomes to get gene/protein/product names using chloroplast nomenclature

#shell scripts in order of usages
loop_prokka_rapid_genomics_run2.sge #loop prokka over all samples, generates predictie transcipt output (*.ffn)
for_each_dir_do.sh #does a given action for each subdirectory
blast_to_genome.sh #loops over all available reference genomes and counts blast results for each prokka .ffn (prediction transcript output) and generates a file (within known_genome_match folder for each sample (e.g. P001_WA01)) containing number of hite per reference genome
annotate_by_genome_list.sh #for a sample (e.g. P001_WA01) blasts all reference genomes in order (starting with highest hits in dataset) generating an annotated version of the prokka's .fnn priotoritizing the gene names found in the "highest hit" reference genome
loop_annotaion_per_genome.sh #loops annotate_by_genome_list.sh over all samples and generate summary statistics (gene_count/locus_tag_count/source_genome_count .txt) wich provide total counts for each unqie hit within their respective catagory

