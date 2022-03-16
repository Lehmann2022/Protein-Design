#!/bin/bash

starting_file=$1

mkdir PDBs
mkdir PSEs

./change_aa.py

mv *.pdb ./PDBs




mv ./*.pse ./PSEs

