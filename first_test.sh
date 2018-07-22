#!/bin/sh

# --- Load modules
# --- Just check python module loads OK. Assume rest are OK

export READ=SINGLE  # SINGLE or PAIRED
export GENOME=hg38.xml  # hg38.fa or mtdna38.fa
export REFERENCE=chrM  # chrM for hg38 or NC_012920.1 for mtdna38

# --- Load modules
# --- Just check python module loads OK. Assume rest are OK

echo "Time of Run: Starting Script "`date`"  run_range"

module load python/3.6.3 > /dev/null 2>&1
if [ $? != 0 ]; then
	echo "Could not load python module for some reason"
	exit 1
	fi
module load samtools
module load qualimap
module load isaac4

# --- Environment variable MIRA should define top directory
# --- so we do not have to use relative paths
	
#if [ X$MIRA == X"" ]; then
#	echo "Environment variable MIRA not defined e.g."
#	echo "  export MIRA=/project/home/student4/Documents/python"
#	echo "Stopping"
#	exit 1
#	fi

# --- Here we go

cd /project/home17/ncc14/Documents/mito2/mutated_mitochondrial_genome
	
while read p; do
	echo $p
	#change into directory
	cd ${p}_SINGLE_150
	pwd
	rm -f  coverage.txt reads.fa
	# Create mutated reads
	python ../programs/mutated_reads.py $pos $sub
	#this will now just run fragmentiser and create mutated reads

	# Alignment starts here
	echo -e "Starting alignment . . ."
	if [ "$READ" = "SINGLE" ]
	then
		#start the alignment
		pwd
		isaac-align -r ../genomes/hg38.xml -b ../${p}_SINGLE_150 -m 90 -f fastq --lane-number-max 1 --single-library-samples 1 -o ./output-${p}_SINGLE_150
		cd output-${p}_SINGLE_150/Projects/default/default
		mv sorted.bam ../../../../
		cd ../../../../
		rm -r output-${p}_SINGLE_150
		samtools view -h -o aln.sam sorted.bam
		python ../programs/change_header.py

	elif [ "$READ" = "PAIRED" ]
	then
		
		isaac-align -r ../genomes/hg38.xml -b ../${p}_SINGLE_150 -m 90 -f fastq --lane-number-max 1 --single-library-samples 1 -o ./output-${p}_SINGLE_150
		cd output-${p}_SINGLE_150/Projects/default/default
		mv sorted.bam ../../../../
		cd ../../../../
		rm -r output-${p}_SINGLE_150
		samtools view -h -o aln.sam sorted.bam
		python ../programs/mispaired.py ${pos}
	fi
	samtools view -b aln.chrM.sam > aln.chrM.bam
	samtools sort aln.chrM.bam > aln.chrM.sorted.bam

	# Calculate coverage
	qualimap bamqc -bam aln.chrM.sorted.bam -oc coverage.txt
		
	# Delete non-relevant files to save space
	rm -f aln.chrM.bam aln.chrM.sam aln.chrM.sorted.bam aln.sam
	rm -f lane1_read1.fastq
	cd ..
done <one.csv

echo "time Finish script"`date`

