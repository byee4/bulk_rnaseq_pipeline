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
    #tmpdirMin: 4000
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


baseCommand: [cutadapt2]


arguments: [-f, fastq,
  --match-read-wildcards,
  --times, "2",
  -e, "0.0",
  --quality-cutoff, "6",
  -m, "18",
  -o, $(inputs.input_trim.nameroot)Tr.fqgz
  ]


inputs:

  input_trim_overlap_length:
    type: string
    default: "5"
    inputBinding:
      position: -3
      prefix: -O
    #  loadContents: True
    #  valueFrom: this.contents
    label: ""
    doc: ""

  input_trim:
    type: File
    inputBinding:
      position: 2

  input_trim_b_adapters:
    type: File
    inputBinding:
      position: 1
      prefix: "-b file:"
      separate: false


stdout: $(inputs.input_trim.nameroot)Tr.metrics

outputs:

  output_trim:
    type: File
    outputBinding:
      glob: $(inputs.input_trim.nameroot)Tr.fqgz

  output_trim_report:
    type: File
    outputBinding:
      glob: $(inputs.input_trim.nameroot)Tr.metrics
