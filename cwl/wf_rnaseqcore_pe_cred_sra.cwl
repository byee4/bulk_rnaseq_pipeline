#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement

inputs:
  speciesChromSizes:
    type: File
  speciesGenomeDir:
    type: Directory
  b_adapters:
    type: File
  sample:
    type: 
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
        # characteristics:
        #   type: record[]
  
  split: 
    type: boolean
    default: true
    
  direction:
    type: string
    default: "r"
    
outputs:


  ### FASTQC STATS ###


  output_fastqc_r1_report:
    type: File
    outputSource: step_fastqc_trim_r1/output_qc_report
  output_fastqc_r1_stats:
    type: File
    outputSource: step_fastqc_trim_r1/output_qc_stats
  
  output_fastqc_r2_report:
    type: File
    outputSource: step_fastqc_trim_r2/output_qc_report
  output_fastqc_r2_stats:
    type: File
    outputSource: step_fastqc_trim_r2/output_qc_stats
    
    
  ### TRIM ###


  output_trim:
    type: File[]
    outputSource: step_trim/output_trim
  output_trim_report:
    type: File
    outputSource: step_trim/output_trim_report

  output_sort_trimmed_fastq:
    type: File[]
    outputSource: gzip_trimmed_fastq/gzipped


  ### GENOME MAPPING OUTPUTS ###


  output_mapgenome_mapped_to_genome:
    type: File
    outputSource: step_map_genome/aligned
  output_mapgenome_stats:
    type: File
    outputSource: step_map_genome/mappingstats

  output_sorted_bam:
    type: File
    outputSource: step_sort/output_sort_bam
  output_sorted_bam_index:
    type: File
    outputSource: step_index/output_index_bai


  ### BIGWIG FILES ###


  output_bigwig_pos_bam:
    type: File
    outputSource: step_makebigwigfiles/posbw
  output_bigwig_neg_bam:
    type: File
    outputSource: step_makebigwigfiles/negbw


steps:


###########################################################################
# Parse adapter files to array inputs
###########################################################################
  
  
  step_parse_sra_records:
    run: parse_sra_records.cwl
    in:
      sample: sample
    out: [accession]
  
  step_prefetch:
    run: prefetch.cwl
    in:
      accession: step_parse_sra_records/accession
    out: [
      sra_file
    ]
    
  step_fastq_dump:
    run: fastq-dump.cwl
    in:
      sra: step_prefetch/sra_file
      split: split
    out: [
      output_fastq
    ]

  step_get_b_adapters:
    run: file2stringArray.cwl
    in:
      file: b_adapters
    out:
      [output]
      
  
###########################################################################
# Upstream
###########################################################################

  step_trim:
    run: trim_pe.cwl
    in:
      input_trim: step_fastq_dump/output_fastq
      input_trim_b_adapters: step_get_b_adapters/output
    out: [
      output_trim,
      output_trim_report
    ]

  step_sort_trimmed_fastq:
    run: fastqsort.cwl
    scatter: input_fastqsort_fastq
    in:
      input_fastqsort_fastq: step_trim/output_trim
    out:
      [output_fastqsort_sortedfastq]

  gzip_trimmed_fastq:
    run: gzip.cwl
    scatter: input
    in:
      input: step_sort_trimmed_fastq/output_fastqsort_sortedfastq
    out:
      [gzipped]
  
  step_fastqc_trim_r1:
    run: wf_fastqc.cwl
    in:
      reads: 
        source: gzip_trimmed_fastq/gzipped
        valueFrom: |
          ${
            return self[0];
          }
    out: [
      output_qc_report,
      output_qc_stats
    ]
  
  step_fastqc_trim_r2:
    run: wf_fastqc.cwl
    in:
      reads: 
        source: gzip_trimmed_fastq/gzipped
        valueFrom: |
          ${
            return self[1];
          }
    out: [
      output_qc_report,
      output_qc_stats
    ]

  step_map_genome:
    run: star.cwl
    in:
      readFilesIn: step_sort_trimmed_fastq/output_fastqsort_sortedfastq
      genomeDir: speciesGenomeDir
    out: [
      aligned,
      output_map_unmapped_fwd,
      output_map_unmapped_rev,
      starsettings,
      mappingstats
    ]

  step_sort:
    run: samtools-sort.cwl
    in:
      input_sort_bam: step_map_genome/aligned
    out:
      [output_sort_bam]

  step_index:
    run: index.cwl
    in:
      input_index_bam: step_sort/output_sort_bam
    out:
      [output_index_bai]

  step_makebigwigfiles:
    run: makebigwigfiles.cwl
    in:
      bam: step_sort/output_sort_bam
      chromsizes: speciesChromSizes
      direction: direction
    out: [
      posbw,
      negbw
      ]

###########################################################################
# Downstream
###########################################################################

