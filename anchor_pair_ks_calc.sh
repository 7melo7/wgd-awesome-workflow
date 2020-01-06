#!/bin/bash
#########################################################
# Function : find anchor-pair genes between 2 genomes   # 
#            and calculate the KaKs value.              #
# Version  : 1.0                                        #
# Date     : 2020-01-04                                 #
# Author   : Wenlei Guo                                 #
# Contact  : Nobugsquirtle@outlook.com                  #
#########################################################

# Initialize variables & default parameters
minspan=30
spe1=""
spe2=""
workspace=""

# Usage
help_msg () {
    cat <<EOF >&2
Usage:
    anchor_pair_ks_calc.sh -m minspan_gene_count spe1 spe2
    [-m minspan gene count(30)] [-h help]
----------------------------------------------------------
Options:
    -m: minspan gene count
----------------------------------------------------------
Example:
    anchor_pair_ks_calc.sh -m 30 ath ath
----------------------------------------------------------
More information:
    Version: v0.1
    Author : Wenlei Guo
    Email  : Nobugsquirtle@outlook.com
    Github : github.com/7melo
EOF
}

# Parameter to variables
get_parameters () {
    while getopts :m:h opt;do 
        case $opt in
        m)  minspan=$OPTARG
            ;;
        h)  help_msg
            exit 0
            ;;
        '?') echo "$0: invalid option -$OPTARG" >&2
            help_msg
            exit 1
            ;;
        esac
    done
    shift $((OPTIND - 1))
    spe1=$1
    spe2=$2
    workspace="${spe1}_${spe2}_workspace"
}

# check python environment and package
check_python_environment () {
    py_version=`python --version | grep 'Python 2' | wc -l`
    jcvi_check=`pip list | grep 'jcvi' | wc -l`
    if [[ $py_version -eq 1 && $jcvi_check -eq 1 ]];then
        echo "python environment right and required packages installed."
    elif [[ $py_check -eq 0 ]];then
        echo "Error: python environment should be Python2.7."
        exit 1;
    elif [[ !$jcvi_check -eq 0 ]];then
        echo "Error: jcvi package not installed."
        exit 1;
    fi
}

# find anchor gene pair using MCScan
find_anchor_pairs () {
    mkdir "$workspace"
    cp "${spe1}.cds" "${spe1}.bed" "${spe2}.cds" "${spe2}.bed" "${workspace}/"
    cd $workspace
    python -m jcvi.compara.catalog ortholog $spe1 $spe2 --no_strip-names
    python -m jcvi.compara.synteny screen --minspan=$minspan --simple $spe1.$spe2.anchors $spe1.$spe2.anchors.$minspan
    cp $spe1.$spe2.anchors.$minspan ../anchor-pair.result.dirt;cd ..
    grep -v "#" anchors-pair.result.dirt > anchors-pair.result
}

get_parameters $*
find_anchor_pairs