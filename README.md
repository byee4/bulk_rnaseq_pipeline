# bulk_rnaseq_pipeline
RNA SEQ processing pipeline written with CWL

- FASTQC
```
fastqc '/projects/ps-yeolab/seqdata/20160606_stefan_parp13/SAMPLE.fastq.gz  \
-o /home/bay001/projects/parp13_ago2_20160606/analysis/parp13_ago2_v3'  > /DIRECTORY/SAMPLE.dummy_fastqc
- cutadapt -f fastq '--match-read-wildcards  \
--times 2  \
-e 0.0  \
-O 5  \
--quality-cutoff 6  \
-m 18  \
-b TCGTATGCCGTCTTCTGCTTG -b ATCTCGTATGCCGTCTTCTGCTTG -b CGACAGGTTCAGAGTTCTACAGTCCGACGATC -b GATCGGAAGAGCACACGTCTGAACTCCAGTCAC -b AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA -b TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT  \
-o /DIRECTORY/SAMPLE.polyATrim.adapterTrim.fastq  \
/projects/ps-yeolab/seqdata/20160606_stefan_parp13/SAMPLE.fastq.gz'  > SAMPLE.polyATrim.adapterTrim.metrics
```
- STAR
```
 STAR \
--runMode alignReads  \
--runThreadN 16  \
--genomeDir /projects/ps-yeolab/genomes/RepBase18.05.fasta/STAR_fixed  \
--genomeLoad LoadAndRemove  \
--readFilesIn /DIRECTORY/SAMPLE.polyATrim.adapterTrim.fastq  \
--outSAMunmapped Within  \
--outFilterMultimapNmax 10  \
--outFilterMultimapScoreRange 1  \
--outFileNamePrefix /DIRECTORY/SAMPLE.polyATrim.adapterTrim.rep.bam  \
--outSAMattributes All  \
--outSAMstrandField intronMotif  \
--outStd BAM_Unsorted  \
--outSAMtype BAM Unsorted  \
--outFilterType BySJout  \
--outReadsUnmapped Fastx  \
--outFilterScoreMin 10  \
--outSAMattrRGline ID:foo' > /DIRECTORY/SAMPLE.polyATrim.adapterTrim.rep.bam
- samtools view /DIRECTORY/SAMPLE.polyATrim.adapterTrim.rep.bam | count_aligned_from_sam.py > /DIRECTORY/SAMPLE.polyATrim.adapterTrim.rmRep.metrics
- fastqc '/DIRECTORY/SAMPLE.polyATrim.adapterTrim.rep.bamUnmapped.out.mate1  \
-o /home/bay001/projects/parp13_ago2_20160606/analysis/parp13_ago2_v3'  > /DIRECTORY/SAMPLE.polyATrim.adapterTrim.rep.bamUnmapped.out.mate1.dummy_fastqc
```
- STAR
```
STAR \
--runMode alignReads  \
--runThreadN 16  \
--genomeDir /projects/ps-yeolab/genomes/hg19/star_sjdb  \
--genomeLoad LoadAndRemove  \
--readFilesIn /DIRECTORY/SAMPLE.polyATrim.adapterTrim.rep.bamUnmapped.out.mate1  \
--outSAMunmapped Within  \
--outFilterMultimapNmax 10  \
--outFilterMultimapScoreRange 1  \
--outFileNamePrefix /DIRECTORY/SAMPLE.polyATrim.adapterTrim.rmRep.bam  \
--outSAMattributes All  \
--outSAMstrandField intronMotif  \
--outStd BAM_Unsorted  \
--outSAMtype BAM Unsorted  \
--outFilterType BySJout  \
--outReadsUnmapped Fastx  \
--outFilterScoreMin 10  \
--outSAMattrRGline ID:foo' > /DIRECTORY/SAMPLE.polyATrim.adapterTrim.rmRep.bam
```
