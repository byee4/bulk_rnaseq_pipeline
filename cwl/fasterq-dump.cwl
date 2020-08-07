#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 6
    ramMin: 8000
    tmpdirMin: 4000
    outdirMin: 4000

baseCommand: [fasterq-dump, -e, "6"]

inputs:

  accession:
    type: string
    inputBinding:
      position: 1
    label: ""
    doc: ""
  
  tmp_dir:
    default: "/oasis/tscc/scratch/bay001/NCRCRG/"
    type: string
    inputBinding:
      position: 2
      prefix: --temp

outputs:

  output_fastq:
    type: File[]
    outputBinding:
      glob: "*.fastq"
