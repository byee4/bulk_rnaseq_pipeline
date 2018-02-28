#!/usr/bin/env cwltool

# rnaseq_pe_cwltorq

cwlVersion: v1.0
class: Workflow

#$namespaces:
#  ex: http://example.com/

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement


#hints:
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


inputs:
  speciesChromSizes:
    type: File
  speciesGenomeDir:
    type: Directory
  repeatElementGenomeDir:
    type: Directory
  species:
    type: string
  adapters:
    type: File
  reads:
    type:
      type: array
      items:
        type: record
        fields:
          read1:
            type: File
          read2:
            type: File
          name:
            type: string

outputs:
  A_output_fastqc_report:
    type: File[]
    outputSource: scatter_rnaseqcore_pe/A_output_fastqc_report
  A_output_fastqc_stats:
    type: File[]
    outputSource: scatter_rnaseqcore_pe/A_output_fastqc_stats

  A_output_trim:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: scatter_rnaseqcore_pe/A_output_trim
  A_output_trim_report:
    type: File[]
    outputSource: scatter_rnaseqcore_pe/A_output_trim_report
  A_output_sort_trimmed_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: scatter_rnaseqcore_pe/A_output_sort_trimmed_fastq

  A_output_maprepeats_stats:
    type: File[]
    outputSource: scatter_rnaseqcore_pe/A_output_maprepeats_stats
  A_output_maprepeats_mapped_to_genome:
    type: File[]
    outputSource: scatter_rnaseqcore_pe/A_output_maprepeats_mapped_to_genome
  A_output_sort_repunmapped_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: scatter_rnaseqcore_pe/A_output_sort_repunmapped_fastq

  A_output_mapgenome_mapped_to_genome:
    type: File[]
    outputSource: scatter_rnaseqcore_pe/A_output_mapgenome_mapped_to_genome
  A_output_mapgenome_stats:
    type: File[]
    outputSource: scatter_rnaseqcore_pe/A_output_mapgenome_stats

  A_output_sorted_bam:
    type: File[]
    outputSource: scatter_rnaseqcore_pe/A_output_sorted_bam
  A_output_sorted_bam_index:
    type: File[]
    outputSource: scatter_rnaseqcore_pe/A_output_sorted_bam_index

  A_bigwig_pos_bam:
    type: File[]
    outputSource: scatter_rnaseqcore_pe/A_bigwig_pos_bam
  A_bigwig_neg_bam:
    type: File[]
    outputSource: scatter_rnaseqcore_pe/A_bigwig_neg_bam

steps:

###########################################################################
# Upstream
###########################################################################

  scatter_rnaseqcore_pe:
    run: wf_rnaseqcore_pe.cwl
    ###
    scatter: read
    ###
    in:
      speciesChromSizes: speciesChromSizes
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      species: species
      adapters: adapters
      read: reads
    out: [
      A_output_fastqc_report,
      A_output_fastqc_stats,
      A_output_trim,
      A_output_trim_report,
      A_output_sort_trimmed_fastq,
      A_output_maprepeats_mapped_to_genome,
      A_output_maprepeats_stats,
      A_output_sort_repunmapped_fastq,
      A_output_mapgenome_mapped_to_genome,
      A_output_mapgenome_stats,
      A_output_sorted_bam,
      A_output_sorted_bam_index,
      A_bigwig_pos_bam,
      A_bigwig_neg_bam
    ]


###########################################################################
# Downstream
###########################################################################

