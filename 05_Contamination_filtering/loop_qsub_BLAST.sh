#Submit blast run for all genes to the queing system
for BLAST in `find ./* -maxdepth 0 -type d`; do
    cd $BLAST
	qsub ../qsub_BLAST.sge
    cd ..
done
