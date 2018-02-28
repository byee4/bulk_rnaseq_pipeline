#!/usr/bin/env cwltool

###
# parses a record object into two reads (read1 and read2)
###

cwlVersion: v1.0

class: ExpressionTool

requirements:
  - class: InlineJavascriptRequirement

inputs:

  read:
    type:
      type: record
      fields:
        read1:
          type: File
        read2:
          type: File?
        name:
          type: string

outputs:

  name:
    type: string
  repName:
    type: string
  rmRepName:
    type: string
  read1Trim:
    type: string
  read2Trim:
    type: string?
  read1:
    type: File
  read2:
    type: File?

expression: |
   ${
      return {
        'name': inputs.read.name,
        'repName': inputs.read.name + ".rep",
        'rmRepName': inputs.read.name + ".rmRep",
        'read1Trim': inputs.read.name + ".trim.r1.fq",
        'read2Trim': inputs.read.name + ".trim.r2.fq",
        'read1': inputs.read.read1,
        'read2': inputs.read.read2
      }
    }

