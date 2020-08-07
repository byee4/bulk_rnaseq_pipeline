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
  start0base:
    type: int
  end: 
    type: int
  
  split: 
    type: boolean
    default: false
    
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


  ### TRIM ###


  output_trim_report:
    type: File
    outputSource: step_trim/output_trim_report
  output_sort_trimmed_fastq:
    type: File
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
  
  output_sorted_rmdup_bam:
    type: File
    outputSource: step_barcodecollapse_se/output_barcodecollapsese_bam
  output_sorted_rmdup_bam_index:
    type: File
    outputSource: step_index_barcodecollapse_se/output_index_bai
    
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
  
  step_header2umitools_extract:
    run: header2umitools_extract.cwl
    in:
      input: 
        source: step_fastq_dump/output_fastq
        valueFrom: |
          ${
            return self[0];
          }
      start0base: start0base
      end: end
    out:
      [output]
      
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
    run: trim_se.cwl
    in:
      input_trim: 
        source: step_header2umitools_extract/output
        # Hack to turn a single File output into a File[] #
        valueFrom: ${ return [ self ]; }
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
    in:
      input: 
        source: step_sort_trimmed_fastq/output_fastqsort_sortedfastq
        valueFrom: |
          ${
            return self[0];
          }
    out:
      [gzipped]
  
  step_fastqc_trim_r1:
    run: wf_fastqc.cwl
    in:
      reads: gzip_trimmed_fastq/gzipped
    out: [
      output_qc_report,
      output_qc_stats
    ]
    
  step_map_genome:
    run: star.cwl
    in:
      readFilesIn:
        source: step_sort_trimmed_fastq/output_fastqsort_sortedfastq
        # Hack to turn a single File output into a File[] #
        # valueFrom: ${ return [ self ]; }
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
    run: samtools-index.cwl
    in:
      alignments: step_sort/output_sort_bam
    out: [alignments_with_index]
  
  step_barcodecollapse_se:
    run: barcodecollapse_se_nostats.cwl
    in:
      input_barcodecollapsese_bam: step_index/alignments_with_index
    out:
      [output_barcodecollapsese_bam]
  
  step_index_barcodecollapse_se:
    run: index.cwl
    in:
      input_index_bam: step_barcodecollapse_se/output_barcodecollapsese_bam
    out:
      [output_index_bai]
      
  step_makebigwigfiles:
    run: makebigwigfiles.cwl
    in:
      bam: step_barcodecollapse_se/output_barcodecollapsese_bam
      chromsizes: speciesChromSizes
      direction: direction
    out: [
      posbw,
      negbw
      ]

###########################################################################
# Downstream
###########################################################################

