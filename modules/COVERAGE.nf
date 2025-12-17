process COVERAGE {
	tag "${Sample}"
	label 'process_low'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy'
	input:
		tuple val (Sample), file(bam), file(bamBai)
		file (bedfile)
	output:
		tuple val (Sample), file ("${Sample}.counts.bed")
	script:
	"""
	bedtools bamtobed -i ${bam} > ${Sample}.bed
	bedtools coverage -counts -a ${bedfile} -b ${Sample}.bed > ${Sample}.counts.bed
	"""
}
