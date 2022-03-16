#!/bin/bash

# Read in Results folder to operate in (first argument) and the name of the original pdb file to compare, which is placed in the "Originals" folder (second argument)
results_folder=$1 	 #example: Rec_Spike_Selection
new_name=$2		 #example: Rec_SPike_FirstDesign
path_to_binac_folder=$3 #example: Terra_Incognita/Chymo1.1
folder=PrepFirstDesign
old_step=Selection
next_step=FirstDesign
destiny_folder=03_FirstDesign

# move into results folder which contains the mutated pdb files
cd ${results_folder}

# create subfolders for the post process files
mkdir files_pdb
mkdir files_score


# move pdb and score files in subfolders
mv *.pdb files_pdb/.
mv *.sc files_score/.

# create a "files" array containing all filenames that end with .pdb (all mutated files including the original pdb)
shopt -s nullglob
cd files_pdb
pdb_files=(*.pdb)
cd ..

# loop over all pdb files
for pdb_file in ${pdb_files[@]}
do

# create new filename string without .pdb extension
pdb_filename=$(echo "${pdb_file}" | cut -f 1 -d '.')

# transform original pdb file into fasta sequence file with the new name and write them in the "files_fasta" subfolder
echo ${pdb_file}

done

# Unite all score files into a single score file
cat files_score/*score_*.sc > ${results_folder}_scores.sc

# Remove all header/description lines --> only metrics remain
sed -i '/^SEQUENCE:/d' ${results_folder}_scores.sc
sed -i '/^SCORE: total_score/d' ${results_folder}_scores.sc

# read all desired scores and filenames from the united score file
PostDock_scores=($(awk '{print $23}' ./${results_folder}_scores.sc))
echo "PostDock"
echo ${PostDock_scores[@]}
PostRelax1_scores=($(awk '{print $24}' ./${results_folder}_scores.sc))
echo "PostRelax1"
echo ${PostRelax1_scores[@]}
rmsd=($(awk '{print $35}' ./${results_folder}_scores.sc))
echo "RMSD"
echo ${rmsd[@]}
total_energy_final=($(awk '{print $37}' ./${results_folder}_scores.sc))
echo "total_energy_final"
echo ${total_energy_final[@]}
total_energy_starting=($(awk '{print $38}' ./${results_folder}_scores.sc))
echo "Total Energy Starting"
echo ${total_energy_starting[@]}
Environment=($(awk '{print $40}' ./${results_folder}_scores.sc))
echo "Environment"
echo ${Environment[@]}
Pose_names=($(awk '{print $41}' ./${results_folder}_scores.sc))
echo "Pose_names"
echo ${Pose_names[@]}


# Print output csv

printf "Number;Pose;PostDock;PostRelax1;RMSD;TotalEnergy_Starting;TotalEnergy_Final;Environment\n" > ${results_folder}_results.csv

for ((i = 0 ; i < ${#Pose_names[@]} ; i++ ));
do
printf "${i};${Pose_names[$i]};${PostDock_scores[$i]};${PostRelax1_scores[$i]};${rmsd[$i]};${total_energy_starting[$i]};${total_energy_final[$i]};${Environment[$i]}\n" >> ${results_folder}_results.csv
done

# sort 20 best results by PostRelax1
csvsort -c PostRelax1 ${results_folder}_results.csv | head -n 21 > best_${results_folder}1.csv

tr "\\[,]" ";" <best_${results_folder}1.csv >best_${results_folder}.csv && rm best_${results_folder}1.csv

cd ..
mkdir ${folder}
cd ./${results_folder}

# copy best pdb to new folder

a=($(awk -F "\"*;\"*" '{print $2}' ./best_${results_folder}.csv))

echo ${a[@]}

for ((i = 0 ; i < ${#a[@]} ; i++ ));
do
cp files_pdb/${a[$i]}.pdb ../${folder}

done


cd ../PrepFirstDesign

pymol *.pdb


#rename files

mkdir originals

cp *.pdb ./originals


# rename files and create excel-sheet
STRING=$new_name rename -v '$_ = sprintf "\Q$ENV{STRING}\E_%d.pdb", ++$::count' *.pdb >renamed1.csv 

tr "\\[ ]" ";" <renamed1.csv >renamed2.csv && rm renamed1.csv | cut -d ";" -f2-3 --complement renamed2.csv > 2_renamed_for_${next_step}.csv && rm renamed2.csv | sed -i 1i"From_${old_step};To_${next_step}" 2_renamed_for_${next_step}.csv

mkdir ../../renamed_files

cp ./2_renamed_for_${next_step}.csv ../../renamed_files

cd ..
mv ./${folder} ../${destiny_folder}/.

cd ../${destiny_folder}/${folder}
scp ./*.pdb st_st161600@login02.binac.uni-tuebingen.de:/beegfs/work/workspace/ws/st_st161600-workspace1-0/${path_to_binac_folder}/03_FirstDesign/.










