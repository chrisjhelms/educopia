#!/usr/bin/perl -w

# Disclaimer: This script does not understand of logical jerarquies of the repositories. When a DSpace's HandleID is passed as a parameter, script requests all the final objects depending of it. Having in mind that Dspace's Handles format are equal for all kind of nodes, if we pass a handle to the script it will return the total set of objects which are leafs of the present tree ignoring intermediate nodes, so we will be collecting all childhood documents whether they are from the subcommunities, collections or subcollections, without preserving information about they parenthood. That is why our data wrangling strategy has been designed (and implemented in DSpace) according to 3 levels: comunities (institutions) > n collections (departments) > n bitsreams (items). We only will request sets corresponding to the handleIDs mapped to collections=departments.
#We also should take into account that this strategy is valid when every Dspace Collection is known to hold up a maximum of 20GB.


#
# CGI script to dynamically process the output of LOCKSS requests
# This is the generic relase of the script: it always expectes webIndex and webOAIif as a parameters (must use the generic XSLT sheet and be used by the generic Plugin)
# If a concrete "set" comes as a parameter, it acts as an HTML renderer of the OAI-MPH response for that set.
# If a concrete "comm2csv" comes as a parameter, it is interpreted as a handle_id corresponding to a community-lervel DSpace entry and outputs a CSV document that defines all its collections (they will be the AUs inside this MetaaArchive Collection), asked by Conspectus. 
# ...other way, acts as a dynamical generator of the Manifest Page, exposing all the communities and collections of the targeted Dspace instance.
#
# We can test the script directly in the CLI by means of:
#  ./Cgi4Lockss (webIndex=<URL>&webOAIif=<URL>) (> ManifestPage.html)
#  ./Cgi4Lockss (webIndex=<URL>&webOAIif=<URL>) set=hdl_xxxxxx_xxxx (> OAIListRecordsSetxxxx.html )
#  ./Cgi4Lockss (webIndex=<URL>&webOAIif=<URL>) resumptionToken=xxxxxx ( > OAIListRecordsSetxxxx2.html)
#  ./Cgi4Lockss (webIndex=<URL>&webOAIif=<URL>) comm2csv=xxxx (> commxxxx.csv)
#
# Or throught localhost:8080/LOCKSS(?var=val) as well, if we start up the application with Plack from the folder that contains the script and the XSL sheet.
#
# /dirScripts$ plackup -D -s Starman -MPlack::App::WrapCGI -MPlack::Builder -e 'builder { mount "/LOCKSS" => Plack::App::WrapCGI->new(script => "./Cgi4Lockss.pl")}' --preload-app --port 8080
#
# Pre-requirements:
# sudo yum install perl-Plack perl-XML-LibXSLT perl-XML-LibXML perl-WWW-Mechanize #sudo aptitude install libwww-mechanize-perl libxml-libxslt-perl libplack-perl 
# If it fails, do it from perl, yet we might need some strictly OS driver file only contained in the previous packages:
# $ env PERL_MM_USE_DEFAULT=1 cpan install CGI WWW::Mechanize XSLT XML:LibXSLT Plack Plack::Handler::Starman CGI::Emulate::PSGI   
# (if we don't got cpan CLI, directly with perl -MCPAN -e 'install <module>'. ' 
#

use strict;
use utf8;
use CGI; #Migrate it to CGI:PSGI if the Benchmark in generation time is too perjudicated
#use CGI::Carp; # Debug mode: qw( fatalsToBrowser ); #Plack already got a debugger 
use URI::URL;
use XML::LibXML;
use XML::LibXSLT;
use WWW::Mechanize;

$| = 1; # Output Buffering Off > ¿Fast::CGI for it?
$CGI::DISABLE_UPLOADS = 1; # Disable uploads for security
$CGI::POST_MAX        = 0;

my $mech;
my $sublink;
my $out = new CGI;


### VARIABLES ###
$out->delete('webIndex') unless $out->param('webIndex'); #This deletes the request parameters if they are empty. It is useful because the plugin builds 
$out->delete('webOAIif') unless $out->param('webOAIif'); #                             URLs by default from parameters, either they have a value or not.
my $webIndex = $out->param('webIndex') || $out->url(-base => 1); # By default, we assume REPO_INDEX_URL=<CGISCRIPT_HOSTBASE>  
my $webOAIif = $out->param('webOAIif') || 'http://' . URI::URL->new($webIndex)->netloc || 'ErrorIdentifyingWebIndexURLHost' . '/oai/request'; # $webIndex . '/oai/request' will be meaningful, if we always put OAI context over the base)
my $xslSheet = './OaiMph2Html.xsl'; # Locally modified copy of 'http://metaarchive.org/public/doc/testSites/xmlMetaDataToLockss/smartech-oai.xsl'
$out->delete('webIndex','webOAIif','verb'); # We discard the OAI verb, we always execute a ListRecords if a Set/Token parameter arrives
#################

# Script acting as dynamical generator of the ManifestPage (default behaviour, i.e, when no set/resumptionToken/CSv is explicitly requested 
# Unless (If not) defined any of the 3 expected parameters
unless( $out->param ) {

	$mech = WWW::Mechanize->new;
	eval {
		$mech->get( "$webIndex" );
     		1;
	} or do {error($out,"URL/connection Error to the main page of repository ".$webIndex.".")};
	$mech->success or error($out,"Repository has replied an error message while trying to access its main page ".$webIndex.".");

	# To parse links by means of the title, if they were uniformed, instead of URL:
	# my @links = $mech->find_all_links( text_regex => qr/Universi/i );
	my @communities = $mech->find_all_links( url_regex => qr{/handle/\d+/\d+/?$}i );
 	error($out,"No links to communities have been found on the given repository's web  ".$webIndex.".") unless ( @communities ); 	

	print $out->header(), 
	      $out->start_html('Collections to Preserve'),
	      $out->h2('Collections to Preserve'),
	      $out->h4(
		  $out->img( { alt => 'MetaArchive logo' , src => 'http://www.metaarchive.org/public/images/favicon.ico' } ),
		  'Manifest Page to Allow preservation by LOCKSS daemons in the ',
		  $out->a( { href => 'http://www.metaarchive.org' }, 'MetaArchive Network' ),
		  $out->br,
		  $out->img( { alt => 'LOCKSS logo' , src => 'http://www.lockss.org/favicon.ico' } ),
		  ' LOCKSS system has permission to collect, preserve, and serve this Archival Unit.'
	      ),
	      $out->p('Collection Info:'),
	      $out->ul( 
		  $out->li( 
		            [ 'Conspectus Collection(s): This demonstration site has no conspectus entry ADAPT IT TO YOUR CASE!!', 
		              'Institution: MetaArchive Org', 
		              'Contact Info: ' . $out->a( { -href => 'mailto:support@metaarchive.org' }, 'support at metaarchive.org' ) 
		            ]
		  ) 
	      );

	for my $link ( @communities ) {
	
	    $link->url_abs =~ m{/handle/\d+/(\d+)/?}i;    #Identify Community ID
	    my $commID = $1;

	    eval{
		$mech->get($link->url_abs);
	    	1;
            } or do {error($out,"URL/connection error when following a link to a community page.")};
 	    $mech->success or error($out,"Repository has replied an error message while trying to follow a link to the community/institution ".$commID."'s page.");
	
  	    $mech->content =~ /Recent.*?<a\shref="(.*?)">/si; # Identify and save the first link which does not correpsond to a collection (First Recent Submissions area's link)
	    my $firstRecSubmi = $1;

	    my @collections = $mech->find_all_links( url_regex => qr{/handle/\d+/\d+/?$}i );

	    for my $sublink ( @collections ) {
		if ( $sublink eq $collections[0] ) { # If first iteration, link should be the same own link of community as first 'seen'
		    ( $link->url_abs eq $sublink->url_abs ) or error($out, "First collection's link was expected to be identical to the one of the community. Inspect expected link formats.");
	       	     print $out->br,
                           $out->h2( 'Community: ', $out->a({ -href => $link->url_abs }, $link->text) , $out->a({ -href => $out->url . '?webIndex=' . $webIndex . '&webOAIif=' . $webOAIif . '&comm2csv=' . $commID }, ' (CSV) ') );
	       } elsif ( $sublink->url eq $firstRecSubmi ){
			last;
	       } else {

		  s/^(.*)handle/hdl/ , tr/\//_/  for my $set = $sublink->url;
                 
		  print $out->h3('Archival Unit: ', $out->a( { -href => $sublink->url_abs }, $sublink->text ) ),   
		        $out->ul(
		           $out->li(
		               [ $out->a( { -href => $webOAIif . '?verb=ListRecords&metadataPrefix=oai_dc&set=' . $set }, ' OAI:DC XML Set ' ),
		                 $out->a( { -href => $out->url . '?webIndex=' . $webIndex . '&webOAIif=' . $webOAIif . '&set=' . $set   }, ' Crawlable HTML Set ' )
		               ]
		           )
		        );
	     }
	   }
	}

	print $out->hr,
	      $out->end_html;


# Script acting as a generator for the CSV file which ennumerates all the handle IDs corresponding to Dspace Collections (=AUs, presumably) for any HandleID passed as argument comm2csv=hdl_id_comm. Resulting CSV can be uploaded to Conspectus in order to indicate which DSpace Collections compose the AUs of a Metaarchive's collection to preserve.
} elsif ( $out->param == 1 && $out->param('comm2csv') ) {
		
	my $commID = $out->param('comm2csv'); 
	$mech = WWW::Mechanize->new;

	eval{
		$mech->get( "$webIndex" );
        	1;
        } or do {error($out,"URL/connection Error to the main page of repository ".$webIndex.".")};
	$mech->success or error($out,"Repository has replied an error message while trying to access its main page ".$webIndex.".");

	eval{
		$mech->follow_link ( url_regex => qr{/handle/\d+/$commID/?$}i );
                1;	
        } or do {error($out,"URL/connection error when following the link to community/institution ".$commID.".'s main page. Does it exist?")};
 	$mech->success or error($out,"Repository has replied an error message while trying to follow a link to the community/institution ".$commID."'s page. Does it exist?");
	
	$mech->content =~ /Recent.*?<a\shref="(.*?)">/si;
	my $firstRecSubmi = $1;

	my @collections = $mech->find_all_links( url_regex => qr{/handle/\d+/\d+/?$}i );
        error($out,"No links to collections were found on the community ".$commID."'s page.") unless ( @collections );

	for my $sublink ( @collections ) {
   		if ( $sublink eq $collections[0] ) {
           		print $out->header(-type=>'application/x-download',
                        	           -attachment  => 'AU_comm'.$commID.'.csv' );
 					   # -Content_length  => -s "$path_to_files/$file", # For obtaining progressbar

            		print "dspace_instance, coll_hdl_id, base_url2, oai_interface\n";
		} elsif ( $sublink->url eq $firstRecSubmi ) { 
			last;
   		} else {
        		$sublink->url =~ m{/handle/(\d+)/(\d+)/?$}i;
        		printf ("%s, %s, %s, %s\n", $1, $2, $webIndex, $webOAIif );
   		}	
	}

# Script acting as an HTML renderer of the OAI XML standard output when it receives 'set' or 'resumptionToken' [which asks for the next registers to the ones shown by a previous 'set'] HTTP GET parameters. 
} elsif ( $out->param == 1 && ( $out->param('set') || $out->param('resumptionToken') )) { 
	
	eval{ 
	  my $parser = XML::LibXML->new;
	  my $xslt = XML::LibXSLT->new;
	  my $stylesheet = $xslt->parse_stylesheet( $parser->parse_file("$xslSheet") );
	  my $results = $stylesheet->transform( $parser->parse_file( $webOAIif . '?verb=ListRecords&' . ( $out->param('resumptionToken') ? 
				('resumptionToken=' . $out->param('resumptionToken')) : 
				( 'metadataPrefix=oai_dc&set=' . $out->param('set'))) ) , dspacehome => "'$webIndex'", dspaceoai=> "'$webOAIif'");
                               # Usually, however, Token's link only goes changing the 'hundreds' number at the end
          print $out->header(),
          $stylesheet->output_string($results);
	  1;

        } or do {error($out,"Error transforming OAI-MPH output to HTML. Check that either remote repository's OAI-MPH Interface or local XSLT sheet routes are both accessible by this script.")};

}else{ error ($out, "CGI Bad Request Parameters (Null, not typified or joint of incompatible parameters).", '400 Bad Request') }


#Error Output Page
sub error {
    my( $q, $error_message, $status ) = @_;

    $status='500 Internal Server Error' unless ($status);

    print $q->header( -status=> $status ),
          $q->start_html( 'Error' ),
          $q->h2( 'Error' ),
          $q->hr,
          $q->p( "Request has thrown the next error: " ),
          $q->p( $q->i ( $error_message ) ),
          $q->end_html;
    exit;
}
