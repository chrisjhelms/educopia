#!/usr/bin/perl -w

#
# Script CGI per a processar dinàmicament l'ouput de les peticions de LOCKSS 
# Si li arriba un valor del paràmetre "set" concret actua de renderer HTML de l'interfície OAI-MPH per a aquell set,
#   altrament, actua com a generador dinàmic per defecte de la Manifest Page, exposant totes les coleccions de la instància DSPACE 
#

# Prerequisits:
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
my $cgiCntxt = '/lockss';

my $out = new CGI;

 
# Aquest script no entén de la jerarquia lògica del repositori. quan se li passa com a paràmetre un handle de DSpace, sol·licita tots els objectes finals que depenen d'aquest. És a dir, tenint en compte que a DSpace el format dels handles és igual per a tot tipus de nodes, si li passem el handle d'una communitat ens retornarà tot el set d'objectes que són fulles d'aquest arbre obviant els nodes intermitjos, de manera que tindrem tots els documents fills de les seves subcomunitats, col·leccions, subcol·leccions, etc. sense tenir informació del seu parentesc. Per això, en la lògica amb què aplicarem aquest script, el nostre repositori serà dissenyat per contemplar solament tres nivells: comunitats (univesitats) > n col·leccions (departaments) > n bitsreams (recursos). Només demanarem els sets corresponents al handle de les col·leccions=departaments. 
 
# L'script actua com a HTML renderer del output OAI XML (si no rep els parametres GET 'set' o 'resumptionToken' [que sol·licita els següents registres als mostrats per una acció 'set' anterior]
if ( "" ne $out->param('set') || "" ne $out->param('resumptionToken')){ 
	#Approach XML::LibXSLT::Easy hagués estat mñes facil, però no està instal·lada per defecte
	my $parser = XML::LibXML->new;
	my $xslt = XML::LibXSLT->new;
	my $stylesheet = $xslt->parse_stylesheet( $parser->parse_file("$xslSheet") );
	my $results = $stylesheet->transform( $parser->parse_file( $webOAIif . '?verb=ListRecords&metadataPrefix=oai_dc&' . 
                 ("" ne $out->param('resumptionToken')) ? ('resumptionToken=' . $out->param('resumptionToken')) : ( 'set=' . $out->param('set')) ) );
	print $stylesheet->output_string($results);

# L'script actua com a generador de la ManifestPage (comportament per defecte, és a dir, quan no sol·licitem exlpícitament cap set) 
} else {

	my $sublink;
	my $mech = WWW::Mechanize->new;

	$mech->get( "$webIndex" );
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
	    my @collections = $mech->find_all_links( url_regex => qr/handle\/\d+\/\d+\/?$/i );

	    for my $sublink ( @collections ) {
	       if ( $sublink eq $collections[0] ) { 
	       	     print $out->br,
		     	   $out->h2( 'Comunitat: ', $out->a({ -href => $link->url_abs }, $link->text) );
	       } else {

		  s/\/handle/hdl/ , tr/\//_/  for my $set = $sublink->url;
                 
		  print $out->h3('Archival Unit: ', $out->a( { -href => $sublink->url_abs }, $sublink->text ) ),   
		        $out->ul(
		           $out->li(
		               [ $out->a( { -href => $webOAIif . '?verb=ListRecords&metadataPrefix=oai_dc&set=' . $set }, ' OAI:DC XML Set ' ),
		                 $out->a( { -href => './' . $cgiCntxt . '?set=' . $set }, ' Crawlable HTML Set ' )
		               ]
		           )
		        );
	     }
	   }
	}

	print $out->hr,
	      $out->end_html;
}
