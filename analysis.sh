#!/bin/bash

# ============================================================
# OpenMS LC-MS/MS Proteomics Analysis
# Dataset: PRIDE PXD000111
# Organism: Mycobacterium tuberculosis H37Rv
# ============================================================

# ------------------------------------------------------------
# 1. Project setup
# ------------------------------------------------------------

mkdir -p OpenMS_PRIDE_Practical/{raw,mzML,db,results,export,logs}
cd OpenMS_PRIDE_Practical


# ------------------------------------------------------------
# 2. Create and activate micromamba environment
# ------------------------------------------------------------

micromamba create -n openms_practical python=3.10 -y
micromamba activate openms_practical

micromamba config append channels conda-forge
micromamba config append channels bioconda
micromamba config set channel_priority strict

micromamba install openms openms-thirdparty -y


# ------------------------------------------------------------
# 3. Check OpenMS installation
# ------------------------------------------------------------

FileInfo --help
MSGFPlusAdapter --help


# ------------------------------------------------------------
# 4. Download PRIDE dataset
# ------------------------------------------------------------

python -m webbrowser \
"https://www.ebi.ac.uk/pride/archive/projects/PXD000111"

wget -c \
"ftp://ftp.pride.ebi.ac.uk/pride/data/archive/2013/01/PXD000111/090313_01.RAW" \
-P raw/

ls -lh raw/090313_01.RAW
file raw/090313_01.RAW


# ------------------------------------------------------------
# 5. Download protein database
# Mycobacterium tuberculosis H37Rv
# ------------------------------------------------------------

wget -c \
"https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/195/955/GCF_000195955.2_ASM19595v2/GCF_000195955.2_ASM19595v2_protein.faa.gz" \
-P db/

gunzip -kf db/GCF_000195955.2_ASM19595v2_protein.faa.gz

mv -f \
db/GCF_000195955.2_ASM19595v2_protein.faa \
db/mtb_h37rv_proteins.fasta

head db/mtb_h37rv_proteins.fasta

grep -c "^>" db/mtb_h37rv_proteins.fasta


# ------------------------------------------------------------
# 6. RAW → mzML conversion
# ------------------------------------------------------------

mono "$CONDA_PREFIX/bin/ThermoRawFileParser.exe" \
-i raw/090313_01.RAW \
-b mzML/090313_01.mzML \
-f 2 -e

ls -lh mzML/090313_01.mzML


# ------------------------------------------------------------
# 7. mzML quality inspection
# ------------------------------------------------------------

FileInfo \
-in mzML/090313_01.mzML \
> logs/01_fileinfo.txt

grep -E \
"MS levels|Number of spectra|level 1|level 2|level 3|Peak type" \
logs/01_fileinfo.txt


# ------------------------------------------------------------
# 8. Target-decoy database generation
# ------------------------------------------------------------

DecoyDatabase \
-in db/mtb_h37rv_proteins.fasta \
-out db/mtb_h37rv_td.fasta \
-decoy_string DECOY_ \
-method reverse

grep -c "^>" db/mtb_h37rv_td.fasta

grep -c "^>DECOY_" db/mtb_h37rv_td.fasta


# ------------------------------------------------------------
# 9. Locate MS-GF+ executable
# ------------------------------------------------------------

MSGF_JAR=$(find "$CONDA_PREFIX" \
-type f -iname "MSGFPlus.jar" | head -n 1)

echo "$MSGF_JAR"


# ------------------------------------------------------------
# 10. MS-GF+ database search
# ------------------------------------------------------------

MSGFPlusAdapter \
-in mzML/090313_01.mzML \
-database db/mtb_h37rv_td.fasta \
-out results/01_msgf.idXML \
-executable "$MSGF_JAR" \
-threads 4

FileInfo -in results/01_msgf.idXML


# ------------------------------------------------------------
# 11. Peptide indexing
# ------------------------------------------------------------

PeptideIndexer \
-in results/01_msgf.idXML \
-fasta db/mtb_h37rv_td.fasta \
-out results/02_indexed.idXML \
-decoy_string DECOY_ \
-decoy_string_position prefix \
-threads 4

FileInfo -in results/02_indexed.idXML


# ------------------------------------------------------------
# 12. PSM-level FDR estimation
# ------------------------------------------------------------

FalseDiscoveryRate \
-in results/02_indexed.idXML \
-out results/03_fdr.idXML \
-PSM true \
-peptide false \
-protein false


# ------------------------------------------------------------
# 13. PSM filtering
# 1% PSM threshold
# ------------------------------------------------------------

IDFilter \
-in results/03_fdr.idXML \
-out results/04_filtered.idXML \
-score:psm 0.01


# ------------------------------------------------------------
# 14. Protein inference
# ------------------------------------------------------------

ProteinInference \
-in results/04_filtered.idXML \
-out results/05_proteins.idXML


# ------------------------------------------------------------
# 15. Export protein identification results
# ------------------------------------------------------------

TextExporter \
-in results/05_proteins.idXML \
-out export/05_proteins.tsv

grep -c "^PEPTIDE" export/05_proteins.tsv

grep -c "^PROTEIN" export/05_proteins.tsv


# ------------------------------------------------------------
# 16. Feature detection
# ------------------------------------------------------------

FeatureFinderCentroided \
-in mzML/090313_01.mzML \
-out results/06_features.featureXML


# ------------------------------------------------------------
# 17. Map identifications to detected features
# ------------------------------------------------------------

IDMapper \
-in results/06_features.featureXML \
-id results/04_filtered.idXML \
-out results/07_mapped.featureXML

TextExporter \
-in results/07_mapped.featureXML \
-out export/07_mapped_features.tsv

head -30 export/07_mapped_features.tsv


# ------------------------------------------------------------
# 18. Protein and peptide quantification
# ------------------------------------------------------------

ProteinQuantifier \
-in results/07_mapped.featureXML \
-protein_groups results/05_proteins.idXML \
-out export/08_protein_quant.csv \
-peptide_out export/08_peptide_quant.csv

head -20 export/08_protein_quant.csv