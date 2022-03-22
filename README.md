# Protein-Design
Scripts and appendix for protein design
A guide

1. scripts used - Rosetta

1.1 Albumin

/used_scripts/BinAC/Alb_Chymo

The scripts here are used for docking and design of albumin variants binding to chymotrypsin. The "Parallel_Start.sh" script is used for each step. The "Docking_1.xml" script performs a randomized first docking step. The "Docking_2.xml" script performs a non-randomized second docking step. The "Interface_Design.xml" script performs the design steps.

1.2 FLS2

/used_scripts/BinAC/FLS2/binds_to_BAK1_FLS2

The scripts here are used for docking and design of Bak1 and FLS2. The "Parallel_Start.sh" script is used for each step. The "Docking_multiple_chaisn.xml" script performs the non-randomized docking steps. The "Interface_FirstDesign_multiple_chains.xml" and the "Interface_SecDesign_multiple_chains.xml" scripts perform the design steps. The only difference here is in the storage of the measurement data.

/used_scripts/BinAC/FLS2/binds_to_FLS2

The scripts here are used for docking and design of FLS2 only. The "Parallel_Start.sh" script is used for each step. The "Docking_single_chain.xml" script performs the non-randomized docking steps. The "Interface_FirstDesign_signle_chain.xml" and the "Interface_SecDesign_single_chain.xml" scripts perform the design steps. The only difference here is in the storage of the measurement data.

/used_scripts/BinAC/FLS2/Original_structure

Here are the two used scripts for the first docking step with the original structure. Both BAK1 and FLS2 are fixed in the process. Backbone movements are also prohibited.

2. scripts used - Ubuntu

2.1. albumin

2.1.1. First docking

/used_scripts/Ubuntu/Alb_Chymo/02_PostFirstDock

The bash script here is used to evaluate, sort and rename the structures after the first docking.
2.1.2 First design

/used_scripts/Ubuntu/Alb_Chymo/03_PostFirstDesign

The bash script here is used to evaluate, sort and rename the structures after the first design. The R script is used to create the graphs, histograms and dot plots.

2.1.3 Second docking

/used_scripts/Ubuntu/Alb_Chymo/04_PostSectDock

The bash script here is used to evaluate, sort and rename the structures after the second docking. The R script creates a histogram with the interaction values.

2.1.4. Zweites Design

/used_scripts/Ubuntu/Alb_Chymo/05_PostSecDesign

The bash script here is used to evaluate, sort and rename the structures after the second design. The R script is used to create the graphs, histograms and dot plots.

2.2 FLS2 different peptides

2.2.1 Preparation

/used_scripts/Ubuntu/FLS2/different_Starting_files/01_Preparation

The present scripts are used to prepare the different structures. The Python script is activated by the bash script. The Python script thereby accesses present comma separated CSV file in which the sequences are created. These scripts are used to create the 15-amino acid long peptides.

2.2.2 Initial Docking

/used_scripts/Ubuntu/FLS2/different_Starting_files/02_PostFirstDock

The bash script here is used to evaluate, sort and rename the structures after the first docking.

2.2.3 First design

/used_scripts/Ubuntu/FLS2/different_Starting_files/03_PostFirstDesign

The bash script here is used to evaluate, sort and rename the structures after the first design. The R script is used to create the graphs, histograms and dot plots. It also calculates the respective quartiles, which also contribute to the selection.

2.2.4 Second Docking

/used_scripts/Ubuntu/FLS2/different_Starting_files/04_PostSectDock

The bash script here is used to evaluate, sort and rename the structures after the second docking. The R script creates a histogram with the interaction values.

2.2.5 Second design

/used_scripts/Ubuntu/FLS2/different_Starting_files/05_PostSecDesign

The bash script here is used to evaluate, sort and rename the structures after the second design. The R script is used for creating the graphs, histograms and dot plots. The pml script is used for creating prebuilt PSE structures of the finalists.

2.3 FLS2-defined peptides

2.3.1 First docking

/used_scripts/Ubuntu/FLS2/same_Starting_files/02_PostFirstDock

The bash script here is used to evaluate, sort and rename the structures after the first docking.

2.3.2 First design

/used_scripts/Ubuntu/FLS2/same_Starting_files/03_PostFirstDesign

The bash script here is used to evaluate, sort and rename the structures after the first design. The R script is used to create the graphs, histograms and dot plots. It also calculates the respective quartiles, which also contribute to the selection.

2.3.3 Second Docking

/used_scripts/Ubuntu/FLS2/same_Starting_files/04_PostSectDock

The bash script here is used to evaluate, sort and rename the structures after the second docking. The R script creates a histogram with the interaction values.

2.3.4 Second design

/used_scripts/Ubuntu/FLS2/same_Starting_files/05_PostSecDesign

The bash script here is used to evaluate, sort and rename the structures after the second design. The R script is used for creating the graphs, histograms and dot plots. The pml script is used for creating pre-made PSE structures of the finalists.

2.4 Templates

/used_scripts/Ubuntu/FLS2/Templates

Below are the templates that have been created. These are copied with the bash scripts of the second design into the respective subfolders and renamed. The XLSM file contains the used macros for the evaluation. On the one hand, the macros create the mutation tables, on the other hand, the amino acids of the peptides used are colored according to their properties and the sequences are colored for their mutations.

3. laboratory variants

The inserted sequences for experimental study can be found under the "experimentelle-Varianten.pdf" file.

4. modeling results

Under "Ergebnisse_Modellierung.pdf", the modeled albumin and FLS2 variants are shown graphically after the respective steps. Also shown in each case are the original sequence, the mutated sequence and, in tabular view, the inserted mutations.

5. amino acid migration

In the Excel file "AS-Austausch.xlsx", the mutations of each final variant created, both albumin and FLS2 variants, are shown. In addition, the trend is shown in the table "Comparison_all". For this, the coefficients of determination and the correlation coefficient are calculated.


Those last three files are written in German.
