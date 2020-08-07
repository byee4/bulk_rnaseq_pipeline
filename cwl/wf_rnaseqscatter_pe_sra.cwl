#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  speciesChromSizes:
    type: File
  speciesGenomeDir:
    type: Directory
  repeatElementGenomeDir:
    type: Directory
  b_adapters:
    type: File
  samples:
    type:
      type: array
      items:
        type: record
        fields:
          library_nickname:
            type: string
          library_prep:
            type: string
          sample_id:
            type: string
          original_assembly:
            type: string
          instrument_model:
            type: string

outputs:


  ### FASTQC STATS ###


  output_fastqc_r1_report:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_fastqc_r1_report
  output_fastqc_r1_stats:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_fastqc_r1_stats
  
  output_fastqc_r2_report:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_fastqc_r2_report
  output_fastqc_r2_stats:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_fastqc_r2_stats

  output_unmapped_fastqc_r1_report:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_unmapped_fastqc_r1_report
  output_unmapped_fastqc_r1_stats:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_unmapped_fastqc_r1_stats
  
  output_unmapped_fastqc_r2_report:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_unmapped_fastqc_r2_report
  output_unmapped_fastqc_r2_stats:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_unmapped_fastqc_r2_stats


  ### TRIM ###


  output_trim_report:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_trim_report
  output_sort_trimmed_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step_rnaseqcore_pe/output_sort_trimmed_fastq


  ### REPEAT MAPPING OUTPUTS ###


  output_maprepeats_stats:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_maprepeats_stats
  output_maprepeats_mapped_to_genome:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_maprepeats_mapped_to_genome
  output_sort_repunmapped_fastq:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: step_rnaseqcore_pe/output_sort_repunmapped_fastq


  ### GENOME MAPPING OUTPUTS ###


  output_mapgenome_mapped_to_genome:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_mapgenome_mapped_to_genome
  output_mapgenome_stats:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_mapgenome_stats

  output_sorted_bam:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_sorted_bam
  output_sorted_bam_index:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_sorted_bam_index


  ### BIGWIG FILES ###


  bigwig_pos_bam:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_bigwig_pos_bam
  bigwig_neg_bam:
    type: File[]
    outputSource: step_rnaseqcore_pe/output_bigwig_neg_bam

steps:

###########################################################################
# Upstream
###########################################################################

  step_rnaseqcore_pe:
    run: wf_rnaseqcore_pe_sra.cwl
    ###
    scatter: sample
    ###
    in:
      speciesChromSizes: speciesChromSizes
      speciesGenomeDir: speciesGenomeDir
      repeatElementGenomeDir: repeatElementGenomeDir
      b_adapters: b_adapters
      sample: samples
    out: [
      output_fastqc_r1_report,
      output_fastqc_r1_stats,
      output_fastqc_r2_report,
      output_fastqc_r2_stats,
      output_unmapped_fastqc_r1_report,
      output_unmapped_fastqc_r1_stats,
      output_unmapped_fastqc_r2_report,
      output_unmapped_fastqc_r2_stats,
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

