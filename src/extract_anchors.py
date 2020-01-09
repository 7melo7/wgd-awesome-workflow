#/usr/bin/env python
# -*- encoding: utf-8 -*-
# Authon: Wenlei Guo
import sys

def get_anchor_pair_into_list(filename):
    anchor_pair = []
    with open(filename, 'r') as f:
        for i in f.readlines():
            anchor_pair.append(i.strip('\n').split('\t'))
    return anchor_pair

def read_cds_into_dict(filename):
    cds = {}
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith('>'):
                cds_id = line[1:]
                if cds_id not in cds:
                    cds[cds_id] = ""
                continue
            sequence = line
            cds[cds_id] += sequence
    return cds

def write_into_independent_fasta_file(anchor_pair, cds_dict, store_path):
    count=1
    for i in anchor_pair:
        with open(store_path+"/"+str(count)+".fasta", "w") as f:
            p1, p2, s1, s2 = i[0], i[1], cds_dict[i[0]], cds_dict[i[1]]
            f.write(">"+p1+'\n')
            while len(s1) > 60:
                f.write(s1[:60]+'\n')
                s1 = s1[60:]
            f.write(s1+'\n')
            f.write(">"+p2+'\n')
            while len(s2) > 60:
                f.write(s2[:60]+'\n')
                s2 = s2[60:]
            f.write(s2+'\n')
        count += 1 
    return None

if __name__ == "__main__":
    anchors_tsv_file = sys.argv[1]
    cds_file = sys.argv[2]
    store_path = sys.argv[3]
    anchor_pair = get_anchor_pair_into_list(anchors_tsv_file)
    cds_dict = read_cds_into_dict(cds_file)
    write_into_independent_fasta_file(anchor_pair, cds_dict, store_path) 
