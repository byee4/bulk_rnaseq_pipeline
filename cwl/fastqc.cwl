#!/usr/bin/env cwltool

cwlVersion: v1.0

class: CommandLineTool


requirements:
  - class: ResourceRequirement
    coresMin: 2

baseCommand: [fastqc, -t, "2", --extract, -k, "7",]

#$namespaces:
#  ex: http://example.com/

#hints:

#  - class: ex:PackageRequirement
#    packages:
#      - name: openjdk-7-jre-headless

#  - class: ex:ScriptRequirement
#    scriptlines:
#      - "#!/bin/bash"

inputs:

  output_postfix:
    type: string
    default: .
    inputBinding:
      position: 1
      prefix: -o
    label: ""
    doc: ""

  reads:
    type: File
    inputBinding:
      position: 1
    label: ""
    doc: ""

outputs:

  output_qc_report:
    type: File
    outputBinding:
      glob: "*/fastqc_report.html"

  output_qc_stats:
    type: File
    outputBinding:
      glob: "*/fastqc_data.txt"
