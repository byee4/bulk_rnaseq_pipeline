#!/usr/bin/env cwltool

cwlVersion: v1.0
class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 16
    ramMin: 8000
    tmpdirMin: 4000
    outdirMin: 4000


baseCommand: [makebigwigfiles]

arguments: [
  --bw_pos,
  $(inputs.bam.nameroot).norm.pos.bw,
  --bw_neg,
  $(inputs.bam.nameroot).norm.neg.bw
  ]

inputs:

  bam:
     type: File
     inputBinding:
       position: 1
       prefix: --bam

  chromsizes:
    type: File
    inputBinding:
      position: 2
      prefix: --genome
  
  direction:
    type: string
    inputBinding:
      position: 3
      prefix: --direction
      
outputs:

  posbw:
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot).norm.pos.bw

  negbw:
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot).norm.neg.bw
