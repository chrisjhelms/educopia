import os,sys,logging,re; 
from utils import Utils;

from lockss_util import log

from django.core.exceptions import ObjectDoesNotExist

from status.models import *; 
 
import ConfigParser
import optparse
import time

class LockssScript:
    """
    basis of all scripts that connect to LOCKSS caches and retrieve data
    parameters can be defined on the command line or in an configuration file
    run the script with --help to see th eusage message
    run with --dryrun to do command line parsing but skip actual execution
    """
    AUIDS = 'auids'
    AUIDPREFIXLIST = 'auidprefixlist'
    SERVERLIST = 'serverlist'
    PARAMSECTION = 'Status'

    def __init__(self, argv0, revision, defaults):
        #print "> %s init" % (self.__class__)

        self.hasAuParams = True
        self.hasCredentials = True
        self.hasServer = True
        self.createCaches = False
        self.base_name = os.path.splitext(os.path.basename(argv0))[ 0 ]

        self.PROGRAM = os.path.splitext(os.path.basename(sys.argv[ 0 ]))[ 0 ].title()
        self.REVISION = revision.split()[ 1 ]
        self.MAGIC_NUMBER = 'AUS' + ''.join(number.rjust(2, '0') for number in self.REVISION.split('.'))

        self.CONFIGURATION_DEFAULTS = dict({
                'auidprefix': None,
                "auidprefixlist": "",  # set in config file
                "auidlist": "",        # set in config file
                'all':      None,

                'server' : None,
                'serverlist': "",      # set in config file

                'timeout':  30,
                'sleep':    10,
                'trials':   3,

                'config':   None,
                'dryrun':   None,
                'loglevel': logging.INFO
            }, **defaults)

        self.parse_opts()
        self.check_opts()
        #print "< %s init" % (self.__class__)


    def _read_configuration(self, filename):
        '''Process configuration file; handles nesting if necessary'''
        if (filename):
            filename = os.path.expanduser(filename)
            while filename not in self.read_configurations:
                self.read_configurations.add( filename )
                if (filename):
                    fname = self.configuration.read( filename )
                    if (fname):
                        log.info("Read Config File '%s'" %  filename)
                    else:
                        log.info("Could not read Config File  '%s'" %  filename)
                    if (self.configuration.has_option(LockssScript.PARAMSECTION, 'config')):
                        filename = self.configuration.get( LockssScript.PARAMSECTION, 'config' )
                        self._read_configuration(filename)

    def _create_opt_parser(self):
        return self._create_parser(au_params=True, mayHaveServer=True, credentials=True)

    def _create_parser(self, au_params=False, mayHaveServer=True, credentials=False, createCaches=False):
        ''' create and return option parser based on self.configuration  '''

        # setup command line options
        self.hasAuParams = au_params
        self.hasCredentials = credentials
        self.hasServer = mayHaveServer
        self.createCaches = createCaches
        if (not self.hasAuParams):
            args  = ''
        else:
            args = '[ AU_ID|@AU_ID_list)...]'
        description = self.__class__.__doc__
        if (description):
            description = re.compile( '(\s)+') .sub(' ', description)
        else:
            description = ""

        option_parser = optparse.OptionParser(usage='usage: %prog [options] ' + args,
                                         version='%prog ' + self.REVISION,
                                         description="%s" % (description))
        option_parser.add_option('-d', '--dryrun',
                                  action='store_true',
                                  help='dry run [%default]')
        option_parser.add_option('-c', '--config',
                                 help='Configuration file [%default]')
        option_parser.add_option('-l', '--loglevel',
                                type='int',
                                help='set loglevel level [%default]')

        configuration_dictionary = dict(self.configuration.items(LockssScript.PARAMSECTION))
        option_parser.set_defaults(**configuration_dictionary)

        if (self.hasAuParams):
            # which archival units to work with
            option_parser.add_option('-A', '--all',
                                      action='store_true',
                                      dest='all',
                                      help='work on all known archival units [%default]')
            option_parser.add_option('-P', '--auidprefix',
                                     action='append',
                                     help='archival unit prefix to match against known auids  [%default]')


        if (self.hasServer):
            # lockss servers
            option_parser.add_option('-S', '--server',
                                     action='append',
                                     metavar='HOST:PORT',
                                     help='LOCKSS cache with port, may give multiple ')


        if (self.hasCredentials):
            # lockss server connection related arguments
            option_parser.add_option('-p', '--password',
                                     help='LOCKSS server password [%default]')
            option_parser.add_option('-u', '--username',
                                     help='LOCKSS server username [%default]')

            option_parser.add_option('-s', '--sleep',
                                 type='int',
                                 help='Sleep time (seconds) between UI requests. Default: [%default]')
            option_parser.add_option('-t', '--timeout',
                                 type='int',
                                 help='Timeout (seconds) before giving up on UI connections. Default: [%default]')
            option_parser.add_option('-T', '--trials',
                                 type='int',
                                 help='how often to retry connections [%default]')
        self.option_parser = option_parser
        #print "< LockssScript.create_parser"
        return option_parser

    def parse_server(self, svr):
        if (svr):
            if ":" in svr:             
                parts = svr.split(':');
                if (len(parts) == 2): 
                    try: 
                        return (parts[0], int(parts[1]))
                    except: 
                        self.option_parser.error("Malformed server %s; port must be a number" % svr); 
                else: 
                    self.option_parser.error("Malformed server %s; format DOMAIN_or_NAME[:PORT]"); 
            else:
                return (svr, 8081); 
        return None

    def require_server(self):
        ''' check on remote_server argument; report option error  '''
        if (not self.options.serverlist):
            self.option_parser.error("Must give a remote server")

    def require_credentials(self):
        ''' check on username and password arguments; report option error  '''
        if (not self.options.username):
            self.option_parser.error( "Must give username")
        if (not self.options.password):
            self.option_parser.error("Must give password")

    def require_auids(self):
        if (not self.options.auids and not self.options.all and not self.options.auidprefixlist):
            self.option_parser.error( "Must give at least one archival unit")

    def check_opts(self, logopts=True):
        '''
        check that timeout, sleep, trials, loglevel are greater than 0
        check that at least one AuId or All = True
        '''
        #print "LockssScript.check_opts %s" % (self.options)

        if (self.options.loglevel < 1):
            self.option_parser.error( "loglevel value (%d) must be greater equal 1"
                                       % self.options.loglevel)

        log.setLevel(self.options.loglevel)

        if (self.hasCredentials):
            if (self.options.timeout < 1):
                self.option_parser.error( "UI Timeout value (%d) must be greater equal 1"
                                          % self.options.timeout)

            if (self.options.sleep < 1):
                self.option_parser.error( "sleep value (%d) must be greater equal 1" % self.options.sleep)

            if (self.options.trials < 1):
                self.option_parser.error( "trials value (%d) must be greater equal 1" % self.options.trials)

        if (self.options.server):
            serverlist = self.options.server
        else:
            serverlist = self.options.serverlist

        self.options.serverlist = []
        for s in  serverlist:
            self.options.serverlist.append(self.parse_server(s))
            print "parsed cache"
        self.options.server = None
        self.options.cachelist = None;     # see get_caches and set_Q_caches
        if (self.options.serverlist):
            self.get_caches();

        if (self.options.auidprefix):
            self.options.auidprefixlist = self.options.auidprefix
            self.options.auidprefix = None

        if (logopts):
            self.log_opts();

    def parse_opts(self):
        #print "> LockssScript.parse_opts"
        # get settings  from config files
        self.read_configurations = set()
        self.configuration = ConfigParser.RawConfigParser(self.CONFIGURATION_DEFAULTS)
        self.configuration.add_section(LockssScript.PARAMSECTION)
        self._read_configuration('~/.' + self.base_name + '.rc')
        self._read_configuration('./' + self.base_name + '.rc')
        self.option_parser = self._create_opt_parser()
        self.options, self.au_ids = self.option_parser.parse_args()  # command line options + defaults
        self._read_configuration(self.options.config)

        self.option_parser = self._create_opt_parser()    # defaults
        self._read_configuration('~/.' + self.base_name + '.rc')
        self._read_configuration('./' + self.base_name + '.rc')
        self._read_configuration(self.options.config)    # config param rc  file
        self.options, self.au_ids = self.option_parser.parse_args()  # + command line

        #self._read_configuration(os.path.expanduser('./' + self.base_name + '.rc'))

        if (self.options.server):
            self.options.serverlist = self.options.server
        elif (self.options.serverlist):
            self.options.serverlist = [s for s in self.options.serverlist.split("\n") if s];
        self.options.server = None

        if (not self.hasAuParams):
            self.options.auids = []
            self.options.auidlist = []
            self.options.auidprefix = []
            self.options.auidprefixlist = [];
        else:
            self.options.auids = []
            # AUID command line options take precedence over options in config files
            if (self.au_ids or self.options.auidprefix):
                # print "# command line ";
                self.options.auids = self.au_ids;
                self.options.auidprefixlist = self.options.auidprefix;
            else:
                # print "# turn strings into arrays"
                auidlist =  self.configuration.get(LockssScript.PARAMSECTION, 'auidlist');
                auidprefixlist = self.configuration.get(LockssScript.PARAMSECTION, 'auidprefixlist')
                self.options.auids = [s for s in auidlist.split("\n") if s];
                self.options.auidprefixlist = [s for s in auidprefixlist.split("\n") if s];
            if (not self.options.auidprefixlist): self.options.auidprefixlist = [];

        self.options.auidlist = []
        self.options.auidprefix = []

        if (self.options.server):
            self.options.serverlist = self.options.server
            self.option.server = None

        self.options._COMMAND =  " ".join(sys.argv)
        self.options._CWD =  os.getcwd();

        #print "< LockssScript.parse_opts"

    def get_caches(self):
        ''' return all caches with domain listed in self.options.serverlist, where the domain may be given in reverse '''
        if (not self.options.cachelist):
            if (not self.options.serverlist):
                self.options.cachelist = LockssCache.objects.all().order_by('name');
            else:
                self.options.serverlist = sorted(self.options.serverlist);
                caches = []
                nxt = None
                for s in self.options.serverlist:
                    if ("." in s[0]): 
                        #assume this is a DNS or reverse DNS 
                        try:
                            dns = s[0]
                            reverse_dns = ".".join(dns.split(".")[::-1])
                            nxt = LockssCache.objects.get( Q(domain = dns) | Q(domain = reverse_dns))
                        except ObjectDoesNotExist:
                            raise RuntimeError("Unknown LockssCache with domain %s" % (s[0]))
                    else:
                        # assume this is a cache name 
                        try: 
                            nxt = LockssCache.objects.get(name = s[0]);
                        except ObjectDoesNotExist: 
                            raise RuntimeError("Unknown LockssCache with name %s" % (s[0]))
                    if (nxt.port != s[1]): 
                        raise RuntimeError("Unknown LockssCache %s:%d, wrong port number" % (s[0],s[1]))
                    caches.append(nxt) 
                self.options.cachelist =  list(set(caches));
        return self.options.cachelist;

    def get_Q_caches(self):
        if (not self.options.serverlist):
            Q_caches = Q();
        else:
            Q_caches = None;
            for c in self.get_caches():
                if (Q_caches):
                    Q_caches = Q_caches | Q(cache = c)
                else:
                    Q_caches = Q(cache = c)
        return Q_caches;

    def log_opts(self):
        '''
        log all int, float, str options
        except for password or strings with '\n'
        also log auids and auiprefix lists
        '''
        options = self.options
        log.info( "COMMAND = %s" % self.options._COMMAND)
        log.info( "CWD     = %s" % self.options._CWD)
        for e in options.__dict__:
            if (not e.startswith('_') and
                not e == self.AUIDS and
                not e == 'password' and
                not e == self.AUIDPREFIXLIST and
                not e == self.SERVERLIST):
                v = self.options.__dict__.get(e)
                if (not v):
                    continue ;
                if (v.__class__ == str) :
                    if (v.find('\n') == -1):
                        log.info( "%s = %s" % (e, v))
                elif (v.__class__ == int or v.__class__ == float):
                    log.info( "%s = %s" % (e, str(v)))
                elif (v.__class__ != list):
                    log.info( "%s = %s" % (e, str(v)))
        if (self.options.cachelist): 
            for c in sorted(self.options.cachelist):
                log.info( "SERVER = %s" % c)
        else: 
            for s in sorted(options.serverlist):
                log.info( "SERVER = %s:%s" % (s[0], s[1]))
        for i in sorted(options.auids):
            log.info( "AUIDS = %s" % i)
        for i in options.auidprefixlist:
            log.info( "AUIDPREFIX = %s" % i)

    def collectAuIdInstances(self, cache):
        ids = [];
        if (self.options.all):
            ids =  cache.locksscacheauid_set.all()
        else:
            ids = LockssCacheAuId.get(self.options.auids, self.options.auidprefixlist, cache)
        log.info("#Matching AUIDS: %d" % len(ids))
        for au in ids:
            log.info("Matching AUIDS: %s" % au.auId)
        return ids

    def collectMasterAuIdInstances(self):
        ids = [];
        if (self.options.all):
            ids =  MasterAuId.objects.all()
        else:
            ids = MasterAuId.get(self.options.auids, self.options.auidprefixlist)
        log.info("#Matching MASTER AUIDS: %d" % len(ids))
        for au in ids:
            log.info("Matching MASTER AUIDS: %s" % au.auId)
        return ids

    @ staticmethod
    def sleep(s):
        log.info("Sleeping %s sec ..." % s)
        time.sleep(s)

    def getausummaries(self, auids, directory, doUrls, expire, noquit):
        action =  [Action.GETAUSUMMARY, Action.GETURLLIST][doUrls]
        errorFile = directory + "/errorIds-%s.rc" % action
        try:
            os.remove(errorFile)
        except:
            pass
        errorIds = set()
        loopids = auids
        while (loopids):
            for auId in loopids:
                    success = LockssCacheAuSummary.load(self.cache, auId, doUrls, expire,
                                                   self.options.trials,
                                                   self.options.sleep, self.options.timeout)
                    if (not success):
                        errorIds.add(auId)
            if (errorIds):
                self.printConfigFile(errorFile, action, errorIds, self.cache)

            if (not noquit):
                break
            else:
                loopids = errorIds
                errorIds = set()
                if (loopids):
                    self.sleep(self.options.sleep)

        return errorIds
        
    def getcrawlstatus(self, auids, directory, noquit):
        errorFile = directory + "/errorIds-%s.rc" %  Action.GETCRAWLSTATUS
        try:
            os.remove(errorFile)
        except:
            pass
        errorIds = set()
        loopids = auids
        while (loopids):
            for auId in loopids:
                success = LockssCrawlStatus.load(self.cache, auId, self.options.trials,
                                                 self.options.sleep, self.options.timeout)
                if (not success):
                    errorIds.add(auId)
            if (errorIds):
                self.printConfigFile(errorFile, Action.GETCRAWLSTATUS, errorIds, self.cache)
            if (not noquit):
                break
            else:
                # get ready for next iteration going through errorIds
                loopids = errorIds
                errorIds = set()
                if (loopids):
                    self.sleep(self.options.sleep)
        return errorIds

    def getreposspace(self):
        return RepositorySpace.load(self.cache, self.options.trials,
                                                 self.options.sleep, self.options.timeout);
                
    def getcommpeers(self, directory, noquit):
        while (True):
            success = LockssCacheCommPeer.load(self.cache, self.options.trials,
                                                 self.options.sleep, self.options.timeout)
            if (success or not noquit):
                break
            else:
                self.sleep(self.options.sleep)
        return success;

    def get_cache(self, domain, port, connect, user= None, password = None):
        '''
        if not connect: returns pre-existing LockssCache db entry for (domain,port) or reports options error
        if no such cache exists

        otherwise connects to domain:port and returns a pr-existing or newly created LockssCache db entry
        saves the connection lockss_daemon.Client in the ui filed of the returned cache
        reports option error  if the connection to the client can not be established
        '''
        if (not connect):
            try:
                cache = LockssCache.objects.get(domain = domain, port = port)
            except ObjectDoesNotExist:
                self.option_parser.error( "no such cache %s:%s" % (domain, port) )
        else:
            cache = LockssCache.connect(domain, port, user, password, self.options.timeout, self.options.sleep)
            if (not cache):
                self.option_parser.error( "Could not get to server")
        return cache

    @staticmethod
    def printConfigFile(fname, action,  auIds, cache):
        log.warn("printing ids for %s on %s to %s" % (action, cache, fname))
        f = open(fname, 'w')
        f.write('[%s]\n' % LockssScript.PARAMSECTION)
        f.write('action=%s\n' % action)
        f.write('auids=\n')
        for au in auIds:
            f.write(' ' + au.auId + "\n ")
        f.write('\n')
        f.close()

class ReportScript(LockssScript):

    MYCONFIGS = {
            'dir':           None, 
            'explainheaders': False,
            'reportheaders':  ""
    }

    HEADEREXPLANATIONS =  {}; 
    ALLHEADERS = []
    
    def __init__(self, argv0, revision, configs = {}):
        self.hasServer = False;
        LockssScript.__init__(self, argv0, revision,
                              dict(ReportScript.MYCONFIGS.items() + configs.items()))

    def _create_opt_parser(self):
        option_parser = self._create_parser(au_params=True, mayHaveServer=True, credentials=False)
        
        option_parser.add_option('--reportheaders',
                        help='report headers [%default];   Available headers: ' +
                        ",".join(self.__class__.ALLHEADERS) )

        option_parser.add_option("--explainheaders",  action="store_true",
                          help='explain report headers [%default]')
        
        return option_parser

    '''
    deal with server option on command line
    and serverlist option from config file
    '''
    def check_opts(self, logopts=False):
        LockssScript.check_opts(self, logopts)
        if (not self.options.dir):
            self.options.dir = "."
        if (not os.path.exists(self.options.dir)):
            os.mkdir(self.options.dir)
        try:
            self.options.reportheaders = Utils.stringToArray(
                   self.options.reportheaders.replace("_"," "), self.ALLHEADERS);
        except RuntimeError as rt:
            self.option_parser.error("%s, available reportheader option: %s" % (rt, self.ALLHEADERS))
                    
    @staticmethod
    def explainheaders(self):
        explain = "";
        for h in self.__class__.ALLHEADERS:
            explain = "%s%-14s\t%s\n" % (explain,h,self.__class__.HEADEREXPLANATIONS[h]);
        return explain

    def report_preamble(self):
        opts = self.options.__dict__;
        for key in ['ausetname', 'auseturl']:
            if (opts.has_key(key)):
                print "#", key, opts.get(key);
                
        caches = self.get_caches();
        lines = [];  
        for c in caches: 
            lines.append("# SERVER\t%s" % c)
        lines.append("#")
        
        for h in self.options.reportheaders:
            lines.append("# HEADER\t%-16s\t%s" % (h,self.__class__.HEADEREXPLANATIONS[h]) );
        lines.append("#\n"); 
        return "\n".join(lines); 
    
