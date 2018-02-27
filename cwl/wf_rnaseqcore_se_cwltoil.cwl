#!/usr/bin/env cwltoil

cwlVersion: v1.0
class: Workflow

#$namespaces:
#  ex: http://example.com/

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?
  #- class: InlineJavascriptRequirement


#hints:
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"


inputs:

  species:
    type: string
  adapters:
    type: File

  out_filter_multimap_nmax_10:
    type: string
    default: "10"

  reads:
    type: File

outputs:
  A_output_fastqc_report:
    type: File
    outputSource: A_fastqc/output_qc_report
  A_output_fastqc_stats:
    type: File
    outputSource: A_fastqc/output_qc_stats

  A_output_trim_fwd:
    type: File
    outputSource: A_trimse/output_trim
  A_output_trim_report:
    type: File
    outputSource: A_trimse/output_trim_report

  A_output_sort_trimmed_fastq:
    type: File
    outputSource: A_sort_trimmed_fastq/output_fastqsort_sortedfastq

  A_output_maprepeats_unmapped_fwd:
    type: File
    outputSource: A_map_repeats/output_map_unmapped_fwd
  A_output_maprepeats_mapped_to_genome:
    type: File
    outputSource: A_map_repeats/output_map_mapped_to_genome
  A_output_maprepeats_stats:
    type: File
    outputSource: A_map_repeats/output_map_stats

  A_output_sort_repunmapped_fastq:
    type: File
    outputSource: A_sort_repunmapped_fastq/output_fastqsort_sortedfastq

  A_output_mapgenome_unmapped_fwd:
    type: File
    outputSource: A_map_genome/output_map_unmapped_fwd
  A_output_mapgenome_mapped_to_genome:
    type: File
    outputSource: A_map_genome/output_map_mapped_to_genome
  A_output_mapgenome_stats:
    type: File
    outputSource: A_map_genome/output_map_stats

  A_output_sorted_bam:
    type: File
    outputSource: A_sort/output_sort_bam
  A_output_sorted_bam_index:
    type: File
    outputSource: A_index/output_index_bai

  A_bigwig_pos_bam:
    type: File
    outputSource: A_makebigwigfiles/posbw
  A_bigwig_neg_bam:
    type: File
    outputSource: A_makebigwigfiles/negbw

steps:

###########################################################################
# Parse inputs
###########################################################################

  parsespecies:
    run: parsespecies.cwl
    in:
      species: species
    out: [chromsizes, starrefrepeats, starrefgenome, annotateref]


###########################################################################
# Upstream
###########################################################################

  A_fastqc:
      run: fastqc.cwl
      in:
        reads: reads
      out: [
        output_qc_report,
        output_qc_stats
      ]

  A_trimse:
      run: trimse.cwl
      in:
        input_trim: reads
        input_trim_b_adapters: adapters
      out: [
        output_trim,
        output_trim_report
      ]

  A_sort_trimmed_fastq:
    run: fastqsort.cwl
    in:
      input_fastqsort_fastq: A_trimse/output_trim
    out:
      [output_fastqsort_sortedfastq]

  A_map_repeats:
    run: mapse.cwl
    in:
      out_filter_multimap_nmax: out_filter_multimap_nmax_10
      input_map_ref: parsespecies/starrefrepeats
      input_map_fwd: A_sort_trimmed_fastq/output_fastqsort_sortedfastq
    out: [
      output_map_unmapped_fwd,
      output_map_mapped_to_genome,
      output_map_stats
    ]

  A_sort_repunmapped_fastq:
    run: fastqsort.cwl
    in:
      input_fastqsort_fastq: A_map_repeats/output_map_unmapped_fwd
    out:
      [output_fastqsort_sortedfastq]

  A_map_genome:
    run: mapse.cwl
    in:
      out_filter_multimap_nmax: out_filter_multimap_nmax_10
      input_map_ref: parsespecies/starrefgenome
      input_map_fwd: A_sort_repunmapped_fastq/output_fastqsort_sortedfastq
    out: [
      output_map_unmapped_fwd,
      output_map_mapped_to_genome,
      output_map_stats
    ]

  A_sort:
    run: sort.cwl
    in:
      input_sort_bam: A_map_genome/output_map_mapped_to_genome
    out:
      [output_sort_bam]

  A_index:
    run: index.cwl
    in:
      input_index_bam: A_sort/output_sort_bam
    out:
      [output_index_bai]

  A_makebigwigfiles:
    run: makebigwigfiles.cwl
    in:
      bam: A_sort/output_sort_bam
      chromsizes: parsespecies/chromsizes
    out: [
      posbw,
      negbw
      ]

###########################################################################
# Downstream
###########################################################################

