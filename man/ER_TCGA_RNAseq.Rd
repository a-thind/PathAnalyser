% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{ER_TCGA_RNAseq}
\alias{ER_TCGA_RNAseq}
\title{ER RNA-seq gene expression data set from TCGA}
\format{
A matrix containing 20,124 HUGO gene symbols (row names) and 60 breast
cancer tumour samples IDs (columns) given in the form of TCGA barcodes for
each sample. For further information on TCGA bar code semantics, please see
the NIH GDC documentation
\url{https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/}.
}
\source{
\url{https://portal.gdc.cancer.gov}).
}
\usage{
ER_TCGA_RNAseq
}
\description{
A gene expression matrix containing RNA-seq raw read counts for 60 human
primary breast tumour samples (30 estrogen receptor (ER) positive and 30 ER
negative samples were selected at random). This data set is a subset of a
much larger data set containing 1,101 primary breast tumour samples collected
from The Cancer Genome Atlas (TCGA).
}
\keyword{datasets}
