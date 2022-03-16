#!/bin/bash

#example command-line for more than one file:
# michelle@codebind:/media/sf_Linux/Chymo/Test$ for i in {01..02};do ./post_process_Design.sh Alb1_Chymo1_FirstDocking.pdb Alb1_Chymo1_FirstDesign_$i.pdb Alb1_Chymo1_FirstDesign_$i; done


# Read in Results folder to operate in (first argument) and the name of the original pdb file to compare, which is placed in the "Originals" folder (second argument)

End=$1	#last folder number
starting_file=$2 # Rec_Spike
original_file_name=$3 # Rec_Spike_FirstDesign_
new_name=$4 # Rec_Spike_SecDock
path_to_binac_folder=$5 #example: Terra_Incognita/Chymo1.1/04_SecDock
old_step=FirstDesign
next_step=SecDock
destiny_folder=04_SecDock


for ((m=1;m<=${End};m++));
do

starting_file=$2 # Rec_Spike_Starting.pdb
original_file_name=$3 # Rec_Spike_FirstDesign
new_name=$4 # Rec_Spike_SecDock
path_to_binac_folder=$5 #example: Terra_Incognita/Chymo1.1/04_SecDock
results_folder=${original_file_name}${m}
original_file=${original_file_name}${m}".pdb"

#Create some folders

mkdir Originals
mkdir PostDesign
mkdir Comparisons
mkdir PrepSecDock
mkdir ${results_folder}/${results_folder}
mkdir PrepSecDock/PDB
mkdir PrepSecDock/Fastas
mkdir PrepSecDock/Mutations
# create Originals-Folder with renamed files

cd ./Originals

cp ../../01_Starting/${starting_file} ./${original_file}
cd ..


# Create a variable containing the original filename without the ".pdb" extension
original_filename=$(echo "${original_file}" | cut -f 1 -d '.')

# move into results folder which contains the mutated pdb files
cd ${results_folder}

# create subfolders for the post process files
mkdir files_fasta
mkdir files_pdb
mkdir files_score
mkdir files_fasta_by_score
mkdir files_mutations
mkdir files_alignment

# move pdb and score files in subfolders
mv *.pdb files_pdb/.
mv *.sc files_score/.

# copy original pdb file in the pdb subfolder
cp ../Originals/${original_file} files_pdb/

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
echo ">${pdb_filename}" > files_fasta/${pdb_filename}.fasta
cat files_pdb/${pdb_file} | awk '/ATOM/ && $3 == "CA" && $5 == "A" {print $4}' | tr '\n' ' ' | sed 's/ALA/A/g;s/CYS/C/g;s/ASP/D/g;s/GLU/E/g;s/PHE/F/g;s/GLY/G/g;s/HIS/H/g;s/ILE/I/g;s/LYS/K/g;s/LEU/L/g;s/MET/M/g;s/ASN/N/g;s/PRO/P/g;s/GLN/Q/g;s/ARG/R/g;s/SER/S/g;s/THR/T/g;s/VAL/V/g;s/TRP/W/g;s/TYR/Y/g' | sed 's/ //g' |fold -w 60 >> files_fasta/${pdb_filename}.fasta

# read number of charged amino acids from fasta file
cp files_fasta/${pdb_filename}.fasta files_fasta/${pdb_filename}_temp.fasta
sed -i '1d' files_fasta/${pdb_filename}_temp.fasta
arginines=$(grep -Fo 'R' files_fasta/${pdb_filename}_temp.fasta | wc -l)
lysines=$(grep -Fo 'K' files_fasta/${pdb_filename}_temp.fasta | wc -l)
aspartics=$(grep -Fo 'D' files_fasta/${pdb_filename}_temp.fasta | wc -l)
glutamics=$(grep -Fo 'E' files_fasta/${pdb_filename}_temp.fasta | wc -l)
charge+=($((${arginines}+${lysines}-${aspartics}-${glutamics})))
echo "Arginies: ${arginines}"
echo "lysines: ${lysines}"
echo "aspartics: ${aspartics}"
echo "glutamics: ${glutamics}"
echo "charge: ${charge[@]}"
rm files_fasta/${pdb_filename}_temp.fasta
done
	
# Unite all score files into a single score file
cat files_score/score*.sc > ${results_folder}_scores.sc
	
# Remove all header/description lines --> only metrics remain
sed -i '/^SEQUENCE:/d' ${results_folder}_scores.sc
sed -i '/^SCORE: total_score/d' ${results_folder}_scores.sc

# read all desired scores and filenames from the united score file
dG_preDesign=($(awk '{print $26}' ./${results_folder}_scores.sc))
echo "dG_PreDesign"
echo ${dG_preDesign[@]}
dG_postDesign=($(awk '{print $6}' ./${results_folder}_scores.sc))
echo "dG_PostDesign"
echo ${dG_postDesign[@]}
i_score=($(awk '{print $66}' ./${results_folder}_scores.sc))
echo "i_score"
echo ${i_score[@]}
d_unsatHbond=($(awk '{print $11}' ./${results_folder}_scores.sc))
echo "unsatHbond_PostDesign"
echo ${d_unsatHbond[@]}
Packstat=($(awk '{print $16}' ./${results_folder}_scores.sc))
echo "Packstat"
echo ${Packstat[@]}
sc_value_post=($(awk '{print $18}' ./${results_folder}_scores.sc))
echo "sc_value_post"
echo ${sc_value_post[@]}
SASA=($(awk '{print $9}' ./${results_folder}_scores.sc))
echo "dsSASA_Int"
echo ${SASA[@]}
rmsd=($(awk '{print $76}' ./${results_folder}_scores.sc))
echo "RMSD"
echo ${rmsd[@]}
total_energy_final=($(awk '{print $83}' ./${results_folder}_scores.sc))
echo "Total_Energy_Final"
echo ${total_energy_final[@]}
total_energy_starting=($(awk '{print $84}' ./${results_folder}_scores.sc))
echo "Total_Energy_Starting"
echo ${total_energy_starting[@]}
positions_A=($(awk '{print $87}' ./${results_folder}_scores.sc))
echo "positions_A"
echo ${positions_A[@]}
environment=($(awk '{print $86}' ./${results_folder}_scores.sc))
echo "Environment"
echo ${environment[@]}
Pose_names=($(awk '{print $88}' ./${results_folder}_scores.sc))
echo "Pose_names"
echo ${Pose_names[@]}


# make a copy of every fasta file with the respective interface score in the filename and save it in the respective subfolder
for ((i = 0 ; i < ${#Pose_names[@]} ; i++ ));
do
cp files_fasta/${Pose_names[$i]}.fasta files_fasta_by_score/${dG_postDesign_scores[$i]}_${Pose_names[$i]}.fasta
scorename="${dG_postDesign_scores[$i]}_${pdb_filename}"
sed -i "1s/${pdb_filename}/${scorename}/" files_fasta_by_score/${dG_postDesign_scores[$i]}_$	{Pose_names[$i]}.fasta
done

# copy the fasta file of the original Pose in the fasta_by_score folder
cp files_fasta/${original_filename}.fasta files_fasta_by_score/

#Unite all fasta Sequences in one file
awk 1 files_fasta_by_score/*.fasta > ${results_folder}_sequences.fasta

# Compare all designed sequences with the original sequence using diffseq from EMBOSS
cd files_fasta
shopt -s nullglob
fasta_files=(${original_filename}_*.fasta)
cd ..

for fasta_file in ${fasta_files[@]}
do

fasta_filename=$(echo "${fasta_file}" | cut -f 1 -d '.')

diffseq \
-asequence files_fasta/${original_filename}.fasta \
-bsequence files_fasta/${fasta_file} \
-wordsize 2 \
-outfile files_mutations/${fasta_filename}_allmut.txt \
-aoutfeat files_mutations/${fasta_filename}_mut.txt \
-boutfeat files_mutations/${fasta_filename}_b_mut.txt \
-globaldifferences true \
-sprotein1 true \
-sprotein2 true

rm files_mutations/${fasta_filename}_allmut.txt
rm files_mutations/${fasta_filename}_b_mut.txt
	
needle \
-asequence files_fasta/${original_filename}.fasta \
-bsequence files_fasta/${fasta_file} \
-gapopen 100 \
-gapextend 10 \
-outfile files_mutations/${fasta_filename}_needle.txt
	
echo $(sed -e '1,30d' < files_mutations/${fasta_filename}_needle.txt) > files_mutations/${fasta_filename}_needle_temp.txt
points=$(grep -Fo '.' files_mutations/${fasta_filename}_needle_temp.txt | wc -l)
d_points=$(grep -Fo ':' files_mutations/${fasta_filename}_needle_temp.txt | wc -l)
mutations+=($((${d_points}+${points})))
rm files_mutations/${fasta_filename}_needle_temp.txt
done


# do multiple sequence alignement using clustalw
directory=$(pwd)
clustalw \
-infile=${directory}/${results_folder}_sequences.fasta \
-align \
-outfile=${directory}/files_alignment/${results_folder}_alignment.txt \
-tree \
-newtree=${directory}/files_alignment/${results_folder}_guidetree.txt \
-type=PROTEIN

rm ${results_folder}_sequences.fasta

# Print output csv

printf "Pose;dG_preDesign;dG_postDesign;unsatHbond_postDesign;I_Score;Packstat;sc_value_post;Mutations;Charge;SASA_Int;RMSD;Total_Energy_Starting;Total_Energy_Final;Environment;Positions_A\n" > ${results_folder}_results.csv
	
for ((i = 0 ; i < ${#Pose_names[@]} ; i++ ));
do
printf "${Pose_names[$i]};${dG_preDesign[$i]};${dG_postDesign[$i]};${i_score[$i]};${d_unsatHbond[$i]};${Packstat[$i]};${sc_value_post[$i]};${mutations[$i]};${charge[$i]};${SASA[$i]};${rmsd[$i]};${total_energy_starting[$i]};${total_energy_final[$i]};${environment[$i]};${positions_A[$i]}\n" >> ${results_folder}_results.csv
done

#sort 5 best results by PostRelax2 and than by Mutaions
csvsort -c dG_postDesign ${results_folder}_results.csv | head -n 6 > best_${results_folder}_PR2.csv
csvsort -c Mutations best_${results_folder}_PR2.csv |head -n 2 > best_${results_folder}1.csv && rm best_${results_folder}_PR2.csv


# Create plots in R

Rscript ../analysis_IA.r "${results_folder}_results.csv" "${results_folder}_PreDesign.png" "${results_folder}_PostDesign.png" "${results_folder}_ScoreCorr.png" "${results_folder}_Mutations.png" "${results_folder}_I_sc.png" "${results_folder}_comparison_Pre_Post_Design.png" "${results_folder}_Pre_Design" "${results_folder}_Post_Design" "${results_folder}_Score_Correlation" "${results_folder}_Mutations" "${results_folder}" "${results_folder}_0.25_Quartil1.csv"

tr "\\[,]" ";" <${results_folder}_0.25_Quartil1.csv >${results_folder}_0.25_Quartil.csv && rm ${results_folder}_0.25_Quartil1.csv

tr "\\[,]" ";" <best_${results_folder}1.csv >best_${results_folder}.csv && rm best_${results_folder}1.csv

cd ..

cp ./${results_folder}/${results_folder}_PostDesign.png ./PostDesign/${results_folder}_PostDesign.png

cp ./${results_folder}/${results_folder}_0.25_Quartil.csv ./.

cp ./${results_folder}/${results_folder}_Mutations.png ./PostDesign/${results_folder}_Mutations.png


#montage ${results_folder}_PostDesign.png -tile 4x4 -geometry +1+1 all.png
# Bsp.: montage Alb1_Chymo1_SecDesign_*_PostDesign.png -tile 4x4 -geometry +1+1 all_PostDesign.png


cp ./${results_folder}/${results_folder}_comparison_Pre_Post_Design.png ./Comparisons


#select best for SecDock

cd ./${results_folder}

echo "in Results Folder"

# copy best PDBs to new folder

a=($(awk -F "\"*;\"*" '{print $1}' ./best_${results_folder}.csv))

echo ${a[@]}

for ((i = 0 ; i < ${#a[@]} ; i++ ));
do
cp files_pdb/${a[$i]}.pdb ./${results_folder}
cp files_fasta/${a[$i]}.fasta ./${results_folder}
cp files_mutations/${a[$i]}_*.txt ./${results_folder}
done

cd ..

done

#sort and select by 25% Quartil
for i in 1;
do

sed '1!d' ./${original_file_name}${i}_0.25_Quartil.csv >> all_Quartils1.csv
sed '2!d' ./${original_file_name}${i}_0.25_Quartil.csv >> all_Quartils1.csv

done

for ((i=2;i<=${End};i++));
do

sed '2!d' ./${original_file_name}${i}_0.25_Quartil.csv >> all_Quartils1.csv

done


csvsort -c Quartil all_Quartils1.csv | head -n 6 > all_Quartils2.csv && rm all_Quartils1.csv
 
 
while IFS=, read Folder Quartil;
do

echo "Folder : $Folder"
echo "Quartil : $Quartil"
b=${Folder}
echo ${b[@]}

for ((o = 0 ; o < ${#b[@]} ; o++ ));
do
cp ./${b[$o]}/${b[$o]}/*.pdb ./PrepSecDock/PDB/.
cp ./${b[$o]}/${b[$o]}/*.fasta ./PrepSecDock/Fastas/.
cp ./${b[$o]}/${b[$o]}/*.txt ./PrepSecDock/Mutations/.
rm -r ./${b[$o]}/${b[$o]}
done

done <"all_Quartils2.csv"


tr "\\[,]" ";" <all_Quartils2.csv > all_Quartils.csv && rm all_Quartils2.csv && rm *_0.25_Quartil.csv

# rename
cd ./PrepSecDock/PDB
mkdir originals

cp ./*.pdb ./originals


# rename files and create excel-sheet
STRING=$new_name rename -v '$_ = sprintf "\Q$ENV{STRING}\E_%d.pdb", ++$::count' *.pdb >renamed1.csv 

tr "\\[ ]" ";" <renamed1.csv >renamed2.csv && rm renamed1.csv | cut -d ";" -f2-3 --complement renamed2.csv > 3_renamed_for_${next_step}.csv && rm renamed2.csv | sed -i 1i"From_${old_step};To_${next_step}" 3_renamed_for_${next_step}.csv

mkdir ../../../renamed_files
cp ./3_renamed_for_${next_step}.csv ../../../renamed_files

cd ../..
mv ./PrepSecDock ../${destiny_folder}/.

cd ../${destiny_folder}/PrepSecDock/PDB
scp ./*.pdb st_st161600@login02.binac.uni-tuebingen.de:/beegfs/work/workspace/ws/st_st161600-workspace2-0/${path_to_binac_folder}/.




