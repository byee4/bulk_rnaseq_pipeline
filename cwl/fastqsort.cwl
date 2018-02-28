#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 16
    ramMin: 8000
    tmpdirMin: 10000
    outdirMin: 10000



# samtools executable in bin folder is v 0.1.18-dev (r982:313)
#baseCommand: [singularityexec, eclip.img, fastq-sort]
# FIXME
#baseCommand: [singularityexec, eclip.img, /projects/ps-yeolab/software/fastq-tools-0.8/bin/fastq-sort]

baseCommand: [fastq-sort]


#$namespaces:
#  ex: http://example.com/

#hints:
#
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"

inputs:

  input_fastqsort_fastq:
    type: File
    format: http://edamontology.org/format_1930
    inputBinding:
      position: 1
      prefix: --id
    label: ""
    doc: "input fastq"

  output_fastqsort_fastq:
    type: string
    default: ""

# stdout: $(inputs.input_fastqsort_fastq.basename)So.fq
stdout: ${
    if (inputs.output_fastqsort_fastq == "") {
      return inputs.input_fastqsort_fastq.nameroot + ".sorted.fq";
    }
  else {
      return inputs.output_fastqsort_fastq;
    }
  }

outputs:

  output_fastqsort_sortedfastq:
    type: File
    format: http://edamontology.org/format_1930
    outputBinding:
      # glob: $(inputs.output_fastqsort_filename)
      # glob: $(inputs.input_fastqsort_fastq.basename)So.fq
      glob: |
        ${
          if (inputs.output_fastqsort_fastq == "") {
            return inputs.input_fastqsort_fastq.nameroot + ".sorted.fq";
          }
          else {
            return inputs.output_fastqsort_fastq;
          }
        }
    label: ""
    doc: "sorted fastq"
