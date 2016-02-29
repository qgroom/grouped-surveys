# grouped-surveys

This script was written to examine the effect of combining botanical field surveys from multiple indepentent observers.
The rational is that false-positive observations can be reduced by combining the species lists created by one or more observer. However, this increases the number of false-negative observations. The script bootstraps the selection of surveys and calculates a mean number of false-positive ands false-negative observations when the surveys are combined.

It takes an input matrix in which the columns are species and each row is the results of a survey. Where a species was not found in the survey the value in the column is 0. A 1 signifies that the species was correctly observered in the survey. A 2 signifies that the species was observed in the survey, but was, in fact, absent.

##usage
groupedSurveys.pl surveysFile outputFileName #replicates #surveys

The survey file is the input matrix
replicates is the number of times to repeat the bootstraping.
surveys is the number of surveys in the input to combine.
