#!/usr/bin/env cwltool

### parses a record object into two reads (read1 and read2) ###

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

  read1:
    type: File
  read2:
    type: File?

expression: |
   ${
      return {
        'read1': inputs.read.read1,
        'read2': inputs.read.read2
      }
    }

doc: "parses a record object into two reads (read1 and read2)"