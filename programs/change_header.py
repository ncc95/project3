def change_header(file, new_file, chromosome):
	with open(file) as f, open(new_file, 'w') as g:
		for line in f:
			if line[0] == "@":
				if chromosome in line or "PG" in line:
					g.write(line)
			else:
				g.write(line)

change_header("aln.sam", "aln.chrM.sam", "chrM")