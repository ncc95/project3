#!/bin/sh
# Workflow for sequence alignment and quality control
# And useful commands

# load necessary modules
module load bwa
module load samtools
module load picard
module load qualimap

# WARNING: do not run this if genome is already indexed

# generate bwa index
bwa index -a bwtsw $REFERENCE
# generate fasta file index
samtools faidx $REFERENCE
# generate sequence dictionary
# export PICARD=/project/soft/linux64/src/hannah/picard/2.10.2/picard.jar
java -jar $PICARD CreateSequenceDictionary \ REFERENCE=$REFERENCE \ OUTPUT=reference.dict

# alignment
bwa mem $REFERENCE $READS > aln.sam

# convert to BAM
samtools view -b aln.sam > aln.bam
samtools sort aln.bam > aln_sorted.bam
samtools index aln_sorted.bam

# extract mapped to mtDNA
samtools view -bh pe_aln_sorted.bam chrM > aln.chrM.bam

# generate coverage data
qualimap bamqc -bam aln_sorted.bam -c

# convert back to fastq
samtools bam2fq aln.chrM.bam > aln.chrM.fq  

# wgsim simulation
# download from github and move into directory
gcc -g -O2 -Wall -o wgsim wgsim.c -lz -lm  # compile
wgsim -Nxxx -1yyy -d0 -S11 -e0 -rzzz hs37m.fa yyy-zzz.fq /dev/null  # change /dev/null to paired-end file
# N = number of reads
# l = length of reads
# r = error rate
# d = distance
# R, X = indels
# e = base quality scaled