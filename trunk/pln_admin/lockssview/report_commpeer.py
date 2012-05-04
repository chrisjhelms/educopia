#!/usr/bin/env python
'''Status Reporter

based on polorus.py 
$Author: $
$Revision: $
$Id: $''' 

import scriptinit

import sys; 

from lockssscript import * 
from lockss_util import log
from status.models import * 

class ReportCommPeerScript(LockssScript):
    MYCONFIGS = { 
            'dir':           ".",
            'serverlist':    None
    }
    
    def __init__(self, argv0):
        LockssScript.__init__(self, argv0, '$Revision: $', ReportCommPeerScript.MYCONFIGS) 
        
    def _create_opt_parser(self):
        option_parser = LockssScript._create_parser(self, False, True)
        option_parser.add_option('-S', '--serverlist',
                        action='append',
                        help='server with port ')
        
        option_parser.add_option('-o', '--outputdir',
                        dest= 'dir', 
                        help="Directory for output files [defaults to server's domain name]")
        
        option_parser.add_option('--noquit', 
                        action='store_true',
                        help = "repeat status data requests for failed auids until all succeed" )
        
        return option_parser

    ''' 
    in addition to LockssScript.check_option: 
    checking that 
        at least on action is given 
        credentials are given with get actions 
    '''
    def check_opts(self):
        print "chek_opts"
        LockssScript.check_opts(self)
        # options.server comes from commmand line args 
        # options.serverlist comes from config files  
        # server command line  arg take precendence over args from config files 
        if (self.options.server): 
            self.options.serverlist = self.parse_server(self.options.server)
        else:
            print self.options.serverlist
            if (self.options.serverlist.__class__ == str):
                self.options.serverlist = self.options.serverlist.split('\n')
            serverlist = self.options.serverlist
            self.options.serverlist = []
            for a in serverlist:
                a = a.strip() 
                if (a): 
                    self.options.serverlist.append(self.parse_server(a))
    
        print self.options.serverlist
        if (not self.options.serverlist):
            self.option_parser.error( "Must give at least one server")

        if (not os.path.exists(self.options.dir)):
            os.mkdir(self.options.dir)
        
        self.require_credentials()
        print self.options
 
    def log_opts(self):
        LockssScript.log_opts(self)
        for a in self.options.serverlist: 
            log.info("SERVER = %s", a)
        
    '''
    if dryrun collect matching auids and log.info them
    otherwise preform all requested actions 
    '''
    def process(self):
        log.info("---") 
        log.info("Start Processing") 
    
        if (self.options.dryrun):
            return
            
        options = self.options 
        
        for server in self.options.serverlist: 
            self.cache = self.get_cache(server[0], server[1], 
                                     True, options.username, options.password)
            log.info(Action.GETCOMMPEERS + " cache: " +  self.cache.domain)
            self.getcommpeers(options.dir, options.noquit)
            LockssCacheCommPeer.printcsv(sys.stdout, self.cache)
                
        log.info("Stop Processing") 
 
def testargs(pwd, cache="rbdadmin.lib.auburn.edu:8081", user="snoop", action="getcommpeers"): 
    cmd = "cmd -r %s -u %s -p %s -l 1" % (cache, user, pwd)    
    if (action): 
        cmd = cmd + " -a " + action
    print cmd;
    return cmd.split(" ")

def __test():   
    global script
    pwd = raw_input("pwd> ")
    sys.argv = testargs(pwd)
    script = ReportCommPeerScript(sys.argv[0])
    script.process()
    return script
     
def __main(): 
    global script
    print sys.argv
    script = ReportCommPeerScript(sys.argv[0])
    script.process()
    
    return 0
                    
if __name__ == '__main__':
    __main()
        
