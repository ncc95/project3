from Bio.Seq import Seq

#this should allow me to test this script however i please and do whatever i want

def make_fragments(input, output, size, paired_end=False, distance=None):
	"""
	Divides the genome into fragments
	"""

	# append each read to list
	with open(input) as f:
		next(f)  # skip FASTA header
		content = f.read()
		content = content.replace("\n", "")  # remove newlines

	# single end reads
	if not paired_end:
		reads = []
		
		for i in range(len(content)-size+1):
			reads.append(content[i:size+i])

		# store in FASTA format
		with open(output, 'w') as f:
			for c, read in enumerate(reads, 1):
				f.write('@read%s\n'%c)
				f.write(read)
				f.write('\n' + '+' +'\n')
				qual = 'I' *len(read)
				f.write(qual + '\n')
	
	# paired end reads
	else:
		if distance:
			forward_reads = []
			reverse_reads = []
			
			for i in range(len(content)-size-distance+1):
				
				# define boundaries
				forward = content[i:size+i]
				reverse = content[i+distance:size+i+distance]
				
				# translate to reverse complement
				reverse = Seq(reverse)
				reverse = reverse.reverse_complement()
				reverse = str(reverse)

				forward_reads.append(forward)
				reverse_reads.append(reverse)

			# store in FASTA format
			name = output.split(".fastq")[0]
			with open(name + "1.fastq", 'w') as f:
				with open(name + "2.fastq", 'w') as g:
					for c, read in enumerate(forward_reads, 1):
						# forward read
						f.write('@read%s/1\n'%c)
						f.write(read)
						f.write('\n' + '+' +'\n')
						qual = 'I' *len(read)
						f.write(qual + '\n')
						# reverse read
						g.write('@read%s/2\n'%c)
						g.write(reverse_reads[c-1])
						g.write('\n' + '+' +'\n')
						g.write(qual + '\n')
		else:
			raise TypeError("'distance' not specified for paired end reads")


