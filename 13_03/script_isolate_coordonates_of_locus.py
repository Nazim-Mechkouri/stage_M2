import sys
import os,re


if len(sys.argv) != 5 :
    print("Inputs incorrectes, respectez la commande : python3 script.py path start_coordonate end_coordonate")
    sys.exit(1)

try :
    int(sys.argv[3])  
    int(sys.argv[4])    
except ValueError:
    print("Erreur : deuxième et troisième arguments doivent être numériques (coordonnées du locus)") 
    sys.exit(1)



################# VARIABLES #################
inputfile = sys.argv[1]
outputfile = sys.argv[2]

start_coordonate = sys.argv[3]
end_coordonate = sys.argv[4]


threshold=10000000
cpt = 0
cpt_locus_size = 0

locus = ""
################### CORE ####################


print(f"\nTHE GIVEN PATH: {inputfile}\n\nStart_of_locus: {start_coordonate}\nEnd_of_locus: {end_coordonate}\n\n")

with open(inputfile, "r") as file1:
    raw_lines = file1.readlines()
    lines = [lines.replace("\n","") for lines in raw_lines]

for line in lines:

    if cpt >= threshold :
        print(f"We counted {cpt} Nucleotides already")
        threshold=threshold+10000000
    if line.startswith(">"):
        header = len(line) 
        print(f"The size of the fasta file header is {header} char\nThe header in question is: {line}\n\n")
    if line.startswith != line.startswith(">") and "N" not in line:  
        if cpt < (int(start_coordonate)-1000):        
            cpt += len(line)
            #print(cpt)

        if cpt >= (int(start_coordonate)-1000) and cpt < (int(end_coordonate)):
            #print("situation1")
            for char in line:
                cpt=cpt+1
                #print(cpt)
        if int(start_coordonate) <= cpt <= int(end_coordonate):
            for char in line:
                #print("situation2")
                locus += char
                cpt_locus_size += 1
                cpt=cpt+1
                #print(cpt)
        elif cpt > int(end_coordonate):
            #print("situation3")
            cpt += len(line)


print(f"\n\nSize of the SEQUENCE in this fasta file is: {cpt}pb")
print(f"Size of the selected LOCUS is: {cpt_locus_size}pb")


with open(outputfile,'w') as file2 :
    file2.write(locus)
