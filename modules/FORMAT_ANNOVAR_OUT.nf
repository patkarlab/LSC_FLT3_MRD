process FORMAT_ANNOVAR_OUT {
	tag "${Sample}"
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*.csv'
	input:
		tuple val (Sample), file(varscan_csv), file(fil3r_csv), file(filt3r_json)
	output:
		tuple val (Sample), file("${Sample}.varscan.csv"), emit:varscan_anno
			tuple val (Sample), file("${Sample}_filt3r_out.csv"), emit:filt3r_anno
	script:
	"""
	if [ -s ${Sample}.varscan.hg19_multianno.csv ]; then
		format_varscan.py ${Sample}.varscan.hg19_multianno.csv ${Sample}.varscan.csv
	else
		touch ${Sample}.varscan.csv
	fi

	# Check if the multianno file is empty
	if [[ ! -s ${Sample}.filt3r.hg19_multianno.csv ]]; then
		touch ${Sample}.filt3r__final.csv
		touch ${Sample}_filt3r_json_filtered.csv
		touch ${Sample}_filt3r_out.csv
	else
		format_filt3r.py ${Sample}.filt3r.hg19_multianno.csv ${Sample}.filt3r__final.csv
		filter_json.py ${Sample}_filt3r_json.csv ${Sample}_filt3r_json_filtered.csv
		merge_filt3r_csvs.py ${Sample}.filt3r__final.csv ${Sample}_filt3r_json_filtered.csv ${Sample}_filt3r_out.csv
	fi
		"""
}
