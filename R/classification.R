#' Classification Using Absolute GSVA Score Thresholds
#' @description Classifies samples according to pathway activity by first
#' ranking samples by their GSVA score and assessing evidence of expression
#' consistency of each sample with the up-regulated gene-set and down-regulated
#' gene-set of the gene signature using absolute GSVA score thresholds. GSVA
#' scores generated by the GSVA algorithm provide a measure of expression
#' abundance of the up-regulated and down-regulated gene-sets, which
#' PathAnalyser uses to assess expression consistency with both
#' parts (up-regulated and down-regulated gene-sets) of the gene signature using
#' the user-supplied absolute GSVA score thresholds as thresholds for expression
#' consistency with each part of the signature.
#' @details
#' Four thresholds are specified by the user:
#' 1) "up_thresh.low" - a GSVA score threshold for considering a sample as
#' having inconsistent expression with up-regulated gene-set.
#' 2) "up_thresh.high" - a GSVA score threshold for considering a sample as
#' having expression consistent with the up-regulated gene-set up-regulated gene
#' set
#' 3) "dn_thresh.low" - a GSVA score threshold for considering a sample as
#' having consistent expression with down-regulated gene-set
#' 4) "dn_thresh.high" - a GSVA score threshold for considering a sample as
#' having inconsistent expression with the down-regulated gene-set.
#' Samples that have consistent expression with both the up-regulated and
#' down-regulated gene-sets of the signature are classified as "Active", those
#' with inconsistent expression with both parts of the signature are classified
#' as "Inactive" and the rest of the samples are classified as "Uncertain".
#' @author Anisha Thind \email{a.thind@@cranfield.ac.uk}
#' @param expr_mat Normalised expression data set matrix comprising the
#' expression levels of genes (rows) for each sample (columns) in a data set.
#' Row names are gene symbols and column names are sample IDs / names. Gene
#' expression matrices can contain normalised (logCPM transformed) RNASeq or
#' microarray transcriptomic data.
#' @param sig_df Gene expression signature for a specific pathway given as data
#' frame with the first column named "gene" containing a list of genes that are
#' the most differentially expressed when the given pathway is active and the
#' second column named "expression" containing their corresponding expression:
#' -1 for down-regulated genes and 1 for up-regulated genes.
#' @param up_thresh.low Number denoting the absolute GSVA score threshold for
#' categorizing a sample as having inconsistent expression with the up-regulated
#' gene-set from the gene signature.
#' @param up_thresh.high Number denoting the absolute GSVA score threshold for
#' categorizing a sample as having consistent expression with the up-regulated
#' gene set from the gene signature.
#' @param dn_thresh.low Number denoting the absolute GSVA score threshold for
#' categorizing a sample as having consistent expression with the down-regulated
#' gene-set from the gene signature.
#' @param dn_thresh.high Number denoting the absolute GSVA score threshold for
#' categorizing a sample as having inconsistent expression with the
#' down-regulated gene-set from the gene signature.
#'
#' @return A data frame containing a list of samples as the first column and
#' their classified pathway activity (Active, Inactive or Uncertain) in the
#' second column.
#' @export
#'
#' @examples
#' # Default thresholds for up-regulated and down-regulated gene-sets
#' \dontrun{classes_df <- classify_gsva_abs(ER_dataset, ER_sig, up_thresh.low=-0.25,
#'      up_thresh.high=0.25, dn_thresh.low=-0.25, dn_thresh.high=0.35)}
classify_gsva_abs <- function(expr_mat,
                              sig_df,
                              up_thresh.low,
                              up_thresh.high,
                              dn_thresh.low,
                              dn_thresh.high) {
  # check thresholds
  if (!is.numeric(up_thresh.high) && !is.numeric(dn_thresh.high) &&
      !is.numeric(up_thresh.low) && !is.numeric(dn_thresh.low)) {
    stop("All thresholds provided must be numbers.")
    # reverse order if the low threshold is larger than the high threshold
  } else if (up_thresh.low > up_thresh.high) {
    stop(
      "The high expression threshold for up-regulated gene-set
    (up_thresh.high) must be higher than the low threshold for the up-regulated
    gene-set (up_thresh.low)"
    )
  } else if (dn_thresh.low > dn_thresh.high) {
    stop(
      "The high expression threshold for down-regulated gene-set
    (dn_thresh.high) must be higher than the low threshold for down-regulated
    gene-set (dn_thresh.low)"
    )
  }
  scores <- run_gsva(expr_mat, sig_df)
  classes_df <-
    classify(scores,
              up_thresh.low,
              up_thresh.high,
              dn_thresh.low,
              dn_thresh.high)
  return(classes_df)
}

#' Sample classification according to pathway activity using a percentile
#' threshold for assessing expression consistency with  both the up-regulated
#' and down-regulated gene-set of a gene signature.
#' @description Classifies samples according to pathway activity by first ranking
#' samples by their expression abundance of the up-regulated gene set and then
#' the down-regulated gene-set using GSVA scores generated by the GSVA algorithm as
#' measures of expression abundance. Samples are then assessed for
#' expression consistency with both the up-regulated and down-regulated
#' gene-sets using percentile thresholds during the pathway activity sample
#' classification.
#'
#'
#' @author Anisha Thind \email{a.thind@@cranfield.ac.uk}
#' @param expr_mat Normalised expression data set matrix comprising the
#' expression levels of genes (rows) for each sample (columns) in a data set.
#' Row names are gene symbols and column names are sample IDs / names. Gene
#' expression matrices can contain normalised (logCPM transformed) RNASeq or
#' microarray transcriptomic data.
#' @param sig_df Gene expression signature for a specific pathway given as data
#' frame with the first column named "gene" containing a list of genes that are
#' the most differentially expressed when the given pathway is active and the
#' second column named "expression" containing their corresponding expression:
#' -1 for down-regulated genes and 1 for up-regulated genes.
#' @param percent_thresh Percentile threshold (0-100) of samples for checking
#' consistency of gene expression of a sample with first the up-regulated and
#' then down-regulated gene-set of the gene signature (default= 25% (quartile)).
#' For example, using the 25% percentile threshold samples ranked in the top 25%
#' and bottom 25% of the up-regulated and down-regulated gene-sets respectively,
#' would be  considered as "Active". Likewise, samples ranked in the bottom 25%
#' and top 25% of the up-regulated and down-regulated gene-set of the gene
#' signature would be classified as "Inactive".
#'
#' @return A data frame with the first column named "sample" containing sample
#' names and the second column named "class" containing their corresponding
#' predicted pathway activity classes (Active, Inactive or Uncertain).
#' @importFrom stats quantile
#' @export
#'
#' @examples
#' # default using quartile threshold (25th percentile)
#' \dontrun{classes_df <- classify_gsva_percent(ER_data_mat, ER_sig)}
#' # custom percentile threshold e.g. 30th percentile
#' \dontrun{classes_df <- classify_gsva_percent(ER_data_mat, ER_sig,
#'        percent_thresh=30)}
classify_gsva_percent <-
  function(expr_mat, sig_df, percent_thresh = 25) {
    # check threshold is a number between 0-100%
    thresh <- tryCatch(percent_thresh / 100, error=function(e){
      stop("Percentile threshold is not a number.")
    })
    scores <- run_gsva(expr_mat, sig_df)
    # compute percentiles
    tryCatch(
      up_thresh <- quantile(scores$Up[, 1], c(thresh, 1 - thresh)),
      error = function(e) {
        stop("Percentile threshold given is not a number between 0 and 100.")
      }
    )
    dn_thresh <- quantile(scores$Down[, 1], c(thresh, 1 - thresh))
    classes_df <-
      classify(
        scores,
        up_thresh.low = up_thresh[1],
        up_thresh.high = up_thresh[2],
        dn_thresh.low = dn_thresh[1],
        dn_thresh.high = dn_thresh[2]
      )
    return(classes_df)
  }

#' GSVA score density distribution plot
#' @description Plots GSVA scores distribution across samples after performing
#' GSVA algorithm on samples in a dataset (gene expression matrix) for the
#' up-regulated and down-regulated gene-sets of a given gene expression
#' signature.
#' @author Anisha Thind \email{a.thind@@cranfield.ac.uk}
#' @param expr_mat Normalised expression data set matrix comprising the
#' expression levels of genes (rows) for each sample (columns) in a data set.
#' Row names are gene symbols and column names are sample IDs / names. Gene
#' expression matrices can contain normalised (logCPM transformed) RNASeq or
#' microarray transcriptomic data.
#' @param sig_df Gene expression signature for a specific pathway given as data
#' frame with the first column named "gene" containing a list of genes that are
#' the most differentially expressed when the given pathway is active, and the
#' second column named "expression" containing their corresponding expression in
#' the gene signature: -1 for down-regulated genes and 1 for up-regulated genes.
#'
#' @return A density plot displaying distribution of GSVA scores obtained for
#' the samples using up-regulated and down-regulated gene-sets from the gene
#' signature
#' @importFrom reshape2 melt
#' @import ggplot2
#' @export
#'
#' @examples
#' \dontrun{gsva_scores_dist(ER_dataset, ER_sig)}
gsva_scores_dist <- function(expr_mat, sig_df) {
  # bind Scores variable locally to function
  Score <- NULL
  # run GSVA using data provided
  gsva_scores <- run_gsva(expr_mat, sig_df)

  sortedScores <- cbind(gsva_scores$Up, gsva_scores$Down)

  # reshape data for plotting
  meltScores <- reshape2::melt(
    sortedScores,
    id.vars = NULL,
    measures.vars = c("Up", "Down"),
    variable.name = "Geneset",
    value.name = "Score"
  )

  levels(meltScores$Geneset) <- c("Up-regulated Gene Signature",
                                  "Down-regulated Gene Signature")

  # density plot
  plot <- ggplot(data = meltScores, aes(x = Score)) +
    geom_density(fill = "#69b3a2", alpha = 0.8) +
    xlab("GSVA Score") +
    ylab("Density") +
    theme_bw() +
    scale_y_continuous(expand = c(0, 0)) +
    scale_x_continuous(breaks = seq(-1, 1, 0.2)) +
    facet_grid( ~ levels(Geneset))
  return(plot)
}


#' Performs GSVA algorithm using both up-regulated and down-regulated gene-sets
#' of the gene signature
#' @description Generates GSVA scores for each sample generated by running GSVA
#' algorithm on the two gene-sets of the gene signature provided.
#' @author Anisha Thind \email{a.thind@@cranfield.ac.uk}
#' @param expr_mat Normalised expression data set matrix comprising the
#' expression levels of genes (rows) for each sample (columns) in a data set.
#' Row names are gene symbols and column names are sample IDs / names. Gene
#' expression matrices can contain normalised (logCPM transformed) RNASeq or
#' microarray transcriptomic data.
#' @param sig_df Gene expression signature for a specific pathway given as data
#' frame with the first column named "gene" containing a list of genes that are
#' the most differentially expressed when the given pathway is active and the
#' second column named "expression" containing their corresponding expression:
#' -1 for down-regulated genes and 1 for up-regulated genes.
#' @keywords internal
#'
#' @return GSVA scores in the form of a list, containing two data frames: GSVA
#' scores for up-regulated gene-set for each sample, and GSVA scores for the
#' down-regulated gene-set GSVA for each sample
#' @importFrom GSVA gsva
#' @noRd
#' @examples
#' \dontrun{run_gsva(ER_dataset, ER_sig)}
run_gsva <- function(expr_mat, sig_df) {
  # check signature arg is data frame
  check_sig_df(sig_df)

  # check input is input matrix
  if (!is.matrix(expr_mat)) {
    stop("expr_mat argument for expression dataset provided is not a matrix object.")
  }

  if(!is.numeric(expr_mat)){
    stop("Expression data matrix contains non-numerical data.")
  }

  # check for duplicate samples
  expr_mat <- duplicate_samples(expr_mat)

  # create list of gene sets (up-regulated and then down regulated) for gsva
  sigs <- list()
  sigs$up <- sig_df[sig_df$expression == 1, 1]
  sigs$dn <- sig_df[sig_df$expression == -1, 1]

  # run GSVA on expression data using 2 gene sets (up-regulated and
  # down-regulated) of the signature
  if (typeof(expr_mat) == "double" && all(expr_mat %% 1 == 0)) {
    # If the data is of type integer, these are raw counts and follow Poisson
    scores <- gsva(expr_mat, sigs, kcdf = "Poisson", verbose = F)
  } else if (typeof(expr_mat) == "double") {
    scores <- gsva(expr_mat, sigs, verbose = F)
  } else {
    stop(
      "Expression dataset contains non-numerical data. Try pre-processing dataset before classification."
    )
  }

  # transpose the matrix
  scores <- t(scores)
  # create an up and down regulated matrix
  scores_up <- as.data.frame(scores[, 1], row.names = rownames(scores))
  colnames(scores_up) <- "Up"
  scores_dn <- as.data.frame(scores[, 2])
  colnames(scores_dn) <- "Down"

  # sort GSVA scores in descending order for the up-regulated
  # and down-regulated set
  sorted_up <- scores_up[order(scores_up$Up, decreasing = T), , drop = F]
  sorted_dn <-
    scores_dn[order(scores_dn$Down, decreasing = T), , drop = F]
  return(list("Up" = sorted_up, "Down" = sorted_dn))
}

#' Generic classifying function for classifying samples based on GSVA scores
#'
#' @param gsva_scores A list containing a data frame of samples and their
#' corresponding GSVA scores when running GSVA on the up-regulated gene-set
#' (stored in the "Up" slot), and a data frame with GSVA scores for the same
#' samples when running GSVA on the down-regulated gene-set (stored in the
#' "Down" slot).
#' @param up_thresh Numerical vector containing the low and high threshold for
#' classification when checking inconsistency and consistency respectively,
#' with only the up-regulated gene-set of the gene signature
#' @param dn_thresh Numerical vector containing the low and high threshold for
#' classification when checking inconsistency and consistency respectively with
#' only the down-regulated gene-set of the gene signature
#' @keywords internal
#'
#' @return A data frame with the first column named "sample" containing the
#' sample IDs / names and the second column named "class" containing pathway
#' activity class labels for each sample i.e. "Active", "Inactive" or
#' "Uncertain".
#' @noRd
#' @examples
#' \dontrun{classes_df <- classify(gsva_scores, up_thresh, dn_thresh)}
classify <-
  function(gsva_scores,
           up_thresh.low,
           up_thresh.high,
           dn_thresh.low,
           dn_thresh.high) {
    if (missing(up_thresh.high) || missing(dn_thresh.high) ||
        missing(up_thresh.low) || missing(dn_thresh.low)) {
      stop(
        "Function requires thresholds for classifying samples using GSVA scores
    generated using the up-regulated and down-regulated gene-set of the gene
         signature."
      )
    }
    # create data frame containing samples and classes
    classes_df <- data.frame(sample = rownames(gsva_scores$Up),
                             class = vector(mode = "character", nrow(gsva_scores$Up)))
    row.names(classes_df) <- classes_df$samples
    classes <- c()
    # Loop through sample rows which are ordered in descending order and checks
    # consistency with up-regulated and down-regulated parts of the gene signature
    classes_list <- sapply(rownames(gsva_scores$Up), function(i) {
      if ((gsva_scores$Up[i, 1] >= up_thresh.high) &&
          (gsva_scores$Down[i, 1] <= dn_thresh.low)) {
        classes[i] <- "Active"
      } else if ((gsva_scores$Up[i, 1] <= up_thresh.low) &&
                 (gsva_scores$Down[i, 1] >= dn_thresh.high)) {
        classes[i] <- "Inactive"
      } else {
        classes[i] <- "Uncertain"
      }
      return(classes)
    })

    # convert list to vector
    classes <-
      factor(classes_list, levels = c("Active", "Inactive", "Uncertain"))

    # add vector to pathway df
    classes_df$class <- classes
    cat("Summary of sample classification based on pathway activity:\n")
    cat("--------------------------------------------------------------\n")
    cat("Number of samples in each pathway activity class:\n")
    print(table(classes_df$class))
    cat(sprintf("\nTotal number of samples: %d", nrow(classes_df)))
    classified <-
      classes_df[classes_df$class %in% c("Active", "Inactive"), ]
    cat(sprintf("\nTotal number of samples classified: %d\n", nrow(classified)))
    return(classes_df)
  }
