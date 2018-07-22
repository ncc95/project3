def remove_mtdna_from_sam(input,output):
	with open(input) as f:
		with open(output, "w") as g:
			for line in f:
				if line.rsplit("\t")[2] != "chrM":
					g.write(line)

remove_mtdna_from_sam("aln.sam", "aln_no_mtdna.sam")
