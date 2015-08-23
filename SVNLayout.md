## Subversion Layout ##

  * trunk/
    * plugins/    -- plugin xml files of plugins not yet active in the production network
    * plugins\_dev  -- all things related to plugin development
      * plugins
        * ext     -- example plugins documented in [metawiki](http://wiki.metaarchive.org)'s plugins sections
        * OTHER  -- plugin xml being tested by plugin developers
      * run\_one\_daemon -- LOCKSS run one daemon development instance used by MetaArchive staff (only in existence while staff works on updates)
      * scripts  -- scripts that may be useful to plugin developers
      * testSites  -- web site mockups used in [metawiki](http://wiki.metaarchive.org)'s plugins sections
    * contentSites/  -- contains subdirectories (one for each content provider) to keep scripts/files/manifest pages <br /> that are kept on web servers for the benefit of LOCKSS crawlers
    * pln\_admin -- scripts useful for PLN administrators

  * branches/
    * release/
      * cache /     -- scripts for LOCKSS cache administrators
      * contentSites/  -- same as in trunk - except these are files kept on actively preserved sites
      * plugins/    -- plugin xml files of plugins active in production network
      * plugins\_dev/
        * manifest\_template.html -- a manifest page template
        * plugintool/  -- LOCKSS plugin tool
        * plugins/  -- example plugins and templates
        * run\_one\_daemon   -- LOCKSS run\_one\_daemon setup which integrates with MetaArchive's conspectus tool  (for plugin developers)
        * scripts/  -- miscellaneous scripts that may be used for plugin developers when analysing a web site
        * testSites/ -- toy web sites - the project wiki refers to these sites in its plugin documentation
        * testSiteRestores/ --  directory to hold (unversioned) zip archives of restored archival units downloaded from a test cache (see http://metaarchive.org/public/doc/testSitesRestores/)
        * webserver/      -- scripts for web server administrators


