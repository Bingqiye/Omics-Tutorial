#!/bin/bash

#SBATCH --job-name=example
#SBATCH --partition=work
#SBATCH -n 1 
#SBATCH --ntasks-per-node=1
#SBATCH --output=%j.out
#SBATCH --error=%j.err

source /WORK/app/toolshs/cnmodule.sh
module load conda
source activate humann
#Fastp
for j in `cat /WORK2/sysu_mxia_5/Bingqi/Microbiome/list/test7.csv`;do
  {
  cd /WORK2/sysu_mxia_5/Bingqi/Microbiome/clean_data/
  mkdir ${j}
  fastp -i /WORK2/sysu_mxia_5/Bingqi/Microbiome/rawdata/control/${j}/${j}_1.fastq.gz -o /WORK2/sysu_mxia_5/Bingqi/Microbiome/clean_data/${j}/${j}_1.fastq.gz -I /WORK2/sysu_mxia_5/Bingqi/Microbiome/rawdata/control/${j}/${j}_2.fastq.gz -O /WORK2/sysu_mxia_5/Bingqi/Microbiome/clean_data/${j}/${j}_2.fastq.gz --html /WORK2/sysu_mxia_5/Bingqi/Microbiome/clean_data/${j}/${j}.html --json /WORK2/sysu_mxia_5/Bingqi/Microbiome/clean_data/${j}/${j}.json
    }
done
#Bowtie2
for j in `cat /WORK2/sysu_mxia_5/Bingqi/Microbiome/list/test7.csv`;do
  {
  cd /WORK2/sysu_mxia_5/Bingqi/Microbiome/unalign_data/
  mkdir ${j}
  bowtie2 -p 15 -x /WORK/sysu_mxia_5/database/GRCh38/GRCh38 -1 /WORK2/sysu_mxia_5/Bingqi/Microbiome/clean_data/${j}/${j}_1.fastq.gz -2 /WORK2/sysu_mxia_5/Bingqi/Microbiome/clean_data/${j}/${j}_2.fastq.gz -S /WORK2/sysu_mxia_5/Bingqi/Microbiome/unalign_data/${j}/${j}_L1.sam --un-conc /WORK2/sysu_mxia_5/Bingqi/Microbiome/unalign_data/${j}/unalign_${j}.fastq
  cd /WORK2/sysu_mxia_5/Bingqi/Microbiome/unalign_data/${j}
  rm ${j}_L1.sam
    gzip *
    cat unalign_${j}.1.fastq.gz unalign_${j}.2.fastq.gz > unalign_${j}.fastq.gz
    rm -rf unalign_${j}.1.fastq.gz
    rm -rf unalign_${j}.2.fastq.gz
    }
done
#merge and metaphlan
for j in `cat /WORK2/sysu_mxia_5/Bingqi/Microbiome/list/test7.csv`;do
  {
  cd /WORK2/sysu_mxia_5/Bingqi/Microbiome/metaphlan/
  metaphlan /WORK2/sysu_mxia_5/Bingqi/Microbiome/unalign_data/${j}/unalign_${j}.fastq.gz --bowtie2out ${j}.bowtie2.bz2 --nproc 5 --input_type fastq -o ${j}.txt --bowtie2db /WORK/sysu_mxia_5/database/metaphlan_database/ -x mpa_v30_CHOCOPhlAn_201901
  rm ${j}.bowtie2.bz2
  }
done

