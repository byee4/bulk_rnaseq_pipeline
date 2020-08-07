#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 8000
    tmpdirMin: 4000
    outdirMin: 4000

baseCommand: [fastq-dump, --origfmt]

inputs:

  gzip:
    default: true
    type: boolean
    inputBinding:
      position: 1
      prefix: --gzip
      
  split:
    default: true
    type: boolean
    inputBinding:
      position: 2
      prefix: --split-files
      
  sra:
    type: File
    inputBinding:
      position: 3
    label: ""
    doc: ""

outputs:

  output_fastq:
    type: File[]?
    outputBinding:
      glob: "*.gz"
