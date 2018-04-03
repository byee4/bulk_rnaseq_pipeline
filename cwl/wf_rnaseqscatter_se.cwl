#!/usr/bin/env cwltool

# rnaseq_se_cwltorq

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
  b_adapters:
    type: File
  reads:
    type:
      type: array
      items:
        type: record
        fields:
          read1:
            type: File
          name:
            type: string


outputs:


  ### FASTQC STATS ###


  output_fastqc_report:
    type: File[]
    outputSource: step_rnaseqcore_se/output_fastqc_report
  output_fastqc_stats:
    type: File[]
    outputSource: step_rnaseqcore_se/output_fastqc_stats


  ### TRIM ###


  output_trim:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step_rnaseqcore_se/output_trim
  output_trim_report:
    type: File[]
    outputSource: step_rnaseqcore_se/output_trim_report
  output_sort_trimmed_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step_rnaseqcore_se/output_sort_trimmed_fastq


  ### REPEAT MAPPING OUTPUTS ###


  output_maprepeats_stats:
    type: File[]
    outputSource: step_rnaseqcore_se/output_maprepeats_stats
  output_maprepeats_mapped_to_genome:
    type: File[]
    outputSource: step_rnaseqcore_se/output_maprepeats_mapped_to_genome
  output_sort_repunmapped_fastq:
    type: File[]
    outputSource: step_rnaseqcore_se/output_sort_repunmapped_fastq


  ### GENOME MAPPING OUTPUTS ###


  output_mapgenome_mapped_to_genome:
    type: File[]
    outputSource: step_rnaseqcore_se/output_mapgenome_mapped_to_genome
  output_mapgenome_stats:
    type: File[]
    outputSource: step_rnaseqcore_se/output_mapgenome_stats


  output_sorted_bam:
    type: File[]
    outputSource: step_rnaseqcore_se/output_sorted_bam
  output_sorted_bam_index:
    type: File[]
    outputSource: step_rnaseqcore_se/output_sorted_bam_index


  ### BIGWIG FILES ###


  bigwig_pos_bam:
    type: File[]
    outputSource: step_rnaseqcore_se/output_bigwig_pos_bam
  bigwig_neg_bam:
    type: File[]
    outputSource: step_rnaseqcore_se/output_bigwig_neg_bam


steps:

###########################################################################
# Upstream
###########################################################################

  step_rnaseqcore_se:
    run: wf_rnaseqcore_se.cwl
    ###
    scatter: read
    ###
    in:
      speciesChromSizes: speciesChromSizes
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      species: species
      b_adapters: b_adapters
      read: reads
    out: [
      output_fastqc_report,
      output_fastqc_stats,
      output_trim,
      output_trim_report,
      output_sort_trimmed_fastq,
      output_maprepeats_mapped_to_genome,
      output_maprepeats_stats,
      output_sort_repunmapped_fastq,
      output_mapgenome_mapped_to_genome,
      output_mapgenome_stats,
      output_sorted_bam,
      output_sorted_bam_index,
      output_bigwig_pos_bam,
      output_bigwig_neg_bam
    ]


###########################################################################
# Downstream
###########################################################################

