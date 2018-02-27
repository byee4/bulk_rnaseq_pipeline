#!/usr/bin/env rnaseqcore_se_cwltorq

cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement      # TODO needed?

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
  read:
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
    outputSource: A_trim/output_trim
  A_output_trim_report:
    type: File
    outputSource: A_trim/output_trim_report
  A_output_sort_trimmed_fastq:
    type: File
    outputSource: A_sort_trimmed_fastq/output_fastqsort_sortedfastq

  A_output_maprepeats_unmapped_fwd:
    type: File
    outputSource: A_map_repeats/output_map_unmapped_fwd
  A_output_maprepeats_stats:
    type: File
    outputSource: A_map_repeats/mappingstats
  A_output_maprepeats_mapped_to_genome:
    type: File
    outputSource: A_map_repeats/aligned
  A_output_sort_repunmapped_fastq:
    type: File
    outputSource: A_sort_repunmapped_fastq/output_fastqsort_sortedfastq

  A_output_mapgenome_unmapped_fwd:
    type: File
    outputSource: A_map_genome/output_map_unmapped_fwd
  A_output_mapgenome_mapped_to_genome:
    type: File
    outputSource: A_map_genome/aligned
  A_output_mapgenome_stats:
    type: File
    outputSource: A_map_genome/mappingstats

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
# Upstream
###########################################################################

  A_fastqc:
      run: fastqc.cwl
      in:
        reads: read
      out: [
        output_qc_report,
        output_qc_stats
      ]

  A_trim:
      run: trim_se.cwl
      in:
        input_trim: read
        input_trim_b_adapters: adapters
      out: [
        output_trim,
        output_trim_report
      ]

  A_sort_trimmed_fastq:
    run: fastqsort.cwl
    in:
      input_fastqsort_fastq: A_trim/output_trim
    out:
      [output_fastqsort_sortedfastq]

  A_map_repeats:
    run: star_se.cwl
    in:
      readFilesIn: A_sort_trimmed_fastq/output_fastqsort_sortedfastq
      genomeDir: repeatElementGenomeDir
    out:
      [aligned, output_map_unmapped_fwd, mappingstats]

  A_sort_repunmapped_fastq:
    run: fastqsort.cwl
    in:
      input_fastqsort_fastq: A_map_repeats/output_map_unmapped_fwd
    out:
      [output_fastqsort_sortedfastq]

  A_map_genome:
    run: star_se.cwl
    in:
      readFilesIn: A_sort_repunmapped_fastq/output_fastqsort_sortedfastq
      genomeDir: speciesGenomeDir
    out:
      [aligned, output_map_unmapped_fwd, mappingstats]

  A_sort:
    run: sort.cwl
    in:
      input_sort_bam: A_map_genome/aligned
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
      chromsizes: speciesChromSizes
    out: [
      posbw,
      negbw
      ]

###########################################################################
# Downstream
###########################################################################

