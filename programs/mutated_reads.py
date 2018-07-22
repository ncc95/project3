"""
Imports two Python scripts to create 
mutated genome and make the fragments.
"""

import sys
import os
from heteroplasmy import create_mutated_genome
from fragmentiser import make_fragments

# get environment variables and arguments
# define what variant we are working with
position = sys.argv[1]
sub = sys.argv[2]
# and the reads we want to produce
read = os.environ.get('READ')  # single or paired
read_length = int(os.environ.get('LENGTH'))
distance = int(os.environ.get('DISTANCE'))

# Here we go
create_mutated_genome("../genomes/rCS_mtDNA.fasta","mtdna38_mut.fa", position, sub)
if read == 'SINGLE':
	make_fragments('mtdna38_mut.fa', 'lane1_read1.fastq', read_length)
elif read == 'PAIRED':
	make_fragments('mtdna38_mut.fa', 'lane1_read.fastq', read_length, True, distance)
