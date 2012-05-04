#!/usr/bin/perl -w

#
# Script CGI per a processar dinàmicament l'ouput de les peticions de LOCKSS 
# Si li arriba un valor del paràmetre "set" concret actua de renderer HTML de l'interfície OAI-MPH per a aquell set,
#  si li arriba un valor del paràmetre "comm2csv" concret, l'interpreta com a un handle_id de DSpace corresponent a una communitat i treu com a output #  el CSV que defineix les seves col·leccions (que seran les AUs dins d'aquella Col·lecció Metaarchive), necessari per el registre al Conspectus. 
#   altrament, actua com a generador dinàmic per defecte de la Manifest Page, exposant totes les coleccions de la instància DSPACE 
#
# Es pot testar a la línia de comandes directament amb:
#  ./Cgi4Lockss (> ManifestPage.html)
#  ./Cgi4Lockss set=hdl_xxxxxx_xxxx (> OAIListRecordsSetxxxx.html )
#  ./Cgi4Lockss resumptionToken=xxxxxx ( > OAIListRecordsSetxxxx2.html)
#  ./Cgi4Lockss comm2csv=xxxx (> commxxxx.csv)
#
# Pre-requisits:
# sudo aptitude install libwww-mechanize-perl libxml-libxslt-perl 
# Si falla tradicional -MCPAN -e 'install WWW::Mechanize' -e 'XML:LibXSLT' o bé XML:LibXSLT::Easy, que no està al apt però encara és més fàcil

use strict;
use utf8;
use CGI; #Passar-ho a CGI:Pretty si el Benchmark en temps de generació no es veu molt perjudicat
use XML::LibXML;
use XML::LibXSLT;
use WWW::Mechanize;

my $webIndex = 'http://84.88.13.203:8080'; # = '.', si aquest script s'emplaça a la mateixa màquina del repositori  
my $webOAIif = $webIndex . '/oai/request';
my $xslSheet = './OaiMph2Html.xsl'; # Copia en local de 'http://metaarchive.org/public/doc/testSites/xmlMetaDataToLockss/smartech-oai.xsl'

my $mech;
my $sublink;
my $out = new CGI;

# L'script actua com a HTML renderer del output OAI XML (si no rep els parametres GET 'set' o 'resumptionToken' [que sol·licita els següents registres als mostrats per una acció 'set' anterior]
if ( defined($out->param('set')) || defined($out->param('resumptionToken')) ){ 

        die "CGI Bad Request (paràmetres comm2csv, set i resumptionToken incompatibles)." if (defined($out->param('comm2csv')) || (defined($out->param('set')) && defined($out->param('resumptionToken'))));
 	
	#Approach XML::LibXSLT::Easy hagués estat més fàcil, però no està instal·lada per defecte
	my $parser = XML::LibXML->new;
	my $xslt = XML::LibXSLT->new;
	my $stylesheet = $xslt->parse_stylesheet( $parser->parse_file("$xslSheet") );
	my $results = $stylesheet->transform( $parser->parse_file( $webOAIif . '?verb=ListRecords&' . 
		 ( defined($out->param('resumptionToken')) ? 
				('resumptionToken=' . $out->param('resumptionToken')) : 
				( 'metadataPrefix=oai_dc&set=' . $out->param('set'))) ) ); # Norm. del link del Token només va canviant l'última centena
	print $stylesheet->output_string($results);
# Aquest script no entén de la jerarquia lògica del repositori. quan se li passa com a paràmetre un handle de DSpace, sol·licita tots els objectes finals que depenen d'aquest. És a dir, tenint en compte que a DSpace el format dels handles és igual per a tot tipus de nodes, si li passem el handle d'una communitat ens retornarà tot el set d'objectes que són fulles d'aquest arbre obviant els nodes intermitjos, de manera que tindrem tots els documents fills de les seves subcomunitats, col·leccions, subcol·leccions, etc. sense tenir informació del seu parentesc. Per això, en la lògica amb què aplicarem aquest script, el nostre repositori serà dissenyat per contemplar solament tres nivells: comunitats (univesitats) > n col·leccions (departaments) > n bitsreams (recursos). Només demanarem els sets corresponents al handle de les col·leccions=departaments. 



# L'script actua com a generador del fitxer csv que enumera tots els Handle IDs corresponents a Col.leccions de DSpace (=AUs=Dept. d'una Universitats), per a aquell HandleID d'una communitat concreta que se li passi comm2csv=hdl_id_comm. El csv resultant és el fitxer que s'haurà de pujar al conspectus per a indicar quines col·leccions de DSpace composen les AUs d'una col·lecció nostra a Metaarchive.
} elsif ( defined($out->param('comm2csv')) ) {
		
	my $commID = $out->param('comm2csv'); 
	$mech = WWW::Mechanize->new;

	$mech->get( "$webIndex" );
	die "Error accedint a la pàgina principal del repositori", $mech->response->status_line unless $mech->success;

	$mech->follow_link ( url_regex => qr/handle\/\d+\/$commID\/?$/i );
	die "Error accedint a la pàgina d'una comunitat: No s'ha trobat l'Id de la comunitat indicat.", $mech->response->status_line unless $mech->success;
	
	$mech->content =~ /Recent.*?<a\shref="(.*?)">/si;
	my $firstRecSubmi = $1;

	my @collections = $mech->find_all_links( url_regex => qr/handle\/\d+\/\d+\/?$/i );

	for my $sublink ( @collections ) {
   		if ( $sublink eq $collections[0] ) {
           		print $out->header(-type=>'application/octet-stream',
                        	           -attachment=>'foo.csv');
            		print "base_url2, instance_id, hdl_id\n";
		} elsif ( $sublink->url eq $firstRecSubmi ) { 
			last;
   		} else {
        		$sublink->url =~ m!/handle/(\d+)/(\d+)/?!i;
        		printf ("%s, %s, %s\n", $webIndex, $1, $2 );
   		}	
	}

# L'script actua com a generador de la ManifestPage (comportament per defecte, és a dir, quan no sol·licitem exlpícitament cap set) 
} else {

	$mech = WWW::Mechanize->new;

	$mech->get( "$webIndex" );
	die "Error accedint a la pàgina principal del repositori", $mech->response->status_line unless $mech->success;

	# Per títol en comptes de per URL seria:
	# my @links = $mech->find_all_links( text_regex => qr/Universi/i );
	my @communities = $mech->find_all_links( url_regex => qr/handle\/\d+\/\d+\/?$/i );
	
	print $out->header(), #$out->header(-charset => 'utf-8'),
	      $out->start_html('Col·leccions a Preservar'),
	      $out->h2('Col·leccions a Preservar'),
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
		            [ 'Conspectus Collection(s): This demonstration site has no conspectus entry CANVIAR!', 
		              'Institution: MetaArchive Org', 
		              'Contact Info: ' . $out->a( { -href => 'mailto:support@metaarchive.org' }, 'support at metaarchive.org' ) 
		            ]
		  ) 
	      );

	for my $link ( @communities ) {
	    $mech->get($link->url_abs);
 	    die "Error accedint a la pàgina d'una comunitat", $mech->response->status_line unless $mech->success;
	 
  	    $mech->content =~ /Recent.*?<a\shref="(.*?)">/si;
	    my $firstRecSubmi = $1;

	    my @collections = $mech->find_all_links( url_regex => qr/handle\/\d+\/\d+\/?$/i );

	    for my $sublink ( @collections ) {
	       if ( $sublink eq $collections[0] ) { 
	       	     print $out->br,
		     	   $out->h2( 'Comunitat: ', $out->a({ -href => $link->url_abs }, $link->text) );
	       } elsif ( $sublink->url eq $firstRecSubmi ){
			last;
	       } else {

		  s/^(.*)handle/hdl/ , tr/\//_/  for my $set = $sublink->url;
                 
		  print $out->h3('Archival Unit: ', $out->a( { -href => $sublink->url_abs }, $sublink->text ) ),   
		        $out->ul(
		           $out->li(
		               [ $out->a( { -href => $webOAIif . '?verb=ListRecords&metadataPrefix=oai_dc&set=' . $set }, ' OAI:DC XML Set ' ),
		                 $out->a( { -href => $out->url() . '?set=' . $set }, ' Crawlable HTML Set ' )
		               ]
		           )
		        );
	     }
	   }
	}

	print $out->hr,
	      $out->end_html;
}
# * Exception handling: http://search.cpan.org/~lds/CGI.pm-3.43/CGI.pm#RETRIEVING_CGI_ERRORS i http://docstore.mik.ua/orelly/linux/cgi/ch05_05.htm
