def create_mutated_genome(wt_genome, mut_genome, position, snp):
	with open(wt_genome) as f, open(mut_genome, 'w') as g:
		# write FASTA header and skip
		g.write(f.readline())
		# prepare data
		content = f.read()
		content = content.replace("\n", "")  # remove newlines
		if content[int(position)-1] == snp:
			raise TypeError("Not a mutation.")
		for i, char in enumerate(content,1):
			if i == int(position):
				g.write(snp)
			else:
				g.write(char)

