<?php

/*

Copyright (c) 2006, Emory University
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.

* Neither the name of Emory University nor the names of its contributors may be 
used to endorse or promote products derived from this software without specific 
prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

// whether to log sql quesries to syslog 
#$logFileName = "log/sql.log";
#$logFile = fopen($logFileName, 'a+') or die("Can't open file $logFileName");
$logFile= NULL; 
include_once('utils.php');

// the url of the ruby conspectus 
$conspectus_url  = "http://conspectus.metaarchive.org"; 

// change this to add or remove caches
$caches = array(
	"Auburn Cap" => "http://metaarchive.lib.auburn.edu",
	"Auburn FE" => "http://metaarchive2.lib.auburn.edu",
	"Boston" => "http://etdsafe.bc.edu",
	"Boston FE" => "http://metaarchive.bc.edu",
	"CBUC" => "http://rovira.cesca.cat",
	"Clemson" => "http://lockss.clemson.edu",
	"FSU Cap" => "http://clockss2.lib.fsu.edu",
	"FSU FE" => "http://clockss.lib.fsu.edu",
	"GATech Cap" => "http://ndiiplockss2.library.gatech.edu",
	"GATech FE" => "http://gt1-ma-cache.library.gatech.edu",
	"HBCU eRack" => "http://metaarchive.auctr.edu",
	"HULL" => "http://metaarchive.hull.ac.uk",
	"HULL eRack" => "http://metaarchive1.hull.ac.uk",
	"IndState" => "http://tbr7.indstate.edu",
	"Louisville Cap" => "http://A70782.library.louisville.edu",
	"Louisville FE" => "http://meta-archive3.library.louisville.edu",
	"UNT" => "http://metaarchive.library.unt.edu",
	"OregState eRack" => "http://pontus.library.oregonstate.edu",
	"PSU eRack" => "http://metaarchive.libraries.psu.edu",
	"Rice" => "http://metaarchive.rice.edu",
	"Rice FE" => "http://metaarchive1.rice.edu",
	"SC FE" => "http://metaarchive.tcl.sc.edu",
	"VT Cap" => "http://metaarchive2.lib.vt.edu",
	"VT FE" => "http://metaarchive3.lib.vt.edu"
	);

error_reporting(E_ALL); 

?>
