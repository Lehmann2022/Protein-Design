#!/bin/bash

#example command-line for more than one file:
# michelle@codebind:/media/sf_Linux/Chymo/Test$ for i in {01..02};do ./post_process_Design.sh Alb1_Chymo1_FirstDocking.pdb Alb1_Chymo1_FirstDesign_$i.pdb Alb1_Chymo1_FirstDesign_$i; done


# Read in Results folder to operate in (first argument) and the name of the original pdb file to compare, which is placed in the "Originals" folder (second argument)

End=$1	#last folder number
starting_file=$2 # Rec_Spike
original_file_name=$3 # Rec_Spike_SecDesign
new_name=$4 # Final

Start2=2
folder=Finals
old_step=SecDesign
next_step=Final
destiny_folder=06_Finals

for ((m=1;m<=${End};m++));
do

starting_file=$2 # Rec_Spike
original_file_name=$3 # Rec_Spike_SecDesign
new_name=$4 # Final
results_folder=${original_file_name}${m}
original_file=${original_file_name}${m}".pdb"


mkdir ../$destiny_folder
mkdir ../$destiny_folder/Final_$m
mkdir ../$destiny_folder/Final_$m/PDBs
mkdir ../$destiny_folder/Final_$m/Fastas
mkdir ../$destiny_folder/Final_$m/Mutations
mkdir ../$destiny_folder/Final_$m/History
mkdir Originals
mkdir PostSecDesign
mkdir Comparisons
mkdir $folder
mkdir $folder/PDB
mkdir $folder/Fastas
mkdir $folder/Mutations
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
PostDesign_scores=($(awk '{print $15}' ./${results_folder}_scores.sc))
echo "PostDesign"
echo ${PostDesign_scores[@]}
PostDock_scores=($(awk '{print $16}' ./${results_folder}_scores.sc))
echo "PostDock"
echo ${PostDock_scores[@]}
PostRelax1_scores=($(awk '{print $17}' ./${results_folder}_scores.sc))
echo "PostRelax1"
echo ${PostRelax1_scores[@]}
PostRelax2_scores=($(awk '{print $18}' ./${results_folder}_scores.sc))
echo "PostRelax2"
echo ${PostRelax2_scores[@]}
rmsd=($(awk '{print $25}' ./${results_folder}_scores.sc))
echo "RMSD"
echo ${rmsd[@]}
total_energy_final=($(awk '{print $26}' ./${results_folder}_scores.sc))
echo "total_energy_final"
echo ${total_energy_final[@]}
total_energy_starting=($(awk '{print $27}' ./${results_folder}_scores.sc))
echo "Total Energy Starting"
echo ${total_energy_starting[@]}
positions_A=($(awk '{print $30}' ./${results_folder}_scores.sc))
echo "positions_A"
echo ${positions_A[@]}
#positions_B=($(awk '{print $31}' ./${results_folder}_scores.sc))
#echo "positions_B"
#echo ${positions_B[@]}
environment=($(awk '{print $29}' ./${results_folder}_scores.sc))
echo "Environment"
echo ${environment[@]}
Pose_names=($(awk '{print $31}' ./${results_folder}_scores.sc))
echo "Pose_names"
echo ${Pose_names[@]}


# make a copy of every fasta file with the respective interface score in the filename and save it in the respective subfolder
for ((i = 0 ; i < ${#Pose_names[@]} ; i++ ));
do
cp files_fasta/${Pose_names[$i]}.fasta files_fasta_by_score/${PostRelax2_scores[$i]}_${Pose_names[$i]}.fasta
scorename="${PostRelax2_scores[$i]}_${pdb_filename}"
sed -i "1s/${pdb_filename}/${scorename}/" files_fasta_by_score/${PostRelax2_scores[$i]}_$	{Pose_names[$i]}.fasta
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
-aoutfeat files_mutations/${fasta_filename}_mut.csv \
-boutfeat files_mutations/${fasta_filename}_b_mut.txt \
-globaldifferences true \
-sprotein1 true \
-sprotein2 true

rm files_mutations/${fasta_filename}_allmut.txt
rm files_mutations/${fasta_filename}_b_mut.txt

cd files_mutations

tr "\\[ ]" ";" <${fasta_filename}_mut.csv >Mut_2.csv && rm ${fasta_filename}_mut.csv
tr "\\[\t]" ";" <Mut_2.csv >Mut_3.csv && rm Mut_2.csv
tr "\\[=]" ";" <Mut_3.csv >Mut_4.csv && rm Mut_3.csv
tr "\\[.]" ";" <Mut_4.csv >${fasta_filename}_mut.csv && rm Mut_4.csv

cd ..

	
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

printf "Number;Pose;PostDock;PostRelax1;PostDesign;PostRelax2;Mutations;Charge;RMSD;TotalEnergy_Starting;TotalEnergy_Final;Environment;Positions_A\n" > ${results_folder}_results.csv
	
for ((i = 0 ; i < ${#Pose_names[@]} ; i++ ));
do
printf "${i};${Pose_names[$i]};${PostDock_scores[$i]};${PostRelax1_scores[$i]};${PostDesign_scores[$i]};${PostRelax2_scores[$i]};${mutations[$i]};${charge[$i]};${rmsd[$i]};${total_energy_starting[$i]};${total_energy_final[$i]};${environment[$i]};${positions_A[$i]}\n" >> ${results_folder}_results.csv
done

#sort 5 best results by PostRelax2 and than by Mutaions
csvsort -c PostRelax2 ${results_folder}_results.csv | head -n 6 > best_${results_folder}_PR2.csv
csvsort -c Mutations best_${results_folder}_PR2.csv |head -n 2 > best_${results_folder}.csv && rm best_${results_folder}_PR2.csv


# Create plots in R

Rscript ../analysis.r "${results_folder}_results.csv" "${results_folder}_PreSecDesign.png" "${results_folder}_PostSecDesign.png" "${results_folder}_ScoreCorr.png" "${results_folder}_Mutations.png" "${results_folder}_Docking.png" "${results_folder}_I_sc.png" "${results_folder}_Pre_SecDesign" "${results_folder}_Post_SecDesign" "${results_folder}_Score_Correlation" "${results_folder}_Mutations" "${results_folder}_Post_SecDocking" "${results_folder}_comparison_Pre_Post_SecDesign.png"

cd ..

cp ./${results_folder}/${results_folder}_PostSecDesign.png ./PostSecDesign/${results_folder}_PostSecDesign.png

cp ./${results_folder}/${results_folder}_Mutations.png ./PostSecDesign/${results_folder}_Mutations.png


#montage ${results_folder}_PostDesign.png -tile 4x4 -geometry +1+1 all.png
# Bsp.: montage Alb1_Chymo1_SecDesign_*_PostDesign.png -tile 4x4 -geometry +1+1 all_PostDesign.png


cp ./${results_folder}/${results_folder}_comparison_Pre_Post_SecDesign.png ./Comparisons


#select best for SecDock

cd ./${results_folder}

# copy best PDBs to new folder

a=($(awk -F "\"*,\"*" '{print $2}' ./best_${results_folder}.csv))

echo ${a[@]}

for ((i = 0 ; i < ${#a[@]} ; i++ ));
do
cp files_pdb/${a[$i]}.pdb ../$folder/PDB/.
cp files_fasta/${a[$i]}.fasta ../$folder/Fastas/.
cp files_mutations/${a[$i]}_*.txt ../$folder/Mutations/.
cp files_mutations/${a[$i]}_*.csv ../$folder/Mutations/.
done

cd ..

done


read -p "Continue with Script?" -n 1 -r

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
exit 1
fi

#rename files
cd ./${folder}/PDB
mkdir originals

cp *.pdb ./originals


# rename files and create excel-sheet
STRING=$new_name rename -v '$_ = sprintf "\Q$ENV{STRING}\E_%d.pdb", ++$::count' *.pdb >renamed1.csv 

tr "\\[ ]" ";" <renamed1.csv >renamed2.csv && rm renamed1.csv | cut -d ";" -f2-3 --complement renamed2.csv > 5_renamed_for_${next_step}.csv && rm renamed2.csv | sed -i 1i"From_${old_step};To_${next_step}" 5_renamed_for_${next_step}.csv

cp ./5_renamed_for_${next_step}.csv ../../../renamed_files

cd ../Mutations
mkdir originals
cp *.txt ./originals/.
STRING=$new_name rename -v '$_ = sprintf "\Q$ENV{STRING}\E_%d_needle.txt", ++$::count' *needle.txt >renamed1.csv 

tr "\\[ ]" ";" <renamed1.csv >renamed2.csv && rm renamed1.csv | cut -d ";" -f2-3 --complement renamed2.csv > renamed_needle.csv && rm renamed2.csv | sed -i 1i"From_${old_step};To_${next_step}" renamed_needle.csv

STRING=$new_name rename -v '$_ = sprintf "\Q$ENV{STRING}\E_%d_mut.csv", ++$::count' *mut.csv >renamed1.csv 

tr "\\[ ]" ";" <renamed1.csv >renamed2.csv && rm renamed1.csv | cut -d ";" -f2-3 --complement renamed2.csv > renamed_mut.csv && rm renamed2.csv | sed -i 1i"From_${old_step};To_${next_step}" renamed_mut.csv

cat *.csv > renamed_Mutations.csv

cd ../Fastas
mkdir originals
cp *.fasta ./originals/.
STRING=$new_name rename -v '$_ = sprintf "\Q$ENV{STRING}\E_%d.fasta", ++$::count' *.fasta >renamed1.csv 

tr "\\[ ]" ";" <renamed1.csv >renamed2.csv && rm renamed1.csv | cut -d ";" -f2-3 --complement renamed2.csv > renamed_fasta.csv && rm renamed2.csv | sed -i 1i"From_${old_step};To_${next_step}" renamed_fasta.csv

cd ../../
#mv ./${folder}./* ../${destiny_folder}/.

cd ../renamed_files
cat *.csv > all_renamed.csv

cd ../$destiny_folder


for l in $(seq $Start $End)
do 

cp ../05_SecDesign/Finals/PDB/${new_name}_${l}* ./${new_name}_${l}/PDBs/.
cp ../05_SecDesign/Finals/Fastas/${new_name}_${l}* ./${new_name}_${l}/Fastas/.
cp ../05_SecDesign/Finals/Mutations/${new_name}_${l}* ./${new_name}_${l}/Mutations/.
cp ../../Vorlagen/Final_Vorlage.docx ./${new_name}_${l}/${new_name}_${l}_Mutations.docx

done

for i in 1;
do

sed '1!d' ../05_SecDesign/$original_file_name$i/best_$original_file_name$i.csv >> Bests1.csv
sed '2!d' ../05_SecDesign/$original_file_name$i/best_$original_file_name$i.csv >> Bests1.csv

done


for i in $(seq $Start2 $End)
do

sed '2!d' ../05_SecDesign/$original_file_name$i/best_$original_file_name$i.csv >> Bests1.csv

done


tr "\\[,]" ";" <Bests1.csv > Finals.csv && rm Bests1.csv


cp ../../Vorlagen/*.xlsm ./.
cp ../../Vorlagen/Results.docx ./.








