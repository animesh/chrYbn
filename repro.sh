#!/bin/bash

echo "🧪 Step 1: Download correct chrY VCF"
# check the chrY VCF
curl --silent ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ | grep 'chrY'

# Download VCF file if it doesn't exist
if [ ! -f "ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz" ]; then
    echo "Downloading VCF file..."
    wget -c ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz
else
    echo "VCF file already exists, skipping download."
fi

# Download VCF index file if it doesn't exist
if [ ! -f "ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz.tbi" ]; then
    echo "Downloading VCF index file..."
    wget -c ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz.tbi
else
    echo "VCF index file already exists, skipping download."
fi

echo
echo "📐 Step 2: Create BED file for NRY"
cat <<EOF > nry_region.bed
chrY	2700000	59030000
EOF

#module load BCFtools/1.19-GCC-13.2.0
echo "🧹 Step 3: Filter for high-confidence NRY SNPs"
bcftools view -R nry_region.bed \
  ALL.chrY.phase3_integrated_v2b.20130502.genotypes.vcf.gz \
  -Oz -o filtered.nry.chrY.vcf.gz

tabix -p vcf filtered.nry.chrY.vcf.gz

echo "📦 Step 4: Download VCF → FASTA converter script"
# Download Python script if it doesn't exist
if [ ! -f "vcf2Fasta.py" ]; then
    echo "Downloading vcf2Fasta.py script..."
    wget -O vcf2Fasta.py https://raw.githubusercontent.com/animesh/chrYbn/main/vcf2Fasta.py
    chmod +x vcf2Fasta.py
else
    echo "vcf2Fasta.py already exists, skipping download."
    # Ensure it's executable
    chmod +x vcf2Fasta.py
fi

echo "🔠 Step 5: Convert to FASTA"
./vcf2Fasta.py filtered.nry.chrY.vcf.gz alignment.fasta

echo "🧬 Step 6: Open BEAUti manually and load alignment.fasta"
echo "⚠️  Manual step required: set substitution model (HKY), strict clock (7.6e-10), BSP prior, and save bsp.xml"

# Uncomment if BEAST and bsp.xml are ready
# echo "🐝 Step 7: Run BEAST"
# beast bsp.xml

echo "📈 Step 8: View skyline in Tracer after run completes"
echo "Done ✅"
