#!/usr/bin/perl

# calculate the number of false positives and negatives between two surveys.
use warnings;
use strict;
use IO::File;
use List::Util;
use utf8;

my $file1 = $ARGV[0] || die "Please pass an input file name to process $ARGV[1]\n";
my $outfile = $ARGV[1] || die "Please pass an output file name to process\n";
my $replicates = $ARGV[2] || die "Please pass the number of replicates\n";
my $numberToCombine = $ARGV[3] || die "Please pass the number of surveys to combine\n";

print "usage groupedSurveys surveysFile outputFileName #replicates #surveys\n";

my %results = ();
my @cutline;
my @surveys2;
my $numberOfSurveys;
my @random_set=();
my $totalNumberOfSpeciesFound = 0;
my $totalNumberOfFalsePositivesFound = 0;
my $totalNumberOfTruePositivesFound = 0;
my $totalOfTwoSurveys = 0; #combining two surveys just for the purpose of true positives
my $totalOfTwoSurveysRP = 0;
my $totalOfTwoSurveysFP = 0;
my $SumOfFalsePositivesFound = 0;
my $SumOfTruePositivesFound = 0;
my $rp = 0;
my $fp = 0;
my @results;
my @resultsFP; #False positives
my @resultsRP; #Real positives
my $count = 0;
my %seen;
my %h;


open(my $fhIn1, "<", $file1)
	or die "cannot open < input1.txt: $!";

open(my $fhOut, ">", $outfile) 
	or die "cannot open > output.txt: $!";

my @surveys = <$fhIn1>;

#copy the list of surveys
@surveys2 = @surveys;
$numberOfSurveys = @surveys;
my @output = ("0") x 290;
my @outputFP = ("0") x 290;
my @outputRP = ("0") x 290;

for (my $i=0; $i <= $replicates-1; $i++){ #loop over the number of replicates 
	@random_set = unique_random_list(1,$numberOfSurveys,$numberToCombine);
	
	for (my $k=0; $k <= $numberToCombine-1; $k++) { #loop over the chosen surveys
		@cutline = split /\t/,$surveys[$random_set[$k]];
		for (my $m=0; $m <= $#cutline; $m++) { #loop over each species
			if($cutline[$m] =~ /^\d+$/){
				#print "=$m - $cutline[$m],";
				if($cutline[$m] != 0 && $cutline[$m] != 1 && $cutline[$m] != 2){
					#this is just here to check the validity of the input files. The values should be 0, 1 or 2.
					print $fhOut "shouldnt be here $cutline[$m]\n,";
				}

				if($cutline[$m] > 0){
					$output[$m]= $output[$m] + 1;
				}
				else{
					$output[$m] = $output[$m] + 0; #this just avoids ending up with some null values, otherwise it does nothing
				}

				if($cutline[$m] == 1){
					$outputRP[$m]= $outputRP[$m] + 1;
				}
				else{
					$outputRP[$m]= $outputRP[$m] + 0;
				}

				if($cutline[$m] == 2){
					$outputFP[$m]= $outputFP[$m] + 1;
				}
				else{
					$outputFP[$m]= $outputFP[$m] + 0;
				}
			}
			else{
				$output[$m]= $output[$m] . "," . $cutline[$m]; #if it is not a number it is a label, so stick it to the front of the string
			}
		}
	} #end loop over the chosen surveys
	
	#Count up the total number of species left by combining species
	foreach (@output) 
	{
		if($_ =~ /^\d+$/){
			if($_ == $numberToCombine){
				$totalNumberOfSpeciesFound++;
			}
		}
	}

	foreach (@output) 
	{
		if($_ =~ /^\d+$/){
			if($_ >= 2){
				$totalOfTwoSurveys++;
			}
		}
	}

	#Count up the total number of real species in the combined surveys
	foreach (@outputRP)
	{
		if($_ =~ /^\d+$/){
			if($_ == $numberToCombine){
				$totalNumberOfTruePositivesFound++;
			}
		}
	}

	foreach (@outputRP)
	{
		if($_ =~ /^\d+$/){
			if($_ >= 2){
				$totalOfTwoSurveysRP++;
			}
		}
	}
	
	foreach $rp (@outputRP)
	{
		if($rp =~ /^\d+$/){
			if($rp >= 1){
				$SumOfTruePositivesFound++;
			}
		}
	}
	
	#Count up the total number of false positive species in the combined surveys
	foreach (@outputFP)
	{
		if($_ =~ /^\d+$/){
			if($_ == $numberToCombine){
				$totalNumberOfFalsePositivesFound++;
			}
		}
	}

	foreach (@outputFP)
	{
		if($_ =~ /^\d+$/){
			if($_ >= 2){
				$totalOfTwoSurveysFP++;
			}
		}
	}
	
	foreach $fp(@outputFP)
	{
		if($fp =~ /^\d+$/){
			if($fp >= 1){
				$SumOfFalsePositivesFound++;
			}
		}
	}

	@output = (0) x 290;
	@outputRP = (0) x 290;
	@outputFP = (0) x 290;
	@random_set=(); 
	push @results, "$totalNumberOfSpeciesFound,$totalNumberOfTruePositivesFound,$totalOfTwoSurveys, $totalNumberOfFalsePositivesFound, $totalOfTwoSurveysFP, $totalOfTwoSurveysRP, $SumOfTruePositivesFound, $SumOfFalsePositivesFound";

	$totalNumberOfSpeciesFound = 0;
	$totalNumberOfTruePositivesFound = 0;
	$totalNumberOfFalsePositivesFound = 0;
	$totalOfTwoSurveys = 0;
	$totalOfTwoSurveysFP = 0;
	$totalOfTwoSurveysRP = 0;
	$SumOfFalsePositivesFound = 0;
	$SumOfTruePositivesFound = 0;
}

foreach (@results)
{
	$count++;
	print $fhOut "\nTotal number of species found $count, $_";
}
# foreach (@resultsRP)
# {
	# print $fhOut "\nTotal number of real species found: $_";
# }
# foreach (@resultsFP)
# {
	# print $fhOut "\nTotal number of false positives found: $_";
# }

sub unique_random_list {

	#Taken from happy.barney on Jul 28, 2011 at 10:52 UTC at http://www.perlmonks.org/
    my ($from, $to, $count) = @_;

    $count = List::Util::min ($count, $to - $from);

    my @result;
    my @queue = [ $from, $to - $from, $count ];

    while (my $job = shift @queue) {
        my ($from, $length, $count) = @$job;

        if ($count == $length) {
            push @result, $from .. $from + $length;
        } elsif ($count == 1) {
            push @result, $from + int rand $length;
        } else {
            my $split_length = int ($length / 2);
            my $split_count  = List::Util::min (int rand $count, $split_length);

            my $pad_length = $length - $split_length;
            my $pad_count = $count - $split_count;

            $split_count += $pad_count - $pad_length
              if $pad_count > $pad_length;

            unshift @queue, grep $_->[2],
              [ $from, $split_length, $split_count ],
              [ $from + $split_length, $length - $split_length, $count - $split_count ];
        }
    }

    @result;
}