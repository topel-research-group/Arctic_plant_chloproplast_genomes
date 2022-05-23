#This script extracts most common family blast hits per contig (helps with taxonomic grouping of lesser sequenced genes genes)
#first loop extracts the contig ref for each gene model from the prokka .tbl file
for TAX in `find ./* -maxdepth 0 -type d`; do
    cd $TAX
    #Create correct output file name
    GENE=$(pwd | cut -d '/' -f 7)
    echo $GENE
    #reset contig_hits.txt, since we will be appending to it later
    rm contig_hits.txt 2> /dev/null || true
    #extract CDS ref codes to grep against contigs
    sed -i '/^[[:space:]]*$/d' ${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family.txt
    cut -d ' ' -f1 "${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family.txt" | perl -pe 's/^/\t/g' > grep_for_contig_prep.txt
    #loop over all ref codes and extract contig name
    cat  grep_for_contig_prep.txt | while read l; do
        SAMPLE=$(echo "${l::-6}"| cut -d $'\t' -f2 | cut -d $'\t' -f2)
        CDS_ref="${l}"
        awk '
        /Feature/{c=0}
        {a[++c]=$0}
        /'$CDS_ref'/{for(i=1;i<=c;i++){print a[i]}exit}
        ' ../../03_Annotation/${SAMPLE}/${SAMPLE}.tbl | head -1 | cut -d ' ' -f2 >> contig_hits.txt
    done < grep_for_contig_prep.txt
    cat grep_for_contig_prep.txt | sed 's/......$//g' | sed 's/^.//g' | paste - contig_hits.txt <(cut -d $'\t' -f3 "${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family.txt") > "${GENE}_contig_hits.txt"
    rm contig_hits.txt 2> /dev/null || true
    cd ..
done

#second loop extracts dominant family per contig, number of hits and % of total and attaches it to "${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family.txt"
for TAX in `find ./* -maxdepth 0 -type d`; do
    cd $TAX
    #Create correct output file name
    GENE=$(pwd | cut -d '/' -f 7)
    echo $GENE
    rm contig_dominant_family.txt 2> /dev/null || true
    cat  ${GENE}_contig_hits.txt | while read c; do
    echo $c
    CONTIG=$(echo $c | cut -d ' ' -f1,2 | sed 's/\s/./g')
    grep -hs $CONTIG ../*/*_contig_hits.txt | sort -rn | uniq -c | sort -rn | awk '{print $1,$4,$2,$3}' | awk '{ a[++n,1] = $2; a[n,2] = $1; t += $1 }
         END {
             for (i = 1; i <= n; i++)
                 printf "%-20s %-15d%d%%\n", a[i,1], a[i,2], 100 * a[i,2] / t
         }' | awk '{print $1,$3,$2}'| sed -e 's/ /\t/g' | head -1 >> contig_dominant_family.txt
    done
    cut -d $'\t' -f2 cut ${GENE}_contig_hits.txt | paste ${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family.txt contig_dominant_family.txt - > ${GENE}_BLAST_top_ncbi_hit_and_self_top_4_out_family_contig_summary.txt
    rm contig_dominant_family.txt 2> /dev/null || true
    cd ..
done
