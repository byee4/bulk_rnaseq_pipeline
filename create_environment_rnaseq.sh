#!/bin/bash

conda create -y --name rna-seq python=2.7;
source activate rna-seq;
conda install -y -c bioconda samtools \
bedtools \
pysam \
pybedtools \
pybigwig \
fastqc \
star \
cutadapt \
rna-seqc \
picard;

conda install -y -c anaconda cython setuptools pytest;
pip install --ignore-installed six;
pip install cwlref-runner;

cd ~/bin;
git clone https://github.com/YeoLab/qtools
cd qtools;
pip install .

cd ~/bin;
git clone https://github.com/yeolab/gscripts;
cd gscripts;
python setup.py install;

# rm /home/bay001/anaconda2/envs/brian2/lib/libgomp.so.1
export LD_LIBRARY_PATH=/opt/gnu/gcc/lib64/:$LD_LIBRARY_PATH;

# PATH variables
export PATH=/var/cfengine/bin:$PATH;
export PATH=/opt/pdsh/bin:$PATH;
export PATH=/opt/maui/bin:$PATH;
export PATH=/opt/sdsc/bin:/opt/sdsc/sbin:$PATH;
export PATH=/opt/rocks/bin:/opt/rocks/sbin:$PATH;
export PATH=/opt/torque/bin:/opt/torque/sbin:$PATH;
export PATH=/opt/gold/bin:/opt/gold/sbin:$PATH;
export PATH=/opt/openmpi/intel/ib/bin:$PATH;
export PATH=/opt/intel/composer_xe_2013_sp1.2.144/bin/intel64:$PATH;
export PATH=/opt/intel/composer_xe_2013_sp1.2.144/mpirt/bin/intel64:$PATH;
export PATH=/opt/intel/composer_xe_2013_sp1.2.144/debugger/gdb/intel64_mic/bin:$PATH;
export PATH=/usr/java/latest/bin:$PATH;
export PATH=/usr/lib64/qt-3.3/bin:$PATH;
export PATH=/bin:/sbin:$PATH;
export PATH=/usr/bin:/usr/sbin:$PATH;
export PATH=/usr/local/bin:/usr/local/sbin:$PATH;

# add this repo to path
export PATH=${PWD}/bin/:$PATH;
export PATH=${PWD}/cwl/:$PATH;
export PATH=${PWD}/members/:$PATH;
export PATH=${PWD}/members/map:$PATH;
export PATH=${PWD}/members/trim:$PATH;
export PATH=${PWD}/members/bin:$PATH;
