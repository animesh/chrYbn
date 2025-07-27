#!/usr/bin/env python3

import sys
import gzip
from collections import defaultdict

def parse_vcf(vcf_file):
    samples = []
    seqs = defaultdict(list)

    with gzip.open(vcf_file, 'rt') if vcf_file.endswith('.gz') else open(vcf_file, 'r') as f:
        for line in f:
            if line.startswith('##'):
                continue
            elif line.startswith('#CHROM'):
                fields = line.strip().split('\t')
                samples = fields[9:]  # Sample IDs
            else:
                parts = line.strip().split('\t')
                ref, alt = parts[3], parts[4]
                if len(ref) != 1 or len(alt) != 1:
                    continue  # skip indels or multiallelics
                genotypes = parts[9:]
                for i, gt in enumerate(genotypes):
                    allele = gt.split(':')[0].replace('|', '/')
                    if allele in {'0/0', '0'}:
                        seqs[samples[i]].append(ref)
                    elif allele in {'1/1', '1'}:
                        seqs[samples[i]].append(alt)
                    elif allele in {'0/1', '1/0'}:
                        seqs[samples[i]].append('N')  # heterozygote (rare on chrY)
                    else:
                        seqs[samples[i]].append('N')  # missing or uncalled
    return samples, seqs

def write_fasta(samples, seqs, output_fasta):
    with open(output_fasta, 'w') as out:
        for sample in samples:
            out.write(f">{sample}\n")
            out.write("".join(seqs[sample]) + "\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: vcf2Fasta.py input.vcf[.gz] output.fasta")
        sys.exit(1)

    vcf_file = sys.argv[1]
    output_fasta = sys.argv[2]

    samples, seqs = parse_vcf(vcf_file)
    write_fasta(samples, seqs, output_fasta)
