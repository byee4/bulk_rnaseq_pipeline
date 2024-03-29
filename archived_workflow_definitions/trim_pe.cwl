#!/usr/bin/env cwltool

cwlVersion: v1.0
class: CommandLineTool

# , $overlap_length_option
# , $g_adapters_option
# , $A_adapters_option
# , $a_adapters_option
# , -o, out_fastq.fastq.gz
# , -p, out_pair.fastq.gz
# , in_fastq.fastq.gz
# , in_pair.fastq.gz
# > report

#$namespaces:
#  ex: http://example.com/

requirements:
  - class: ResourceRequirement
    coresMin: 2
    ramMin: 16000
    tmpdirMin: 4000
    #outdirMin: 4000
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

#hints:
#  - class: ex:PackageRequirement
#    packages:
#      - name: cutadapt
#        package_manager: pip
#        version: "1.10"
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"
#  - class: ShellCommandRequirement


baseCommand: [cutadapt]

# arguments: [-f, fastq,
#   --match-read-wildcards,
#   --times, "2",
#   -e, "0.0",
#   --quality-cutoff, "6",
#   -m, "18",
#   -o, $(inputs.input_trim.nameroot)Tr.fqgz
#   ]


inputs:

  f:
    type: string
    default: "fastq"
    inputBinding:
      position: -2
      prefix: -f

  input_trim_overlap_length:
    type: string
    default: "5"
    inputBinding:
      position: -1
      prefix: -O

  input_trim_b_adapters:
    type: File
    inputBinding:
      position: 0
      prefix: "--anywhere=file:"
      separate: false

  match_read_wildcards:
    type: boolean
    default: true
    inputBinding:
      position: 1
      prefix: --match-read-wildcards

  times:
    type: string
    default: "2"
    inputBinding:
      position: 2
      prefix: --times

  error_rate:
    type: string
    default: "0.0"
    inputBinding:
      position: 3
      prefix: -e

  minimum_length:
    type: string
    default: "18"
    inputBinding:
      position: 4
      prefix: -m

  output_r1:
    type: string
    inputBinding:
      position: 5
      prefix: -o
      valueFrom: |
        ${
          if (inputs.output_r1 == "") {
            return inputs.input_trim[0].nameroot + "Tr.fq";
          }
          else {
            return inputs.output_r1;
          }
        }
    default: ""

  output_r2:
    type: string?
    inputBinding:
      position: 6
      prefix: -p
      valueFrom: |
        ${
          if (inputs.output_r2 == "") {
            return inputs.input_trim[1].nameroot + "Tr.fq";
          }
          else {
            return inputs.output_r2;
          }
        }
    default: ""

  quality_cutoff:
    type: string
    default: "6"
    inputBinding:
      position: 7
      prefix: --quality-cutoff

  input_trim:
    type: File[]?
    inputBinding:
      position: 8


stdout: $(inputs.input_trim[0].nameroot)Tr.metrics

outputs:

  output_trim:
    type: File[]?
    outputBinding:
      # glob: "*Tr.fq"
      # If output_r1 and output_r2 were not specified, look for input basename
      glob: |
        ${
          if (inputs.output_r1 == "") {
            return [
              inputs.input_trim[0].nameroot + "Tr.fq",
              inputs.input_trim[1].nameroot + "Tr.fq"
            ];
          }
          else {
            return [
              inputs.output_r1,
              inputs.output_r2
            ];
          }
        }

  output_trim_report:
    type: File
    outputBinding:
      # glob: "*Tr.metrics"
      glob: "*.metrics"
