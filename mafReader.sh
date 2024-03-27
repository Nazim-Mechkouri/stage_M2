#!/bin/bash

# SBATCH -c 1 # Number of cores on the same node
# SBATCH --partition=igh # specifies the partiton of the queue
# SBATCH -o slurmlog/slurmlogmytask_%j.out # File to which STDOUT will be written, %j will be replaced by the jobID
# SBATCH -e slurmlog/slurmlogmytask_%j.err # File to which STDERR will be written, %j will be replaced by the jobID.

################################################################################
# This scripts filters mulputiple alignment files .maf                         #
#                                                                              #
# If problems encoutered concerning the input or usage of the script           #
# please refer to the help section below or use : ./mafReader -h               #
#                                                                              #
#  version updates and perspectives :-                                         #
#                                    -                                         #
#                                    -                                         #
#                                    -                                         #
#                                    -                                         #
################################################################################

################################################################################
# Help                                                                         #
################################################################################
Help()
{
   # Display Help
   RED='\033[1;33m'
   NC='\033[0m'

   echo "####This script takes 6 arguments as follow and in this order"
   echo
   echo
   echo -e "${RED}Usage : ${NC}./mafReader.sh MAFfile SpecieGenome ChrNumber Start-Coordonate End-Coordonate OutputFile"
   echo
   echo -e "${RED}-mafFile :${NC} obtained from UCSC genome browser data"
   echo -e "${RED}-SpecieGenome & ChrNumber :${NC} name of the genome.assembly as it is referenced in the maf file (ex : hg38,mmus19,CanFam5,BosTau9 ...etc). ChrNumber only ("10" and not "chr10")"
   echo -e "${RED}-Start-Coordonate :${NC} Start of the targeted sequence to be looked for"
   echo -e "${RED}-End-Coordonate :${NC} End of the targeted sequence to be looked for"
   echo -e "${RED}-End-Coordonate :${NC} End of the targeted sequence to be looked for"

}


################################################################################
# Process the input options. Add options as needed.                            #
################################################################################

# Get the options
while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
     \?) # incorrect option
         echo "Error: Invalid option"
         exit;;
   esac
done



################################################################################
#                              Main program                                    #
################################################################################

# Define output file
output_file=$6

# Initialize the output file
> "$output_file"


# my inputs #
maf_file=$1
input_specie=$2
input_chrom=$3


sequence_start_position=$4
sequence_end_position=$5



# my counts #
found_specie=0
found_block=0
found_UTR=0
cpt=0
temporary_count=1001
# split the filename from the Path #
p=$maf_file
file=$( echo ${p##*/} )
#extract the first digits of the position (we cant work on exact positions for the enhancers or genes for example since they are not annotated, so we take roughly the same position)
trimmed_input_pos=${sequence_start_position:0:2}
wider_input_pos=$((trimmed_input_pos+1))


# Initialization and quality of life
echo "The current file is : $file"
echo "specie of interest : "$input_specie
echo "chromosome of interest : chr"$input_chrom
echo "looking near position : "$trimmed_input_pos"XXXXX" "and/or "$wider_input_pos"XXXXX"   
echo
echo "I am searching for a match between current position and the given position in the file ..." 



################################################################################################################################################################
#reading the file

while IFS= read -r line
do
    # Check if the line starts with 'a' indicating a NEW alignment block #
    if [[ $line == "a"* ]]; then
        found_specie=0
        found_chrom=0
        found_candidate_sequence=0
        block_info="$line\n"  # Initialize block_info variable with the line
 
    fi

    # Check if the line starts with 's' indicating a sequence line
    if [[ $line == "s"* ]]; then
        # Extract the sequence from the line using an array list #
        line_parts=($line)
        current_specie=$(echo ${line_parts[1]} | cut -d "." -f 1)  # specie of the current line (for pariwise human/dog for example its either hg38 or CanFam)
        current_chrom=$(echo ${line_parts[1]} | cut -d "." -f 2)  # chromosome where the current sequence is located
        cpt=$((cpt+1))
        if [[ $cpt == $temporary_count ]]  ; then 
            echo $cpt $current_chrom $current_specie
            temporary_count=$((temporary_count*2-1))
        fi    
        if [[ $current_chrom == "chr$input_chrom" ]]; then
            found_chrom=1
            if [[ $current_specie == $input_specie ]]; then
                found_specie=1
                # echo "I found the right specie and right chrom"
                split_line=($line)
                current_start_position=${split_line[2]}
                #echo $current_start_position $trimmed_input_pos 
                if [[ $current_start_position -ge $sequence_start_position ]] && [[ $current_start_position -le $sequence_end_position ]]; then
                    found_candidate_sequence=1
                    echo "I have found in the specie "$current_specie" and its chromosome "$current_chrom" a match for our sequences :"
                    echo "current position :"$current_start_position" matches with the given input position : "$sequence_start_position"(seed : "$trimmed_input_pos")"
                fi
            fi    
        fi    
    fi

    # Check if all conditions are met, then append block_info to the output file
    if [[ $found_specie -eq 1 && $found_chrom -eq 1 && $found_candidate_sequence -eq 1 ]]; then
        echo -e "$block_info\n$line" >> "$output_file"
    fi

    # Append block info to block_info variable
    block_info="$block_info\n$line"

done < "$maf_file"


