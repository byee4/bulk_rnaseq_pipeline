# bulk_rnaseq_pipeline
Simple RNA SEQ processing pipeline written in [CWL](https://www.commonwl.org/).

By default uses/accepts TruSeq reverse stranded reads. If stranded, modify the ```direction``` flag to be ```f```, which will only affect the last steps (bigwig file creation). Unstranded reads may also be used, however as bigwig files are split by strand, these may not be useful.

# Steps:
- Using rep1 fastq files from encodeproject, found [here](https://www.encodeproject.org/experiments/ENCSR767LLP/)

### FastQC
```bash
fastqc -t 2 --extract -k 7 -o . ENCFF201PEI.fastq.gz
fastqc -t 2 --extract -k 7 -o . ENCFF508QNI.fastq.gz
```

### Trim common adapters and polyA/T with cutadapt
```bash
cutadapt -O 5 -f fastq --match-read-wildcards --times 2 -e 0.0 --quality-cutoff 6 -m 18 -o ENCFF201PEI.fastqTr.fq -p ENCFF508QNI.fastqTr.fq -b TCGTATGCCGTCTTCTGCTTG -b ATCTCGTATGCCGTCTTCTGCTTG -b CGACAGGTTCAGAGTTCTACAGTCCGACGATC -b GATCGGAAGAGCACACGTCTGAACTCCAGTCAC -b AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA -b TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT ENCFF201PEI.fastq.gz ENCFF508QNI.fastq.gz
```

### Sort trimmed fastq by name and gzip
```bash
fastq-sort --id ENCFF201PEI.fastqTr.fq
fastq-sort --id ENCFF508QNI.fastqTr.fq
```

### Map to repeat element index and filter with STAR
- Note that R1 (ENCFF201PEI) and R2 (ENCFF508QNI) names are transformed such that each dataset will now be referred by its R1 (ie. ENCFF201PEI) name only.

```bash
STAR --alignEndsType EndToEnd --genomeDir homo_sapiens_repbase_v2 --genomeLoad NoSharedMemory --outBAMcompression 10 --outFileNamePrefix ENCFF201PEI.fastqTr.sorted.STAR --outFilterMultimapNmax 10 --outFilterMultimapScoreRange 1 --outFilterScoreMin 10 --outFilterType BySJout --outReadsUnmapped Fastx --outSAMattrRGline ID:foo --outSAMattributes All --outSAMmode Full --outSAMtype BAM Unsorted --outSAMunmapped Within --outStd Log --readFilesIn ENCFF201PEI.fastqTr.sorted.fq ENCFF508QNI.fastqTr.sorted.fq --runMode alignReads --runThreadN 8
```

### Sort surviving reads
```bash
fastq-sort --id ENCFF201PEI.fastqTr.sorted.STARUnmapped.out.mate1 > read1.fastqTr.sorted.STARUnmapped.out.sorted.fq
fastq-sort --id ENCFF201PEI.fastqTr.sorted.STARUnmapped.out.mate2 > read2.fastqTr.sorted.STARUnmapped.out.sorted.fq
```

### Map to genome index with STAR
- **Note**: If using this CWL pipeline, you might notice the readFilesIn Read1 and Read2 files having the same name. This is due to the previous alignment step re-naming according to a singular prefix, which in our case is based on Read1. 
```bash
STAR --alignEndsType EndToEnd --genomeDir star_2_4_0i_gencode19_sjdb --genomeLoad NoSharedMemory --outBAMcompression 10 --outFileNamePrefix ENCFF201PEI.fastqTr.sorted.STARUnmapped.out.sorted.STAR --outFilterMultimapNmax 10 --outFilterMultimapScoreRange 1 --outFilterScoreMin 10 --outFilterType BySJout --outReadsUnmapped Fastx --outSAMattrRGline ID:foo --outSAMattributes All --outSAMmode Full --outSAMtype BAM Unsorted --outSAMunmapped Within --outStd Log --readFilesIn read1.fastqTr.sorted.STARUnmapped.out.sorted.fq read2.fastqTr.sorted.STARUnmapped.out.sorted.fq --runMode alignReads --runThreadN 8
```

### Gzip to condense final outputs
```bash
gzip -c ENCFF201PEI.fastqTr.sorted.fq
gzip -c ENCFF508QNI.fastqTr.sorted.fq
gzip -c ENCFF201PEI.fastqTr.sorted.STARUnmapped.out.sorted.fq
gzip -c ENCFF508QNI.fastqTr.sorted.STARUnmapped.out.sorted.fq
```

### Sort and index genome-mapped BAM files
```bash
samtools sort -o ENCFF201PEI.fastqTr.sorted.STARUnmapped.out.sorted.STARAligned.out.sorted.bam ENCFF201PEI.fastqTr.sorted.STARUnmapped.out.sorted.STARAligned.out.bam

samtools index ENCFF201PEI.fastqTr.sorted.STARUnmapped.out.sorted.STARAligned.out.sorted.bam ENCFF201PEI.fastqTr.sorted.STARUnmapped.out.sorted.STARAligned.out.sorted.bam.bai
```

### Make stranded RPM-normalized bigwig files
```bash
makebigwigfiles --bw_pos ENCFF201PEI.fastqTr.sorted.STARUnmapped.out.sorted.STARAligned.out.sorted.norm.pos.bw --bw_neg ENCFF201PEI.fastqTr.sorted.STARUnmapped.out.sorted.STARAligned.out.sorted.norm.neg.bw --bam ENCFF201PEI.fastqTr.sorted.STARUnmapped.out.sorted.STARAligned.out.sorted.bam
```

### makebigwigfiles (found [here](https://github.com/yeolab/makebigwigfiles)) is itself a wrapper for the following commands:
```bash
genomeCoverageBed -ibam input_bam -bg -strand + (or -, flipped if reverse strand) -scale 1 / (float(samfile.mapped) / 1000000) -g hg19.chrom.sizes -du
bedSort in_bed_graph out_bed_graph
bedGraphToBigWig in_bed_graph hg19.chrom.sizes out_big_wig
```

# Notes:
- To run on one node, sequentially, use [cwlref-runner](https://pypi.org/project/cwlref-runner/). 
- To run in parallel, use [TOIL](https://toil.readthedocs.io/en/latest/index.html). Since our cluster (TSCC) currently uses PBS/Torque, we've developed wrappers (```wf/```) that are configured to work for TOIL on Torque:
    - export TOIL_TORQUE_ARGS="-l walltime=1:00:00 -q condo"
    - cwltoil --jobStore ./tmp/ --batchSystem Torque ~/projects/codebase/bulk_rnaseq_pipeline/cwl/wf_rnaseqcore_se_cwltorq.cwl wf_rnaseqscatter_se.yaml
