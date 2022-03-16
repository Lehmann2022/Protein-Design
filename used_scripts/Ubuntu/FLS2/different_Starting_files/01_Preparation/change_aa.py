#!/usr/bin/env python3
import csv
from collections import defaultdict
from Bio.Seq import Seq
from Bio.SeqUtils import seq3
from Bio.PDB.PDBParser import PDBParser
from Bio.PDB.Polypeptide import PPBuilder
from Bio.PDB.Polypeptide import index_to_one
import os


# some variables
row = 15
i = row
original = "renumb"
file = "Rec_Spike"


# number of sequence
while i <= 1253:
  position_in_Sequence_to_be_mutated = i-1
  n = position_in_Sequence_to_be_mutated
  column_of_csv = 6
  k = column_of_csv
  first_aa_position_to_be_mutated_in_complex_PSE = 935
  o = first_aa_position_to_be_mutated_in_complex_PSE
  mutation_run_number = 1
  b = mutation_run_number
  starting_file = original+".pse" 
  name = starting_file 
 
  print('Petide Sequence of ' + str(n) + '. part: ')
  
  
  # read csv with its mutations  
  with open('select_parts.csv') as f:
    reader = csv.reader(f)
    reader = list(reader)

    
    
    # insert mutation to specific place
    while k == 6:
      #row_number = k
      new_name = file+str(n)+".pse"
      print(file+str(n)+"."+str(b))
      new_name_but_pdb= file+str(n)+".pdb"
   
      aa = reader[i][k]
      three_letter_code = seq3(aa).upper()
      print( aa + ' is ' + three_letter_code )
      
      from pymol import cmd, stored 
      # Initialize
      cmd.load(name)
      cmd.wizard("mutagenesis")
      cmd.do("refresh_wizard")
      
      # lets mutate residue o to AA
      cmd.get_wizard().set_mode(three_letter_code)
      cmd.get_wizard().do_select(str(o)+"/")
      
      # Apply the mutation
      cmd.get_wizard().apply()
      
      # set new variables
      k = k+1
      o = o+1
      b = b+1 #number of inserted mutations
      name=new_name_but_pdb
      
    while k <= 27:
     
      new_name = file+str(n)+".pse"
      new_name_but_pdb= file+str(n)+".pdb"
   
      aa = reader[i][k]
      three_letter_code = seq3(aa).upper()
      print( aa + ' is ' + three_letter_code )
      print(file+str(n)+"."+str(b))
      
      from pymol import cmd, stored 
      # Initialize
      
      cmd.wizard("mutagenesis")
      cmd.do("refresh_wizard")
      
      # lets mutate residue 936 to CYS
      cmd.get_wizard().set_mode(three_letter_code)
      cmd.get_wizard().do_select(str(o)+"/")
      
      # Apply the mutation
      cmd.get_wizard().apply()
      

      
      #set new variables
      k = k+1
      o = o+1
      b = b+1

      name=new_name_but_pdb
    
      
    # save new file
    cmd.save(new_name)
    cmd.save(new_name_but_pdb)
  i=i+1



