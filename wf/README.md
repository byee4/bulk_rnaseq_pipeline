This folder contains work-in-progress "metadata runners". The idea is to better
facilitate switching between cwlref-runner (local), cwltoil (local), cwltoil (torque). 

All singleNode variations are identical to their prefixed counterparts, with the exception that these 
scripts use cwlref-runner instead of TOIL and is designed to run each step in serial as opposed to in 
paralle.

RNASEQ_pairedend - Runs the standard RNASEQ paired end stranded pipeline. Wraps wf_rnaseqscatter_pe.cwl
RNASEQ_singleend - Runs the standard RNASEQ single end stranded pipeline. Wraps wf_rnaseqscatter_se.cwl
rnaseq-0.0.4-pe-sra-runner - Variation of RNASEQ_pairedend, which parses an SRR accession instead of using fastq files to map. Wraps wf_rnaseqscatter_pe_sra.cwl
rnaseq-0.0.4-se-sra-runner - Variation of RNASEQ_singleend, which parses an SRR accession instead of using fastq files to map. Wraps wf_rnaseqscatter_se_sra.cwl
rnaseq-0.0.4-pe-cred-sra-runner - Variation of rnaseq-0.0.4-pe-sra-runner, which skips repeat mapping (due to potentially violating RepBase license). Wraps wf_rnaseqcore_pe_cred_sra.cwl
rnaseq-0.0.4-se-cred-sra-runner - Variation of rnaseq-0.0.4-se-sra-runner, which skips repeat mapping (due to potentially violating RepBase license). Wraps wf_rnaseqcore_se_cred_sra.cwl
rnaseq-0.0.4-se-cred-sra-headerumi-runner - Variation of rnaseq-0.0.4-se-cred-sra-runner, which runs an additional upstream step that searches for and extracts an existing UMI (embedded in the read header) for use with [umi_tools](https://github.com/CGATOxford/UMI-tools)