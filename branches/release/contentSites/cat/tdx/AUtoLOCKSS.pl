#!/usr/bin/perl -w

#
# Script for batch-adding AUs on local LOCKSS caches throught REGEXPs
#
# Simply introduce requested cache parameters, choose a REGEXP which matches expected AUs for adding on LOCKSS, check the 
# matching list shown, and finally confirm ingestion. Read the reply's message left by the server after every adding action 
# (it should notice when an AU was successfully added or either a message error from server, as when AU is already added).  
#
# Written by Marc Miranda <nightswimming84@gmail.com>
#

use strict;
use utf8;
use WWW::Mechanize;
use MIME::Base64 qw(encode_base64);


# INITIALIZATION (before User Input)
my $mech = WWW::Mechanize->new( autocheck => 0 ); # Disable error checking from Mechanize

# USER INPUT GATHERING
print "\n>>>> Please, introduce the following data about your local LOCKSS cache: \n";
print "\n\t- LOCKSS Host (FQDN/IP): ";
chomp (my $HOST = <>); 
#my $HOST='rovira.cesca.cat';
print "\t- LOCKSS AdminUI User: ";
chomp (my $USER = <>); 
#my $USER='lockss9meta8';
print "\t- LOCKSS AdminUI Pass: ";
#my $PASS='c8ucl0ckssm3t99rch1v3';
system "stty -echo";
chomp (my $PASS = <>);
system "stty echo";
print "\n";


# HARDODED PARAMETERS
my $CASE_SENSITIVE_REGEXP=1; 
my $LOCKSS_ADMIN_UI="http://$HOST:8081/AuConfig";


# MAIN SCRIPT
eval {
	# Auth: We might use '(USER:PASS@)host:port' URL syntax in order to get acccess, but we prefer a permanent Header
	$mech->default_header(Authorization => 'Basic ' . encode_base64( $USER . ':' . $PASS ));
	$mech->get( "$LOCKSS_ADMIN_UI?lockssAction=Add" );
	1;
} or die "\n\t*** ERROR!: Connection/URL/Auth Error accessing AuConfig's LOCKSS page ($LOCKSS_ADMIN_UI).\n\n";
$mech->success or die "\n\t*** ERROR!: LOCKSS returned an error message when trying to access AuConfig's LOCKSS page '$LOCKSS_ADMIN_UI?lockssAction=Add'.\n\n";

my @AUs;
my $ANSWER='';
my ($select) = $mech->find_all_inputs( type => 'option', name => 'Title' ); # Converting to list (if not it only shows #elements)

if ($select){ 
	until ('ingest!' eq $ANSWER){
		print "\n>>>> Please, introduce a REGEXP pattern for matching AUs to be ingested [i.g, 'College.*Year(199[5-9]|200[0-5])' ].\n";
		print "\n     (CASE SENSITIVE is ".($CASE_SENSITIVE_REGEXP ? 'ON' : 'OFF')." on hardcoded initial params): ";
		chomp (my $REGEXP = <>);

		@AUs = grep(($CASE_SENSITIVE_REGEXP? /$REGEXP/ : /$REGEXP/i ), $select->value_names);
		print (!@AUs ? "\n\t  <EMPTY LIST>": "\n\t- ".join("\n\t- ",@AUs));
		print "\n\t-------------------------------------\n\t> Archival Units Matched: ".(@AUs)."\n";
		next if !@AUs;
		print "\n>>>> If you are sure you want to mechanize the ingestion of all these AUs on your local LOCKSS '$HOST', please enter 'ingest!'. For redefining REGEXP enter any other string or just press <Enter>: ";
		chomp ($ANSWER = <>);
	}

	foreach (@AUs){
		print "\n\t...Adding Title '$_'...";
		eval{
			$mech->select('Title',"$_");
			$mech->success or die "\n\n\t*** ERROR!: Could not select AU '$_' from the dropdown. Title was not added.\n\n";
			$mech->click_button( value => 'Continue' ); # o click('button');
			$mech->success or die "\n\n\t*** ERROR!: Could not access AU's details page of the title '$_' when hitting 'Continue' button. Title was not added.\n\n";
			$mech->click_button( value => 'Create' ); # o click('lockssAction');
			$mech->success or die "\n\n\t*** ERROR!: Failure when hitting 'Create' button on title '$_''s details page. Title was POSSIBLY added.\n\n";
			1;
		} or die ($@ =~ /ERROR!:/ ? $@ : "\n\n\t*** ERROR!: Problems creating AU '$_'. Title was possibly not added.\n\n" );

		eval{
			$mech->content =~ /<body.*?<center.*?<font.*?>(.*?)<\/font>/si; # Identifiquem el missatge de retorn
			print "\n\t--- [Action Reply Msg]: $1";
		} or die "\n\n\t*** Title '$_' . It could not be added.\n\n";
		
		eval{
			# $mech->follow_link ( text  => 'Back to Journal Configuration' );
			# $mech->click_button( value => 'Add' ); # Javascript seems not to be much well handled through Mechanize
			$mech->get("$LOCKSS_ADMIN_UI?lockssAction=Add"); #Back to the beggining
		} or die "\n\n\t*** ERROR!: Connection/URL/Auth Error returning to AuConfig's LOCKSS page ($LOCKSS_ADMIN_UI) after ingesting previous AU.\n\n";
		$mech->success or die "\n\n\t*** ERROR!: LOCKSS returned an error message when trying to acess AuConfig's LOCKSS page '$LOCKSS_ADMIN_UI?lockssAction=Add' after ingesting previous AU.\n\n";
	}

	print "\n\n>>>> Finished! You can check again all AUs are ingested right-clicking at '$LOCKSS_ADMIN_UI'.\n\n";
}else{
	print "\n*** Error figuring SELECT (dropdown) options out for Archival Unit\n\n";
}
