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
base_dir=`pwd`
project_dir=$(cd "$(dirname "$0")";pwd)
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
    jcvi_check=`pip list | grep 'jcvi' | wc -l`
    if [[ $jcvi_check -eq 1 ]];then
        echo "python environment right and required packages installed."
    elif [[ !$jcvi_check -eq 0 ]];then
        echo "Error: jcvi package not installed."
        exit 1;
    fi
}

# find anchor gene pair using MCScan
find_anchor_pairs () {
    mkdir "$base_dir/$workspace"
    cp "$base_dir/${spe1}.cds" "$base_dir/${spe1}.bed" "$base_dir/${workspace}/"
    cp "$base_dir/${spe2}.cds" "$base_dir/${spe2}.bed" "$base_dir/${workspace}/"
    cd $base_dir/$workspace
    python -m jcvi.compara.catalog ortholog $spe1 $spe2
    python -m jcvi.compara.synteny screen --minspan=$minspan --simple $spe1.$spe2.anchors $spe1.$spe2.anchors.$minspan
    grep -v "#" $spe1.$spe2.anchors.$minspan | cut -f1,2 > anchors-pair.result.tsv
}

# i am at $base_dir/$workspace now.

# get ortholog gene pair in fasta file
ortholog_gene_pair_write() {
    mkdir gene_pair_dirct
    if [ ${spe1} == ${spe2} ];then
        final_cds="${spe1}.cds"
    else
        cat $base_dir/$spe1.cds $base_dir/$spe2.cds > $base_dir/$workspace/merge.cds
        final_cds="merge.cds"
    fi
    python $project_dir/py/extract_anchors.py $base_dir/$workspace/anchors-pair.result.tsv $base_dir/$final_cds $base_dir/$workspace/gene_pair_dirct
}

# ka ks calculate
ka_ks_calculate () {
    count=`ls -l $base_dir/$workspace/gene_pair_dirct/*fasta | wc -l`
    for i in $(seq 1 $count);do
        muscle -in $base_dir/$workspace/gene_pair_dirct/$i.fasta -phyiout $base_dir/$workspace/gene_pair_dirct/$i.phy
        AXTConvertor $base_dir/$workspace/gene_pair_dirct/$i.phy $base_dir/$workspace/gene_pair_dirct/$i.axt
    done
    cat $base_dir/$workspace/gene_pair_dirct/*axt > $base_dir/$workspace/gene_pair_dirct/${spe1}_${spe2}.axt
    KaKs_Calculator -i $base_dir/$workspace/gene_pair_dirct/${spe1}_${spe2}.axt -o $base_dir/${spe1}_${spe2}_kaks.csv -m YN -c 11
}

get_parameters $*
# check_python_environment
# find_anchor_pairs
# ortholog_gene_pair_write
ka_ks_calculate
echo all done!
