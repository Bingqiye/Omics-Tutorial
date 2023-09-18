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
for j in `cat /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/checklist/1.csv`;do
  {
  cd /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/clean_data/
  mkdir ${j}
  fastp -i /WORK/sysu_mxia_5/OGTT/rawdata/${j}/${j}_1.fq.gz -o /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/clean_data/${j}/${j}_1.fq.gz -I /WORK/sysu_mxia_5/OGTT/rawdata/${j}/${j}_2.fq.gz -O /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/clean_data/${j}/${j}_2.fq.gz --html /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/clean_data/${j}/${j}.html --json /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/clean_data/${j}/${j}.json
    }
done
#Bowtie2
for j in `cat /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/checklist/1.csv`;do
  {
  cd /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/unaligned_data/
  mkdir ${j}
  bowtie2 -p 15 -x /WORK/sysu_mxia_5/database/GRCh38/GRCh38 -1 /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/clean_data/${j}/${j}_1.fq.gz -2 /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/clean_data/${j}/${j}_2.fq.gz -S /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/unaligned_data/${j}/${j}_L1.sam --un-conc /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/unaligned_data/${j}/unalign_${j}.fq
  cd /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/unaligned_data/${j}
  rm ${j}_L1.sam
    gzip *
    }
done
#合并
for j in `cat /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/checklist/1.csv`;do
  {
cd /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/unaligned_data/${j}/
cat unalign_${j}.1.fq.gz unalign_${j}.1.fq.gz > ${j}.fq.gz
  }
done
#Humann
for j in `cat /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/checklist/1.csv`;do
  {
  cd /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/humann/
  mkdir ${j}
  cd /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/unaligned_data/${j}/
  humann --input ${j}.fq.gz --output /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/humann/${j} --metaphlan-options="--bowtie2db /WORK/sysu_mxia_5/database/metaphlan_database/"
  cd /WORK/sysu_mxia_5/OGTT/Bingqi_Ye/humann/${j}
  humann_renorm_table --input ${j}_pathabundance.tsv --output ${j}_pathabundance_relab.tsv --units relab --special n
  rm -r ${j}_humann_temp/
  }
done