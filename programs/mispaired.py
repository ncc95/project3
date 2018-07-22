
def check_mispaired(input,output):
	"""
	Returns sam file only with reads mapped to chrM.
	Rather than randomly selecting the origin of multimapped reads,
	the program favours two paired reads to derive from
	one chromosome, chrM.	
	"""
	with open(input) as f, open(output, "w") as g:
		lines = f.readlines()
		M = "chrM"
		for i, line in enumerate(lines, 0):
			if line[0] == "@":  # headers
				if M in line or "@PG" in line:  # only keep mtDNA and PG header
					g.write(line)
			else:
				# split each line into columns
				columns = line.rsplit("\t")
				pair = columns[6]
				
				# if both reads on mtDNA
				if pair == "=":
					if columns[2] == M:
						g.write(line)
				else:
					# discard nuclear DNA
					if M in line:

						# if information on this line
						if columns[2] != M:
							# extract alternative pair
							XA = columns[15]
							# extract position of mtDNA read
							before, chrM, after = XA.partition(M)
							l = [x.strip() for x in after.split(',')]
							pos = l[1]
							# write new line
							columns[2] = M
							columns[3] = pos[1:]
							columns[6] = "="
							newline = "\t".join(columns)
							g.write(newline)

						# if information not on this line, look at pair
						else:
							try:  # will not work for last line
								if lines[i+1].rsplit("\t")[0] == columns[0]:
									nextline = lines[i+1]
								if lines[i-1].rsplit("\t")[0] == columns[0]:
									nextline = lines[i-1]
							except:
								if lines[i-1].rsplit("\t")[0] == columns[0]:
									nextline = lines[i-1]
							# same thing as above
							nextline_columns = nextline.rsplit("\t")
							XA = nextline_columns[15]
							before, chrM, after = XA.partition(M)
							l = [x.strip() for x in after.split(',')]
							pos = l[1]
							columns[6] = M
							columns[7] = pos[1:]
							columns[6] = "="
							newline = "\t".join(columns)
							g.write(newline)

check_mispaired("aln.sam", "aln.chrM.sam")
