#!/bin/sh

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

#!/bin/sh
for sub in A C G T
do
	for pos in `seq 1`
	do
		echo "Running: ${pos}${sub}"
		# Create directory where results will be stored
		mkdir ${pos}${sub}_${READ}
		cd ${pos}${sub}_${READ}

		# Create mutated reads
		python ../programs/mutated_reads.py $pos $sub
		# check if python code above returned an exit code
		# it will do this if the directory is redundant
		# because it is not a mutation
		if [ $? != 0 ]
		then
			cd ..
			rm -rf ${pos}${sub}_${READ}
			continue
		fi

		# Alignment starts here
		echo -e "Starting alignment . . ."
		if [ "$READ" = "SINGLE" ]
		then
			#remove the mutated genome so as to not confuse isaac4
			rm rCS_mtDNA_mut.fa
			isaac-align -r ../genomes/hg38.xml -b ../${pos}${sub}_${READ} -m 90 -f fastq --lane-number-max 1 --single-library-samples 1 -o ./output-${pos}${sub}_${READ}
			cd output-${pos}${sub}_${READ}/Projects/default/default
			mv sorted.bam ../../../../
			cd ../../../../
			samtools view -h -o aln.sam sorted.bam
			python ../programs/change_header.py

		elif [ "$READ" = "PAIRED" ]
		then
			#remove the mutated genome so as to not confuse isaac4
			rm rCS_mtDNA_mut.fa
			isaac-align -r ../genomes/hg38.xml -b ../${pos}${sub}_${READ} -m 90 -f fastq --lane-number-max 1 --single-library-samples 1 -o ./output-${pos}${sub}_${READ}
			cd output-${pos}${sub}_${READ}/Projects/default/default
			mv sorted.bam ../../../../
			cd ../../../../
			samtools view -h -o aln.sam sorted.bam
			python ../programs/mispaired.py ${pos}
		fi
		samtools view -b aln.chrM.sam > aln.chrM.bam
		samtools sort aln.chrM.bam > aln.chrM.sorted.bam

		# Calculate coverage
		qualimap bamqc -bam aln.chrM.sorted.bam -oc coverage.txt
		
		# Delete non-relevant files to save space
		rm -f aln.chrM.bam aln.chrM.sam aln.chrM.sorted.bam aln.sam
		#rm -f reads1.fa reads2.fa
		
		# Back to python dir
		cd ..
	done
done

echo "Time of Run: Finish script   "`date`"  run_range"

