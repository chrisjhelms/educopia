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
#use CGI::Carp; # Debug mode: qw( fatalsToBrowser ); #Plack ja té un debugger 
use XML::LibXML;
use XML::LibXSLT;
use WWW::Mechanize;


my $webIndex = 'http://84.88.13.203:8080'; # = '.', si aquest script s'emplaça a la mateixa màquina que el repositori  
my $webOAIif = $webIndex . '/oai/request';
my $xslSheet = './OaiMph2Html.xsl'; # Copia en local de 'http://metaarchive.org/public/doc/testSites/xmlMetaDataToLockss/smartech-oai.xsl'

my $mech;
my $sublink;
my $out = new CGI;



# L'script actua com a generador de la ManifestPage (comportament per defecte, és a dir, quan no sol·licitem exlpícitament cap set) 
# Unless (If not) defined any of the 3 expected parameters
unless( $out->param ) {

	$mech = WWW::Mechanize->new;
	eval {
		$mech->get( "$webIndex" );
     		1;
	} or do {error($out,"Error de connexió/URL a la pàgina principal del repositori.")};
	$mech->success or error($out,"El repositori ha tornat una missatge d'error en intentar accedir a la pàgina principal.");

	# Per títol en comptes de per URL seria:
	# my @links = $mech->find_all_links( text_regex => qr/Universi/i );
	my @communities = $mech->find_all_links( url_regex => qr/handle\/\d+\/\d+\/?$/i );
 	error($out,"No s'han trobat enllaços a comunitats a la web del repositori proporcionada.") unless ( @communities ); 	

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
	    eval{
		$mech->get($link->url_abs);
	    	1;
            } or do {error($out,"Error de connexió/URL en seguir l'enllaç a una pàgina d'una comunitat.")};
 	    $mech->success or error($out, "El repositori ha tornat una missatge d'error en intentar seguir l'enllaç a una pàgina d'una comunitat.");
	 
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
		                 $out->a( { -href => $out->url . '?set=' . $set }, ' Crawlable HTML Set ' )
		               ]
		           )
		        );
	     }
	   }
	}

	print $out->hr,
	      $out->end_html;


# L'script actua com a generador del fitxer csv que enumera tots els Handle IDs corresponents a Col.leccions de DSpace (=AUs=Dept. d'una Universitats), per a aquell HandleID d'una communitat concreta que se li passi comm2csv=hdl_id_comm. El csv resultant és el fitxer que s'haurà de pujar al conspectus per a indicar quines col·leccions de DSpace composen les AUs d'una col·lecció nostra a Metaarchive.
} elsif ( $out->param == 1 && $out->param('comm2csv') ) {
		
	my $commID = $out->param('comm2csv'); 
	$mech = WWW::Mechanize->new;

	eval{
		$mech->get( "$webIndex" );
        	1;
        } or do {error($out,"Error de connexió/URL a la pàgina principal del repositori.")};
	$mech->success or error ($out, "El repositori ha tornat una missatge d'error en intentar accedir a la pàgina principal.");

	eval{
		$mech->follow_link ( url_regex => qr/handle\/\d+\/$commID\/?$/i );
                1;
        } or do {error($out,"Error de connexió/URL en seguir l'enllaç a la pàgina principal de la comunitat/institució ".$commID.". Existeix?")};	
	$mech->success or error ($out, "El repositori ha tornat un error en intentar accedir a la pàgina principal de la comunitat/institució ".$commID.". Existeix?");
	
	$mech->content =~ /Recent.*?<a\shref="(.*?)">/si;
	my $firstRecSubmi = $1;

	my @collections = $mech->find_all_links( url_regex => qr/handle\/\d+\/\d+\/?$/i );
        error($out,"No s'han trobat enllaços a col·leccions a la pàgina de la comunitat.".$commID.".") unless ( @collections );

	for my $sublink ( @collections ) {
   		if ( $sublink eq $collections[0] ) {
           		print $out->header(-type=>'application/x-download',
                        	           -attachment  => 'AUs_comm'.$commID.'.csv' );
 					   # -Content_length  => -s "$path_to_files/$file", # Per obtenir progressbar

            		print "base_url2, instance_id, hdl_id\n";
		} elsif ( $sublink->url eq $firstRecSubmi ) { 
			last;
   		} else {
        		$sublink->url =~ m!/handle/(\d+)/(\d+)/?!i;
        		printf ("%s, %s, %s\n", $webIndex, $1, $2 );
   		}	
	}

# L'script actua com a HTML renderer del output OAI XML (si no rep els parametres GET 'set' o 'verb+resumptionToken' [que sol·licita els següents registres als mostrats per una acció 'set' anterior]. Precedència al statement condicional: eq > && > ||. 
} elsif ( $out->param == 1 && $out->param('set') || $out->param == 2 && $out->param('resumptionToken') && $out->param('verb') eq 'ListRecords' ) { 
	
	eval{ #Approach XML::LibXSLT::Easy hagués estat més fàcil, però no està instal·lada per defecte
	  my $parser = XML::LibXML->new;
	  my $xslt = XML::LibXSLT->new;
	  my $stylesheet = $xslt->parse_stylesheet( $parser->parse_file("$xslSheet") );
	  my $results = $stylesheet->transform( $parser->parse_file( $webOAIif . '?verb=ListRecords&' . ( $out->param('resumptionToken') ? 
				('resumptionToken=' . $out->param('resumptionToken')) : 
				( 'metadataPrefix=oai_dc&set=' . $out->param('set'))) ) , dspacehome => "'$webIndex'"); # Norm. del link del Token només va canviant l'última centena
          print $out->header(),
          $stylesheet->output_string($results);
	  1;

        } or do {error($out,"Error transformant l'ouput OAI-MPH a HTML. Comproveu que tant la interfície OAI-MPH delrepositori remot com la fulla XSTL local siguin accessibles des de l'script.")};

# Aquest script no entén de la jerarquia lògica del repositori. quan se li passa com a paràmetre un handle de DSpace, sol·licita tots els objectes finals que depenen d'aquest. És a dir, tenint en compte que a DSpace el format dels handles és igual per a tot tipus de nodes, si li passem el handle d'una communitat ens retornarà tot el set d'objectes que són fulles d'aquest arbre obviant els nodes intermitjos, de manera que tindrem tots els documents fills de les seves subcomunitats, col·leccions, subcol·leccions, etc. sense tenir informació del seu parentesc. Per això, en la lògica amb què aplicarem aquest script, el nostre repositori serà dissenyat per contemplar solament tres nivells: comunitats (univesitats) > n col·leccions (departaments) > n bitsreams (recursos). Només demanarem els sets corresponents al handle de les col·leccions=departaments. 


}else{ error ($out, "CGI Bad Request Parameters (Paràmetres no tipificats, amb valor nul, o proveïts conjuntament essent de modes incompatibles).") }


#Error Output Page
sub error {
    my( $q, $error_message ) = @_;

    print $q->header(),
          $q->start_html( 'Error' ),
          $q->h2( 'Error' ),
          $q->hr,
          $q->p( "S'ha produït el següent error en la petició: " ),
          $q->p( $q->i ( $error_message ) ),
          $q->end_html;
    exit;
}

