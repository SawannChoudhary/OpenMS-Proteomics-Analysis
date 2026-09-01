# OpenMS Proteomics Analysis

A reproducible LC-MS/MS proteomics data analysis workflow using OpenMS and MS-GF+ for peptide identification, false discovery rate (FDR) filtering, protein inference, feature mapping, and protein quantification.

## Overview

This project demonstrates a complete bottom-up proteomics analysis workflow starting from a Thermo RAW mass spectrometry file and ending with protein- and peptide-level quantitative results.

The workflow was performed using OpenMS and MS-GF+ and includes database searching, target-decoy database generation, peptide indexing, PSM-level FDR filtering, protein inference, feature detection, identification mapping, and label-free protein quantification.

## Dataset

The mass spectrometry dataset was obtained from the PRIDE Archive.

- **PRIDE accession:** PXD000111
- **Raw file:** `090313_01.RAW`
- **Organism:** *Mycobacterium tuberculosis* H37Rv
- **Instrument:** LTQ FT
- **Acquisition time:** approximately 73 minutes

The raw mass spectrometry data are not included in this repository because of file size. The original dataset can be obtained from the PRIDE Archive using accession PXD000111.

## Workflow

```text
RAW mass spectrometry data
            |
            v
ThermoRawFileParser
            |
            v
           mzML
            |
            v
 Target-decoy database
            |
            v
        MS-GF+
            |
            v
     PeptideIndexer
            |
            v
      FDR estimation
            |
            v
       PSM filtering
            |
            v
    Protein inference
            |
            v
    Feature detection
            |
            v
     ID mapping
            |
            v
 Protein quantification
            |
            v
 Final protein and peptide tables
 Analysis Steps
Downloaded the LC-MS/MS RAW file from PRIDE.
Downloaded the M. tuberculosis H37Rv protein FASTA database from NCBI.
Converted the Thermo RAW file to mzML format.
Inspected the resulting mzML file using OpenMS FileInfo.
Generated a target-decoy protein database using reversed protein sequences.
Performed peptide-spectrum matching using MS-GF+.
Indexed peptide identifications against the protein database.
Estimated PSM-level false discovery rate.
Filtered identifications at a 1% PSM score threshold.
Performed protein inference.
Exported protein identification results.
Detected LC-MS features.
Mapped peptide identifications to detected features.
Performed protein and peptide quantification using ProteinQuantifier.
Dataset QC

The converted mzML file contained:

7,776 total spectra
4,059 MS1 spectra
3,662 MS2 spectra
55 MS3 spectra
3,073,368 total peaks
73 minute acquisition range

All three MS levels were reported as centroided in the OpenMS FileInfo output.

Results

The protein identification export contained:

311 protein entries
1,944 peptide entries

The final quantitative tables contained:

105 quantified protein rows
1,169 quantified peptide rows

Protein abundance values ranged from approximately:

8.39 × 10⁵ to 2.94 × 10⁸
Median abundance: approximately 5.32 × 10⁶

The median number of peptides supporting a quantified protein was 5, with a maximum of 51 peptides supporting a single quantified protein.
Repository Contents
OpenMS-Proteomics-Analysis/
│
├── README.md
├── analysis.sh
├── .gitignore
│
├── data/
│   └── README.md
│
├── figures/
│   ├── abundance_vs_peptide_support.png
│   ├── peptide_support_per_protein.png
│   ├── protein_abundance_distribution.png
│   └── top10_proteins_abundance.png
│
└── results/
    ├── 05_proteins.tsv
    ├── 07_mapped_features.tsv
    ├── 08_peptide_quant.csv
    └── 08_protein_quant.csv
    Figures
Protein abundance distribution

Distribution of quantified protein abundances on a log10 scale.

Top 10 quantified proteins

The ten proteins with the highest calculated abundance values.

Peptide support per protein

Distribution of the number of peptides supporting each quantified protein.

Protein abundance vs peptide support

Relationship between the number of supporting peptides and calculated protein abundance.

Software
OpenMS
MS-GF+
ThermoRawFileParser
micromamba
Python

OpenMS version used in the analysis: 2024.03.26

Reproducibility

The computational workflow is documented in analysis.sh.

Large raw and intermediate mass spectrometry files are intentionally excluded from this repository. The dataset accession and data source are documented in data/README.md.

Important Note

This project represents a single LC-MS/MS run. It is therefore a demonstration of proteomics identification and quantification rather than a differential proteomics experiment.

No biological replicate-based statistical comparison or differential protein abundance analysis was performed.

Author

Sawan Choudhary
MSc Bioinformatics and Biotechnology