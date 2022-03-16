#! /bin/bash

WorkDir=$(pwd)
echo ${WorkDir}
RosettaDir="/home/st/st_st/st_st161600/rosetta_src_2021.16.61629_bundle/main/source/bin/rosetta_scripts.default.linuxgccrelease"

# read input values for replicates and jobs
replicates=$1
jobs=$2
file=$3
protocol=$4
folder=$5
queue=$6
time=$7
ram=$8

mkdir ${folder}
mkdir ${folder}/LOGS
mkdir ${folder}/PBS
mkdir ${folder}/Input

cp ${WorkDir}/${file} ${folder}/Input/.
cp ${WorkDir}/${protocol} ${folder}/Input/.
cp ${WorkDir}/Parallel_Start.sh ${folder}/Input/.

reps_per_job=$((${replicates}/${jobs}))

for (( j=1; j<=${jobs}; j++ ))
do

rm ${folder}/PBS/${folder}_${j}_pbs.sh
cat <<EOT >> ${folder}/PBS/${folder}_${j}_pbs.sh
#PBS -l nodes=1:ppn=1
#PBS -l walltime=${time}
#PBS -l mem=${ram}
#PBS -S /bin/bash
#PBS -N ${folder}_${j}
#PBS -j oe
#PBS -o ${WorkDir}/${folder}/LOGS/LOG_${folder}_${j}
#PBS -f ${WorkDir}/${folder}/LOGS/Feedback_${folder}_${j}

$RosettaDir \
-s ${WorkDir}/${file} \
-parser:protocol ${WorkDir}/${protocol} \
-nstruct ${reps_per_job} \
-partners B_A \
-spin \
-dock_pert 3 8 \
-ex1 \
-ex2 \
-jd2:failed_job_exception false \
-jd2:ntrials 100 \
-ignore_unrecognized_res \
-out:path:all ${WorkDir}/${folder} \
-out:suffix _${j}
EOT

qsub -q ${queue} ${folder}/PBS/${folder}_${j}_pbs.sh

done
