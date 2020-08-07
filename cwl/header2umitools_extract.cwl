#!/usr/bin/env cwltool

cwlVersion: v1.0
class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 2
  - class: InlineJavascriptRequirement

baseCommand: [header2umitools.py]

inputs:

  input:
     type: File
     inputBinding:
       position: 1
       prefix: --input

  output_file:
    type: string
    inputBinding:
      position: 2
      prefix: --output
      valueFrom: |
        ${
          if (inputs.output_file == "") {
            return inputs.input.nameroot + ".umi.fastq.gz";
          }
          else {
            return inputs.output_file;
          }
        }
    default: ""
  
  start0base:
    type: int
    inputBinding:
      position: 3
      prefix: --start0base
  
  end:
    type: int
    inputBinding:
      position: 4
      prefix: --end
      
outputs:

  output:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.output_file == "") {
            return inputs.input.nameroot + ".umi.fastq.gz";
          }
          else {
            return inputs.output_file;
          }
        }
