# Lockssview command line scripts #

<dl>
<dt> <code> INSTALL_DIR/scripts.py  </code>
</dt><dd> list available scripts   </dd>
<dt>  <code> INSTALL_DIR/scripts.py THESCRIPT PARAMS  </code>
</dt> <dd> execute THESCRIPT  with given parameters<br>
</dd>
</dl>
Scripts fall into two categories: those, that retrieve information form individual LOCKSS caches and print status information about them and those, that report on content preserved on several LOCKSS Caches.

In the following we us ` lksNAME ` as shortcut for ` INSTALL_DIR/scripts.py NAME `

# Parameters common to all Scripts #

All commands accept the following:
<dl>
<dt> <code> --help </code> </dt>
<dd>     The usage messages printed are available a <a href='http://educopia.googlecode.com/svn/trunk/pln_admin/lockssview/doc/scripts/usage/'>usage txt files</a> </dd>
<dt> <code> --version </code> </dt>
<dd> Versions correspond to the subversion revision of a scripts last commit. </dd>
<dt> <code> -c filename </code> </dt>
<dd>    Scripts read the given file name and parse options defined in the <a href='Status.md'>Status</a> section as configuration parameters; users may give multiple configuration files. See the cachestatus.rc example file.  </dd>
<dt>  <code> -d </code> </dt>
<dd> Dryrun; interpret command line and read configuration files  </dd>
<dt>  -l loglevel </dt>
<dd>      The amount of logging desired: 1==most, 21=least </dd>
</dl>

### Configuration files ###

Each command reads configuration files (if existent)  in the following order
  1. ~/.command.rc
  1. ./command.rc
  1. files listed in -c options on the command line i the order that they are listed

Parameters values given on the command line supersede  any settings in configuration files.

All parameters that can be set via command line options, may be defined in configuration files instead. All scripts look for settings in the [Status](Status.md) section only. It is easy to share common settings across commands by passing a common configuration file to scripts via the -c option. [cachestatus.rc](http://lockssview.metaarchive.org/doc/scripts/cachestatus.rc) shows settings for all options accepted by the cachestatus script.

## EXAMPLE USAGE ##

### Caches ###

[lkscaches USAGE](https://educopia.googlecode.com/svn/trunk/pln_admin/lockssview/doc/scripts/usage/caches.txt)

<dl>
<dt> <code> lkscaches --help  </code>  </dt> <dd>    print usage message  </dd>
<dt> <code>  lkscaches  </code> </dt> <dd> Print all defined caches  </dd>
<dt> <code> lkscaches  -n  </code> </dt> <dd> Print the names of caches only </dd>
<dt> <code> lkscaches -N production  </code> </dt> <dd> Print the only production network caches </dd>
<dt> <code> lkscaches -N production -D </code> </dt> <dd> Print the docmain names of production network caches </dd>
</dl>

### CacheStatus ###

[lkscachestatus USAGE](https://educopia.googlecode.com/svn/trunk/pln_admin/lockssview/doc/scripts/usage/cachestatus.txt)

lkscachestatus is the work horse for retrieving status information from LOCKSS
caches, storing retrieved information in the lockssview database,  and for printing cache specific information to tab separated files.

When retrieving data, users must specify at least one LOCKSS cache to retrieve data from and one of the get-action. Caches are defined by their name or domain name, as they are given in the `lkscaches` command. With the exception of the `getauidlist` action, users must define at least one id of an archival unit, for which information should be retrieved:
<dl>
<dt>getauidlist</dt>
<dd> retrieve list of preserved archival unit ids from given LOCKSS caches(s) </dd>
<dt>getausummary</dt>
<dd> retrieve ausummary info for given archival unit(s) </dd>
<dt>getcrawlstatus</dt>
<dd> retrieve crawlstatus info for given archival units(s) </dd>
<dt>geturllist</dt>
<dd> retrieve urllist for given archival units(s); retrieving urllist info automatically retrieves ausuammry info as well </dd>
<dt>getreposspace, getcommpeers</dt>
<dd> not yet fully implemented </dd>
</dl>

`get`-actions need to contact LOCKSS caches. Thus users must include  LOCKSS daemon credentials via the user and password parameters. `cachestatus` retrieves new status data from LOCKSS caches only if its database does not contain ausummary, urllist, or crawlstatus information, that was retrieved within `x` hours, where `x` is defined by the `expire` parameter. `expire` defaults to 168 hours. Setting it to `0` forces data retrieval from LOCKSS caches.

Here a  few data retrieval examples:
<dl>
<dt>  <code> lkscachestatus -a getauidlist -u user -p pwd -S aub-dell  </code> </dt>
<dd>
Retrieve the list of known auids  from the aub-dell server.<br>
</dd>
<dt>  <code> lkscachestatus -a getausummary -a getcrawlstatus --all  -u user -p pwd -S aub-dell </code> </dt>
<dd>
Update  ausummary  and crawlstatus info for all aus known to the aub-dell cache<br>
</dd>
<dt> <code>  lkscachestatus -a geturllist -P edu.auburn  -u user -p pwd -S aub-dell  -S vt-fe </code> </dt>
<dd>
Update urllist iand crawlstatus info for all aus starting with ids that start with edu.auburn known to the aub-dell and vt-fe  caches. Note that retrieving the urllists implies updating the ausuammry information as well.<br>
</dd>
<dt>  <code>  lkscachestatus -a geturllist -u user -p pwd -S aub-dell -x 24 'edu|auburn|...&amp;year~192' </code>
</dt>
<dd>
Get urllists for 'edu|auburn|...&year~192'. The -x parameter states that data older than a day needs to be refreshed.<br>
</dd>
</dl>