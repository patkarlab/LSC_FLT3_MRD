#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	IMPORT MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { TRIM } from './modules/TRIM.nf'
include { MAPBAM } from './modules/MAPBAM.nf'
include { MINIMAP } from './modules/MINIMAP.nf'
include { SORTBAM } from './modules/SORTBAM.nf'
include { BAM_TO_FASTQ} from './modules/BAM_TO_FASTQ.nf'
include { COVERAGE } from './modules/COVERAGE.nf'
include { FILT3R } from './modules/FILT3R.nf'
include { GETITD } from './modules/GETITD.nf'
include { FLT3_ITD_EXT } from './modules/FLT3_ITD_EXT.nf'
include { VARSCAN } from './modules/VARSCAN.nf'
include { ANNOVAR } from './modules/ANNOVAR.nf'
include { FORMAT_ANNOVAR_OUT } from './modules/FORMAT_ANNOVAR_OUT.nf'
include { COMBINE_ALL } from './modules/COMBINE_ALL.nf'


log.info """
STARTING PIPELINE
=*=*=*=*=*=*=*=*=
Sample list: ${params.input}
BED file: ${params.bedfile}
Sequences in:${params.sequences}
"""

bedfile = file("${params.bedfile}", checkIfExists: true)
illumina_adapters = file("${params.adaptors}", checkIfExists: true )
nextera_adapters = file("${params.nextera_adapters}", checkIfExists: true )
filt3r_reference = file("${params.filt3r_ref}", checkIfExists: true)
minimap_getitd_reference = file("${params.genome_minimap_getitd}", checkIfExists: true)
//getitd_path = file("${params.get_ITD_path}", checkIfExists: true)
annovar_db = file("${params.annovar_db}", checkIfExists:true)
genome_file = file("${params.genome}", checkIfExists: true)
index_files = file("${params.genome_dir}/${params.ind_files}.*")

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow FLT3_MRD {
	Channel.fromPath(params.input)
		.splitCsv(header:false)
		.map { row ->
			def sample = row[0].trim()
			def r1 = file("${params.sequences}/${sample}_S*_R1_*.fastq.gz", checkIfExists: false)
			def r2 = file("${params.sequences}/${sample}_S*_R2_*.fastq.gz", checkIfExists: false)

			if (!r1 && !r2) {
				r1 = file("${params.sequences}/${sample}*_R1.fastq.gz", checkIfExists: false)
				r2 = file("${params.sequences}/${sample}*_R2.fastq.gz", checkIfExists: false)
			}
			tuple(sample, r1, r2)
		}
		.set { fastq_ch }
	main:
	TRIM(fastq_ch, illumina_adapters, nextera_adapters)
	MAPBAM(TRIM.out, genome_file, index_files)
	FILT3R(TRIM.out, filt3r_reference)
	MINIMAP(fastq_ch, minimap_getitd_reference)
	SORTBAM(MINIMAP.out)
	BAM_TO_FASTQ(SORTBAM.out)
	GETITD(BAM_TO_FASTQ.out )
	FLT3_ITD_EXT(TRIM.out)
	COVERAGE(MAPBAM.out, bedfile)
	VARSCAN(MAPBAM.out, genome_file, index_files, bedfile)
	ANNOVAR(VARSCAN.out.join(FILT3R.out.filt3r_vcf), annovar_db)
	FORMAT_ANNOVAR_OUT(ANNOVAR.out.join(FILT3R.out.filt3r_json))
	COMBINE_ALL(FILT3R.out.filt3r_json.join(FORMAT_ANNOVAR_OUT.out.varscan_anno.join(FORMAT_ANNOVAR_OUT.out.filt3r_anno.join(GETITD.out.join(FLT3_ITD_EXT.out.join(COVERAGE.out))))))
}

workflow.onComplete {
	log.info ( workflow.success ? "\n\nDone! Output in the 'Final_Output' directory \n" : "Oops .. something went wrong" )
	def msg = """\
	Pipeline execution summary
	---------------------------
	Completed at : ${workflow.complete}
	Duration     : ${workflow.duration}
	""".stripIndent()

	println ""
	println msg
}

