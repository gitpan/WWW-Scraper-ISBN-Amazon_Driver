use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		=> 'WWW::Scraper::ISBN::Amazon_Driver',
    'VERSION'	=> '0.11',
    'PREREQ_PM'		=> {

		WWW::Scraper::ISBN			=> 0.25,
		WWW::Scraper::ISBN::Driver	=> 0.18,
		WWW::Mechanize				=> 0,
		Template::Extract			=> 0,
		Test::More					=> 0.45,	# for testing
	},
	NO_META			=> 1,

    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT => 'Search drivers for the Amazon online catalog',
       AUTHOR     => 'Barbie <barbie@cpan.org>') : ()),
);
