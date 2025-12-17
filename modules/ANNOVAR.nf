process ANNOVAR {
	tag "${Sample}"
	label 'process_medium'
	publishDir "${params.outdir}/${Sample}/", mode: 'copy', pattern: '*.csv'
	input:
		tuple val (Sample), file(varscanVcf), file(filt3r_vcf)
		file(annovar_db)
	output:
		tuple val (Sample), file("${Sample}.varscan.hg19_multianno.csv"), file("${Sample}.filt3r.hg19_multianno.csv")
	script:
	"""
	convert2annovar.pl -format vcf4 ${varscanVcf} --outfile ${Sample}.varscan.avinput --withzyg --includeinfo
		
	table_annovar.pl ${Sample}.varscan.avinput --out ${Sample}.varscan --remove --protocol refGene,cytoBand,cosmic84,popfreq_all_20150413,avsnp150,intervar_20180118,1000g2015aug_all,clinvar_20170905 --operation g,r,f,f,f,f,f,f --buildver hg19 --nastring '-1' --otherinfo --csvout --thread ${task.cpus} ${annovar_db} --xreffile example/gene_fullxref.txt

	convert2annovar.pl -format vcf4 ${Sample}_filt3r.vcf --outfile ${Sample}.filt3r.avinput --withzyg --includeinfo

	table_annovar.pl ${Sample}.filt3r.avinput --out ${Sample}.filt3r --remove --protocol refGene,cytoBand,cosmic84,popfreq_all_20150413,avsnp150,intervar_20180118,1000g2015aug_all,clinvar_20170905 --operation g,r,f,f,f,f,f,f --buildver hg19 --nastring '-1' --otherinfo --csvout --thread ${task.cpus} ${annovar_db} --xreffile example/gene_fullxref.txt
	"""
}
