#contains directories with the forward and reverse data for each well in the second rapid genomics sequencing run
create_dirs.sh #creates a directory for the forward and reverse of each well of the 2nd rapid genomix run sequence data
dirs.txt #a list containing all directories, needed to copy the same directory structure into the trimmed/rapid_genomicsv2 folder 
for_each_dir_do_unzip.sh # unzips all files genrated from the fastQC in all subfolders (in order to extract the adapter sequences later)
for_each_dir_do_extract_adapters.sh # extract all unique adapter sequences found by FastQC within all subfolders and prints them sorted into adapters.txt
