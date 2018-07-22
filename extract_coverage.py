import os
import pandas as pd

coverage = {}

original = pd.read_csv('coverage_across_reference.txt', sep="\t")
original_coverage = pd.Series(original['Coverage'])

number = 0
different = 0

for i in range(5000,5351):
	for j in 'A', 'C', 'G', 'T':
		cur_dir = str(i) + j
		try:  # will fail if dir doesn't exist
			data = pd.read_csv('%s/aln.chrM_stats/raw_data_qualimapReport/coverage_across_reference.txt' % cur_dir, sep="\t")
		except:
			continue
		coverage_cur_dir = pd.Series(data['Coverage'])
		if not coverage_cur_dir.equals(original_coverage):
			coverage[cur_dir] = pd.DataFrame({cur_dir : data['Coverage']})
coverage_df = pd.concat(coverage.values(), axis=1)
print(coverage.keys())