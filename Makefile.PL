use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'WWW::Scraper::ISBN::Amazon_Driver',
    'VERSION'	=> '0.04',
    'PREREQ_PM'		=> {

		WWW::Scraper::ISBN			=> 0.25,
		WWW::Scraper::ISBN::Driver	=> 0.18,
		WWW::Mechanize				=> 0,
		Template::Extract			=> 0,
		Test::More					=> 0.45,	# for testing

	},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT => q|Search drivers for the Amazon online catalog|,
       AUTHOR     => 'Barbie <barbie@cpan.org>') : ()),
);
