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

#$namespaces:
#  ex: http://example.com/

#hints:
#  - class: ex:PackageRequirement
#    packages:
#      - name: bedtools
#      - name: samtools
#      - name: pysam
#        package_manager: pip
#        version: 0.8.3
#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"
#      - "~/miniconda/bin/conda install argparse"
#      - ""



baseCommand: [makebigwigfiles]
#baseCommand: [singularityexec, eclip.img, /projects/ps-yeolab/software/makebigwigfiles-0.0.1/bin/make_bigwig_files.py]


arguments: [
  --bw_pos,
  $(inputs.bam.nameroot).norm.pos.bw,
  --bw_neg,
  $(inputs.bam.nameroot).norm.neg.bw
  ]

inputs:

  bam:
     type: File
     # format: http://edamontology.org/format_2572
     inputBinding:
       position: 1
       prefix: --bam
     #secondaryFiles:
     #  - ".bai"

  #bai:
  #  type: File
  #  format: http://edamontology.org/format_3327
  #  inputBinding:
  #    position: 2
  #    prefix: --bai

  chromsizes:
    type: File
    inputBinding:
      position: 3
      prefix: --genome

outputs:

  posbw:
    type: File
    # format: http://edamontology.org/format_3006
    outputBinding:
      glob: $(inputs.bam.nameroot).norm.pos.bw

  negbw:
    type: File
    # format: http://edamontology.org/format_3006
    outputBinding:
      glob: $(inputs.bam.nameroot).norm.neg.bw

  #posbg:
  #  type: File
  #  outputBinding:
  #    glob: $(inputs.bam.nameroot).No.pos.bg
  #negbg:
  #  type: File
  #  outputBinding:
  #    glob: $(inputs.bam.nameroot).No.neg.bg
  #noposbg:
  #  type: File
  #  outputBinding:
  #    glob: $(inputs.bam.nameroot).No.pos.bg
  #nonegbg:
  #  type: File
  #  outputBinding:
  #    glob: $(inputs.bam.nameroot).No.neg.bg
  #nonegtbg:
  #  type: File
  #  outputBinding:
  #    glob: $(inputs.bam.nameroot).No.negt.t.bg
