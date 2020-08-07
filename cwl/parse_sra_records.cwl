#!/usr/bin/env cwltool

### parses a record object into two reads (read1 and read2) ###

cwlVersion: v1.0
class: ExpressionTool

requirements:
  - class: InlineJavascriptRequirement

inputs:

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
          
outputs:

  accession:
    type: string
    
expression: |
   ${
      return {
        'accession': inputs.sample.sample_id
      }
    }

doc: "parses a record object into two reads (read1 and read2)"