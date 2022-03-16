#!/bin/bash

# Read in Results folder to operate in (first argument) and the name of the original pdb file to compare, which is placed in the "Originals" folder (second argument)

End=$1
results_folder=$2 #Rec_Spike_SecDock_
new_name=$3 #Rec_Spike_SecDesign
path_to_binac_folder=$4 #example: Terra_Incognita/Chymo1.1
folder=PrepSecDesign
old_step=SecDock
next_step=SecDesign
destiny_folder=05_SecDesign

for ((m=1;m<=$End;m++));
do

results_folder=$2
new_name=$3
path_to_binac_folder=$4 #example: Terra_Incognita/Chymo1.1/03_FirstDesign

results_folder=$results_folder$m

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
cat files_score/score*.sc > ${results_folder}_scores.sc

# Remove all header/description lines --> only metrics remain
sed -i '/^SEQUENCE:/d' ${results_folder}_scores.sc
sed -i '/^SCORE: total_score/d' ${results_folder}_scores.sc

# read all desired scores and filenames from the united score file
# read all desired scores and filenames from the united score file
dG_preDock=($(awk '{print $32}' ./${results_folder}_scores.sc))
echo "dG_preDock"
echo ${dG_preDock[@]}
dG_postDock=($(awk '{print $12}' ./${results_folder}_scores.sc))
echo "dG_postDock"
echo ${dG_postDock[@]}
d_unsatHbond=($(awk '{print $17}' ./${results_folder}_scores.sc))
echo "unsatHbond_PostDock"
echo ${d_unsatHbond[@]}
Packstat=($(awk '{print $22}' ./${results_folder}_scores.sc))
echo "Packstat"
echo ${Packstat[@]}
sc_value_post=($(awk '{print $24}' ./${results_folder}_scores.sc))
echo "sc_value_post"
echo ${sc_value_post[@]}
rmsd=($(awk '{print $88}' ./${results_folder}_scores.sc))
echo "RMSD"
echo ${rmsd[@]}
total_energy_final=($(awk '{print $95}' ./${results_folder}_scores.sc))
echo "Total_Energy_Final"
echo ${total_energy_final[@]}
total_energy_starting=($(awk '{print $96}' ./${results_folder}_scores.sc))
echo "Total_Energy_Starting"
echo ${total_energy_starting[@]}
environment=($(awk '{print $98}' ./${results_folder}_scores.sc))
echo "Environment"
echo ${environment[@]}
Pose_names=($(awk '{print $100}' ./${results_folder}_scores.sc))
echo "Pose_names"
echo ${Pose_names[@]}



# Print output csv

printf "Pose;dG_preDock;dG_postDock;unsatHbond_PostDock;Packstat;sc_value_post;RMSD;Total_Energy_Starting;Total_Energy_Final;Environment\n" > ${results_folder}_results.csv
	
for ((i = 0 ; i < ${#Pose_names[@]} ; i++ ));
do
printf "${Pose_names[$i]};${dG_preDock[$i]};${dG_postDock[$i]};${d_unsatHbond[$i]};${Packstat[$i]};${sc_value_post[$i]};${rmsd[$i]};${total_energy_starting[$i]};${total_energy_final[$i]};${environment[$i]}\n" >> ${results_folder}_results.csv
done

# sort 10 best results by PostRelax1
csvsort -c dG_postDock ${results_folder}_results.csv | head -n 2 > best_${results_folder}1.csv

tr "\\[,]" ";" <best_${results_folder}1.csv >best_${results_folder}.csv && rm best_${results_folder}1.csv

cd ..
mkdir ${folder}
cd ./${results_folder}

# copy best pdb to new folder

a=($(awk -F "\"*;\"*" '{print $1}' ./best_${results_folder}.csv))

echo ${a[@]}

for ((i = 0 ; i < ${#a[@]} ; i++ ));
do
cp files_pdb/${a[$i]}.pdb ../PrepSecDesign

done



#Create Plots in R
Rscript ../hist_with_IA.r "${results_folder}_results.csv" "${results_folder}_i_score.png" "${results_folder}_i_score"

cd ..
mkdir all_i_scores
cp ./${results_folder}/${results_folder}_i_score.png ./all_i_scores/.

done


cd ./${folder}
mkdir originals

cp *.pdb ./originals


# rename files and create excel-sheet
STRING=$new_name rename -v '$_ = sprintf "\Q$ENV{STRING}\E_%d.pdb", ++$::count' *.pdb >renamed1.csv 

tr "\\[ ]" ";" <renamed1.csv >renamed2.csv && rm renamed1.csv | cut -d ";" -f2-3 --complement renamed2.csv > 4_renamed_for_${next_step}.csv && rm renamed2.csv | sed -i 1i"From_${old_step};To_${next_step}" 4_renamed_for_${next_step}.csv

mkdir ../../renamed_files
cp ./4_renamed_for_${next_step}.csv ../../renamed_files

cd ..
mv ./${folder} ../${destiny_folder}/.

cd ../${destiny_folder}/${folder}
scp ./*.pdb st_st161600@login02.binac.uni-tuebingen.de:/beegfs/work/workspace/ws/st_st161600-workspace2-0/${path_to_binac_folder}/05_SecDesign/.



