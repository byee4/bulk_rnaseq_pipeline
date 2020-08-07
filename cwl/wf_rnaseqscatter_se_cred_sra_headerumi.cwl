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
  start0base:
    type: int
  end: 
    type: int

outputs:


  ### FASTQC STATS ###


  output_fastqc_r1_report:
    type: File[]
    outputSource: step_rnaseqcore_se/output_fastqc_r1_report
  output_fastqc_r1_stats:
    type: File[]
    outputSource: step_rnaseqcore_se/output_fastqc_r1_stats


  ### TRIM ###


  output_trim_report:
    type: File[]
    outputSource: step_rnaseqcore_se/output_trim_report
  output_sort_trimmed_fastq:
    type: File[]
    outputSource: step_rnaseqcore_se/output_sort_trimmed_fastq


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


  ### RMDUP OUTPUTS ###
  
  
  output_sorted_rmdup_bam:
    type: File[]
    outputSource: step_rnaseqcore_se/output_sorted_rmdup_bam
    
  output_sorted_rmdup_bam_index:
    type: File[]
    outputSource: step_rnaseqcore_se/output_sorted_rmdup_bam_index
  
  
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
    run: wf_rnaseqcore_se_cred_sra_headerumi.cwl
    ###
    scatter: sample
    ###
    in:
      speciesChromSizes: speciesChromSizes
      speciesGenomeDir: speciesGenomeDir
      b_adapters: b_adapters
      sample: samples
      start0base: start0base
      end: end
    out: [
      output_fastqc_r1_report,
      output_fastqc_r1_stats,
      output_trim_report,
      output_sort_trimmed_fastq,
      output_mapgenome_mapped_to_genome,
      output_mapgenome_stats,
      output_sorted_bam,
      output_sorted_rmdup_bam,
      output_sorted_rmdup_bam_index,
      output_bigwig_pos_bam,
      output_bigwig_neg_bam
    ]


###########################################################################
# Downstream
###########################################################################

