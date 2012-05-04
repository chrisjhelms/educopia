#!/usr/bin/perl -w

#
# Script CGI per a processar dinàmicament l'ouput de les peticions de LOCKSS 
# Si li arriba un valor del paràmetre "set" concret actua de renderer HTML de l'interfície OAI-MPH per a aquell set,
# si li arriba un valor del paràmetre "comm2csv" concret, l'interpreta com a un handle_id de DSpace corresponent a una communitat i treu com a output el CSV que defineix les seves col·leccions (que seran les AUs dins d'aquella Col·lecció Metaarchive), necessari per el registre al Conspectus. 
# ...altrament, actua com a generador dinàmic per defecte de la Manifest Page, exposant totes les coleccions de la instància DSPACE 
#
# Es pot testar a la línia de comandes directament amb:
#  ./Cgi4Lockss (> ManifestPage.html)
#  ./Cgi4Lockss set=hdl_xxxxxx_xxxx (> OAIListRecordsSetxxxx.html )
#  ./Cgi4Lockss resumptionToken=xxxxxx ( > OAIListRecordsSetxxxx2.html)
#  ./Cgi4Lockss comm2csv=xxxx (> commxxxx.csv)
#
# O bé a través de localhost:8080/LOCKSS(?var=val) si aixequem l'aplicació amb Plack des del directori que conté l'script i el XSLT
#
# /dirScripts$ plackup -D -s Starman -MPlack::App::WrapCGI -MPlack::Builder -e 'builder { mount "/LOCKSS" => Plack::App::WrapCGI->new(script => "./Cgi4Lockss.pl")}' --preload-app --port 8080
#
# Pre-requisits:
# sudo yum install perl-Plack perl-XML-LibXSLT perl-XML-LibXML perl-WWW-Mechanize #sudo aptitude install libwww-mechanize-perl libxml-libxslt-perl libplack-perl 
# Si falla fer-ho des de perl, tot i que pot haver algun fitxer necessari que només es trobi en els paquets anteriors que sigui estrictament driver del OS:
# $ env PERL_MM_USE_DEFAULT=1 cpan install CGI WWW::Mechanize XSLT XML:LibXSLT Plack Plack::Handler::Starman CGI::Emulate::PSGI   
# (si no tenim la CLI cpan, directament amb perl -MCPAN -e 'install <mòdul>'. ' 
#

use strict;
use utf8;
use CGI; #Passar-ho a CGI:PSGI el Benchmark en temps de generació no es veu molt perjudicat
#use CGI::Carp; # Debug mode: qw( fatalsToBrowser ); #Plack ja té un debugger 
use URI::URL;
use XML::LibXML;
use XML::LibXSLT;
use WWW::Mechanize;

$| = 1; # Output Buffering Off > ¿Fast::CGI?
$CGI::DISABLE_UPLOADS = 1; # Disable uploads for security
$CGI::POST_MAX        = 0;

my $mech;
my $sublink;
my $out = new CGI;


### VARIABLES ###
my $webIndex = 'http://84.88.13.203:8080' || $out->url(-base => 1); # Per defecte, assumim REPO_INDEX_URL=<CGISCRIPT_HOSTBASE>  
my $webOAIif = 'http://84.88.13.203:8080/oai/request' || 'http://' . URI::URL->new($webIndex)->netloc || 'ErrorIdentificantHostDeURLWebIndex' . '/oai/request'; # Tb tindria sentit .$webIndex . '/oai/request', si /oai/ s'apendés sempre quin sigui el context principal del repositori (<host>/dspace -> <host/dspace>/oai/)
my $xslSheet = './OaiMph2HtmlParticular.xsl'; # Còpia en local modificada de 'http://metaarchive.org/public/doc/testSites/xmlMetaDataToLockss/smartech-oai.xsl'
$out->delete('verb'); # Obviem el codi de comanda que ens puguin passar de OAI-MPH, sempre fem ListRecords si ens arriba un Set/Token
#################

# L'script actua com a generador de la ManifestPage (comportament per defecte, és a dir, quan no sol·licitem exlpícitament cap set) 
# Unless (If not) defined any of the 3 expected parameters
unless( $out->param ) {

	$mech = WWW::Mechanize->new;
	eval {
		$mech->get( "$webIndex" );
     		1;
	} or do {error($out,"Error de connexió/URL a la pàgina principal del repositori ".$webIndex.".")};
	$mech->success or error($out,"El repositori ha tornat una missatge d'error en intentar accedir a la pàgina principal ".$webIndex.".");

	# Per títol, si fos uniforme, en comptes de per URL seria:
	# my @links = $mech->find_all_links( text_regex => qr/Universi/i );
	my @communities = $mech->find_all_links( url_regex => qr{/handle/\d+/\d+/?$}i );
 	error($out,"No s'han trobat enllaços a comunitats a la web del repositori proporcionada ".$webIndex.".") unless ( @communities ); 	

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
	
	    $link->url_abs =~ m{/handle/\d+/(\d+)/?}i;    #Identifiquem la ID de la comunitat
	    my $commID = $1;

	    eval{
		$mech->get($link->url_abs);
	    	1;
            } or do {error($out,"Error de connexió/URL en seguir l'enllaç a una pàgina d'una comunitat.")};
 	    $mech->success or error($out,"El repositori ha tornat un missatge d'error en intentar seguir l'enllaç a la pàgina de la comunitat ".$commID.".");
	
  	    $mech->content =~ /Recent.*?<a\shref="(.*?)">/si; # Identifiquem i guardem el 1er enllaç que no correspon a una col·lecció (Recent Submissions)
	    my $firstRecSubmi = $1;

	    my @collections = $mech->find_all_links( url_regex => qr{/handle/\d+/\d+/?$}i );

	    for my $sublink ( @collections ) {
		if ( $sublink eq $collections[0] ) { # Si primera iteració, hauria d'apareixer el propi link de la comunitat com el primer 'vist'
		    ( $link->url_abs eq $sublink->url_abs ) or error($out, "El primer enllaç de la col·leció s'esperava idèntic al de la comunitat. Revisar el format esperat.");
	       	     print $out->br,
		     	   $out->h2( 'Comunitat: ', $out->a({ -href => $link->url_abs }, $link->text) , $out->a({ -href => $out->url . '?comm2csv=' . $commID  }, ' (CSV) ') );
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
        } or do {error($out,"Error de connexió/URL a la pàgina principal del repositori ".$webIndex.".")};
	$mech->success or error ($out, "El repositori ha tornat una missatge d'error en intentar accedir a la pàgina principal ".$webIndex.".");

	eval{
		$mech->follow_link ( url_regex => qr{/handle/\d+/$commID/?$}i );
                1;
        } or do {error($out,"Error de connexió/URL en seguir l'enllaç a la pàgina principal de la comunitat/institució ".$commID.". Existeix?")};	
	$mech->success or error ($out, "El repositori ha tornat un error en intentar accedir a la pàgina principal de la comunitat/institució ".$commID.". Existeix?");
	
	$mech->content =~ /Recent.*?<a\shref="(.*?)">/si;
	my $firstRecSubmi = $1;

	my @collections = $mech->find_all_links( url_regex => qr{/handle/\d+/\d+/?$}i );
        error($out,"No s'han trobat enllaços a col·leccions a la pàgina de la comunitat.".$commID.".") unless ( @collections );

	for my $sublink ( @collections ) {
   		if ( $sublink eq $collections[0] ) {
           		print $out->header(-type=>'application/x-download',
                        	           -attachment  => 'AU_comm'.$commID.'.csv' );
 					   # -Content_length  => -s "$path_to_files/$file", # Per obtenir progressbar

            		print "dspace_instance, coll_hdl_id, base_url2\n";
		} elsif ( $sublink->url eq $firstRecSubmi ) { 
			last;
   		} else {
        		$sublink->url =~ m{/handle/(\d+)/(\d+)/?$}i;
        		printf ("%s, %s, %s, %s\n", $1, $2, $webIndex );
   		}	
	}

# L'script actua com a HTML renderer del output OAI XML si rep els parametres GET 'set' o 'resumptionToken' [que sol·licita els següents registres als mostrats per una acció 'set' anterior]. 
} elsif ( $out->param == 1 && ( $out->param('set') || $out->param('resumptionToken') )) { 
	
	eval{ 
	  my $parser = XML::LibXML->new;
	  my $xslt = XML::LibXSLT->new;
	  my $stylesheet = $xslt->parse_stylesheet( $parser->parse_file("$xslSheet") );
	  my $results = $stylesheet->transform( $parser->parse_file( $webOAIif . '?verb=ListRecords&' . ( $out->param('resumptionToken') ? 
				('resumptionToken=' . $out->param('resumptionToken')) : 
				('metadataPrefix=oai_dc&set=' . $out->param('set'))) ) , dspacehome => "'$webIndex'", dspaceoai => "'$webOAIif'" ); 
                               # Norm. del link del Token només va canviant l'última centena
          print $out->header(),
          $stylesheet->output_string($results);
	  1;

        } or do {error($out,"Error transformant l'ouput OAI-MPH a HTML. Comproveu que les rutes tant a la interfície OAI-MPH del repositori remot com a la fulla XSTL local siguin accessibles des d'aquest script que us està parlant.")};

# Aquest script no entén de la jerarquia lògica del repositori. quan se li passa com a paràmetre un handle de DSpace, sol·licita tots els objectes finals que depenen d'aquest. És a dir, tenint en compte que a DSpace el format dels handles és igual per a tot tipus de nodes, si li passem el handle d'una communitat ens retornarà tot el set d'objectes que són fulles d'aquest arbre obviant els nodes intermitjos, de manera que tindrem tots els documents fills de les seves subcomunitats, col·leccions, subcol·leccions, etc. sense tenir informació del seu parentesc. Per això, en la lògica amb què aplicarem aquest script, el nostre repositori serà dissenyat per contemplar solament tres nivells: comunitats (univesitats) > n col·leccions (departaments) > n bitsreams (recursos). Només demanarem els sets corresponents al handle de les col·leccions=departaments. 


}else{ error ($out, "CGI Bad Request Parameters (Paràmetres no tipificats, amb valor nul, o proveïts conjuntament essent de modes incompatibles).", '400 Bad Request') }


#Error Output Page
sub error {
    my( $q, $error_message, $status ) = @_;

    $status='500 Internal Server Error' unless ($status);

    print $q->header( -status=> $status ),
          $q->start_html( 'Error' ),
          $q->h2( 'Error' ),
          $q->hr,
          $q->p( "S'ha produït el següent error en la petició: " ),
          $q->p( $q->i ( $error_message ) ),
          $q->end_html;
    exit;
}
