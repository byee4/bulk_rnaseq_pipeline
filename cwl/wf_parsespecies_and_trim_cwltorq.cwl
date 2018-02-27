#!/usr/bin/env rnaseqse_cwltorq

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


###########################################################################
# Downstream
###########################################################################

