#!/usr/bin/env cwltool

cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement


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
  read:
    type:
      type: record
      fields:
        read1:
          type: File
        name:
          type: string

  direction:
    type: string
    
outputs:


  ### FASTQC STATS ###


  output_fastqc_report:
    type: File
    outputSource: step_fastqc/output_qc_report
  output_fastqc_stats:
    type: File
    outputSource: step_fastqc/output_qc_stats


  ### TRIM ###


  output_trim_report:
    type: File
    outputSource: step_trim/output_trim_report
  output_sort_trimmed_fastq:
    type: File
    outputSource: gzip_trimmed_fastq/gzipped


  ### REPEAT MAPPING OUTPUTS ###


  output_maprepeats_mapped_to_genome:
    type: File
    outputSource: step_map_repeats/aligned
  output_maprepeats_stats:
    type: File
    outputSource: step_map_repeats/mappingstats
  output_sort_repunmapped_fastq:
    type: File
    outputSource: gzip_repunmapped_fastq/gzipped


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

  parse_records:
    run: parse_records.cwl
    in:
      read: read
    # read2 should/will be null/empty
    out: [
      read1,
      read2
    ]

  get_b_adapters:
    run: file2stringArray.cwl
    in:
      file: b_adapters
    out:
      [output]

###########################################################################
# Upstream
###########################################################################


  step_fastqc:
    run: fastqc.cwl
    in:
      reads: parse_records/read1
    out: [
      output_qc_report,
      output_qc_stats
    ]

  step_trim:
    run: trim_se.cwl
    in:
      input_trim:
        source: parse_records/read1
        # Hack to turn a single File output into a File[] #
        valueFrom: ${ return [ self ]; }
      input_trim_b_adapters: get_b_adapters/output
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
    in:
      input: 
        source: step_sort_trimmed_fastq/output_fastqsort_sortedfastq
        valueFrom: |
          ${
            return self[0];
          }
    out:
      [gzipped]
      
  step_map_repeats:
    run: star.cwl
    in:
      readFilesIn: step_sort_trimmed_fastq/output_fastqsort_sortedfastq
      genomeDir: repeatElementGenomeDir
    out: [
      aligned,
      output_map_unmapped_fwd,
      output_map_unmapped_rev,
      starsettings,
      mappingstats
    ]

  step_sort_repunmapped_fastq:
    run: fastqsort.cwl
    in:
      input_fastqsort_fastq: step_map_repeats/output_map_unmapped_fwd
    out:
      [output_fastqsort_sortedfastq]
  
  gzip_repunmapped_fastq:
    run: gzip.cwl
    in:
      input: step_sort_repunmapped_fastq/output_fastqsort_sortedfastq
    out:
      [gzipped]
      
  step_map_genome:
    run: star.cwl
    in:
      readFilesIn:
        source: step_sort_repunmapped_fastq/output_fastqsort_sortedfastq
        # Hack to turn a single File output into a File[] #
        valueFrom: ${ return [ self ]; }
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

