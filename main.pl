use strict;
use warnings;
use Switch;
use Data::Classifier::NaiveBayes;            #classification
use Lingua::StopWords qw( getStopWords );    #stopwords

sub main {

	my $cl = Data::Classifier::NaiveBayes->new;
	my $training_data = 'test.csv';
	my $ans;
	my $finalquery;


	unless ( open( INPUT, $training_data ) ) {
		die print "Could not open file";
	}

	<INPUT>;    #so avoid reading the labels

	#read training data and set up classifier
	while ( my $w = <INPUT> ) {
		my @line = split( ',', $w );

		$cl->train( $line[0], $line[1] );
	}

	#get list of stop words
	my $stopwords = getStopWords('en');

	do {
		print "1.Submit entry to train\n2.Test query\n3.Exit\nEnter option : ";
		$ans = <STDIN>;

		chomp $ans;

		switch ($ans) {
			case 1 {
				#append data to training set for further use
				unless ( open( OUTPUT, '>>' . $training_data ) ) {
					die print "Output file not opened";
				}

				#set file handler for input to start of file
				seek INPUT, 0, 0;

				<INPUT>;

				print "Enter query : ";
				my $q1 = <STDIN>;
				chomp $q1;		#to remove new line character

				print "Spam or NotSpam?";
				my $q2 = <STDIN>;
				chomp $q2;

				my @var = split( ' ', $q1 );	#array with words from input query

				my @var2 = grep { !$stopwords->{$_} } @var;		#remove stop words

				foreach my$w (@var2)
				{
					print $w . " ";
				}

				foreach my $w (@var2) {
					chomp $w;
					$cl->train( $q2, $w );
					print $q2. "->" . $w . "\n";
					print OUTPUT $q2 . ",", $w . "\n";
				}

				close OUTPUT;
			}

			case 2 {
				print "Enter query : ";
				my $query = <STDIN>;

				my @var = split( ' ', $query );

				my @var2 = grep { !$stopwords->{$_} } @var;

				print "Query after removal of stop words : ";

				foreach my $var (@var2) {
					print $var . " ";
				}

				foreach my $word (@var2) {
					$finalquery = " " . $word;
				}

				print "\n"
				  . "Query classified as : "
				  . $cl->classify($finalquery) . "\n";
			}

			case 3 {
				die print "Thank you for using Spam Classifier\n";
			}

			else {
				print "Enter a valid option\n";
			}
		}
		print "\n";
	} while ($ans);

	close(INPUT);
}

main();
