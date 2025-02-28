% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calculate_accuracy.R
\name{calculate_accuracy}
\alias{calculate_accuracy}
\title{Accuracy calculation of classification method}
\usage{
calculate_accuracy(true_labels, predicted_labels, pathway, show_stats = FALSE)
}
\arguments{
\item{true_labels}{a data frame, matrix or file name which contains a
column named "sample" that consists of sample names / IDs and another column
named after a specific pathway which contains the corresponding true pathway
activity labels.}

\item{predicted_labels}{a predicted labels data frame or matrix
generated by the classification method yielding predicted pathway activity
labels in a column called "class" for the samples in the "sample" column.}

\item{pathway}{name of pathway used for classification (Note: this pathway
name must be present in the true labels data frame / matrix / file name for
classification evaluation and generation of the confusion matrix.)}

\item{show_stats}{an optional flag to display additional statistical
information using the confusion matrix and other classification evaluation
metrics including: sensitivity, specificity, precision, false positive rate,
false negative rate etc.}
}
\value{
confusion_matrix
}
\description{
This method provides several classification evaluation metrics
to assess the accuracy of predicted pathway classification.
The accuracy calculation is performed using predicted pathway
activity labels from the employed classification method for each sample and
the corresponding true activity labels for the given pathway. A confusion
matrix is created to display the classification accuracy decomposed into the
distinct pathway activity classes in tabular form for the user. Additional
classification evaluation statistics (such as sensitivity, specificity,
recall, percentage of classified samples etc) is the optional feature that
the user can specify.
}
\examples{
\dontrun{calculate_accuracy(true_labels_df, predicted_labels_df, "ER",
show_stats= TRUE)}
}
\author{
Ozlem Karadeniz \email{ozlem.karadeniz.283@cranfield.ac.uk}
}
