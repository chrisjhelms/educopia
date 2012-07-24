#!/usr/bin/env python
'''Status Reporter
$Author: mmevenk $
$Revision: 3839 $
$Id: $'''

import scriptinit

import sys

from lockssscript import *
from lockss_util import log
from status.models import *


class ReportAuProfile(ReportScript):
    '''
    if dryrun collect matching auids and log.info them
    otherwise collect stored data (do not update from LOCKSS caches) and print a report
    if --problemsOnly is given list only troubled archival units, that is archival units that have too few replications,
    whose agreement is low
    '''

    HEADEREXPLANATIONS =  {
     "auid" : "LOCKSS Archival Unit id",
     "repl" : "Number of known archival unit replications",
     'lowrepl' : "True if repl is below given repl threshold parameter",
     "replserver" : "Number of known archival unit replications on servers listed in report parameters, see caches",
     'lowreplserver': "True if replserver is below given replserver threshold parameter",
     'nausummary' : "Number of archival unit summary information entries found related to the servers listed in report parameters",
     'missingauinfo' : "True iff nausummary is smaller than replserver",
     'nLowAgree' :  "number of archival units with agreement values smaller than the agreement threshold parameter",
      "sizeMB avg" : "average of archival unit size stated in archival unit summaries for servers listed in report parameters",
      "sizeMB min" : "minimum of archival unit size stated in archival unit summaries for servers listed in report parameters",
      "sizeMB max" : "maximum of archival unit size stated in archival unit summaries for servers listed in report parameters",
      "sizeMB sum" : "sum of archival unit size stated in archival unit summaries for servers listed in report parameters",
      "diskMB avg" : "average of archival unit disk usage stated in archival unit summaries for servers listed in report parameters",
      "diskMB min" : "minimum of archival unit disk usage stated in archival unit summaries for servers listed in report parameters",
      "diskMB max" : "maximum of archival unit disk usage stated in archival unit summaries for servers listed in report parameters",
      "diskMB sum" : "sum of archival unit disk usage stated in archival unit summaries for servers listed in report parameters",
      "agree avg" : "average of archival unit agreement stated in archival unit summaries for servers listed in report parameters",
      "agree min" : "minimum of archival unit agreement stated in archival unit summaries for servers listed in report parameters",
      "agree max" : "maximum of archival unit agreement stated in archival unit summaries for servers listed in report parameters",
      "reportDate min" : "date of oldest archival unit agreement info",
      "reportDate max" : "date of youngest archival unit agreement info",
      "caches" : "lists those servers given as report parameters where archival unit is know to be preserved. see replserver"
    };

    ALLHEADERS = sorted(HEADEREXPLANATIONS.keys())

    DEFAULTHEADERS = ["auid",
                  "replserver", 'lowreplserver',
                  'nLowAgree',
                  "sizeMB avg",
                  "diskMB avg",
                  "agree avg",
                  "reportDate min", "reportDate max",
                  "caches" ];

    MYCONFIGS = {
            'replserver':     6,
            'repl':           6,
            'agreement':      95.0,
            'reportheaders':  ",".join(DEFAULTHEADERS),
            'problemsonly':   False
            };

    def __init__(self, argv0):
        ReportScript.__init__(self, argv0, '$Revision: 3839 $', self.__class__.MYCONFIGS)

    def _create_opt_parser(self):
        option_parser = ReportScript._create_opt_parser(self)

        option_parser.add_option('--agreement',
                                type='float',
                                help='minimum acceptable agreement [%default]')

        option_parser.add_option("--problemsonly",  action="store_true",
                          help='restrict listing to troubled archival units [%default]')

        option_parser.add_option('--replserver',  dest="replserver",
                                type='int',
                                help='mark as error archival units those with less replications on given servers  [%default]')

        option_parser.add_option('--repl',
                                type='int',
                                help='mark as error archival units those with less total known replications  [%default]')

        return option_parser

    def check_opts(self):
        ReportScript.check_opts(self, logopts=True)
        self.require_auids()

    def add_value(self, val, key, prof):
        if (val != None):
            if (prof['min'] == None):
                # first value
                prof['min'] = val
                prof['max'] = val
                if (prof.has_key('sum')):
                    prof['sum'] = val
                return 1, prof

            # add value; keep track ofmin,max,sum
            if (val < prof['min']):
                prof['min'] = val
            if (val > prof['max']):
                prof['max'] = val
            if (prof.has_key('sum')):
                prof['sum'] = prof['sum'] + val
            return 1, prof
        return 0, prof

    def process(self):
        log.info("---")
        log.info("Start Processing")

        if (self.options.explainheaders):
            print ReportScript.explainheaders(self);
            return;
        
        if (self.options.dryrun):
            return
        
        opts = self.options.__dict__
        print "# COMMAND", self.options._COMMAND;
        for key in ['repl', 'replserver', 'agreement']:
            if (opts.has_key(key)):
                print "#", key, opts.get(key);
        print "# ";

        if (self.options.problemsonly):
            print "# listing only archival units that appear to have a problem"
            print "# ";

        masterAuIds = self.collectMasterAuIdInstances()
        print self.report_preamble(); 

        headers = self.options.reportheaders;
        print "\t".join(headers);
        for mauid in masterAuIds:
            auids = LockssCacheAuId.objects.filter(Q( auId = mauid.auId ), self.get_Q_caches())
            repl =  mauid.replication()
            replserver = auids.count()

            prof = {    'auid' : mauid.auId,
                        'repl': repl,
                        'lowrepl' : repl < self.options.repl,
                        'replserver' : replserver,
                        'lowreplserver' : replserver < self.options.replserver,
                        'nLowAgree' : 0,
                        'reportDate' : { 'min' : None, 'max' : None },
                        'nausummary': None,
                        'missingauinfo': False,
                        'sizeMB' : { 'min' : None, 'max' : None, 'avg' : None, 'sum' : None },
                        'diskMB' : { 'min' : None, 'max' : None, 'avg' : None, 'sum' : None },
                        'agree' : { 'min' : None, 'max' : None, 'avg' : None, 'sum' : None },
                        'caches' : []
                        }
            nagree = 0;
            nlausum = 0
            for au in auids:
                lau = au.getlocksscacheausummary()
                if (lau):
                    nlausum = nlausum + 1
                    if (lau.agreement < self.options.agreement):
                        prof['nLowAgree'] = prof['nLowAgree'] + 1
                    delta, prof['agree'] = self.add_value(lau.agreement, 'agree', prof['agree'])
                    nagree = nagree + delta

                    delta, prof['sizeMB'] = self.add_value(lau.contentSizeMB(), 'sizeMB', prof['sizeMB'])
                    assert delta == 1,  "%s sizeMB: %s" % (str(lau), str(prof['sizeMB']))
                    delta, prof['diskMB'] = self.add_value(lau.diskUsageMB, 'sizeMB', prof['diskMB'])
                    assert delta == 1,  "%s diskMB: %s" % (str(lau), str(prof['diskMB']))
                    delta, prof['reportDate'] = self.add_value(lau.reportDate, 'reportDate', prof['reportDate'])
                    assert delta == 1,  "%s reportDare: %s" % (str(lau), str(prof['reportDate']))
                else:
                    prof['missingauinfo'] = True
                prof['caches'].append(au.cache.name)

            prof['caches'] = sorted(prof['caches']);
            
            prof['nausummary'] = nlausum;
            if (nagree > 0):
                prof['agree']['avg'] = prof['agree']['sum'] / nagree;
            if (nlausum > 0):
                prof['sizeMB']['avg'] = prof['sizeMB']['sum'] / nlausum;
                prof['diskMB']['avg'] = prof['diskMB']['sum'] / nlausum;

            if ((not self.options.problemsonly) or
                prof['lowrepl'] or prof['lowreplserver'] or prof['nLowAgree'] > 0):
                vals = [];
                for f in headers:
                    keys = f.split(" ");
                    if (len(keys) == 1):
                        v = prof[f]
                    else:
                        v = prof[keys[0]][keys[1]]
                    if (v.__class__ == float):
                        v = "%.2f" % v
                    elif (v.__class__ == list):
                        v = "\t".join(sorted(v))
                    vals.append(str(v))
                print "\t".join(vals)

        log.info("Stop Processing")

def testargs(pwd, server="rbdadmin.lib.auburn.edu:8081", user="snoop"):
    cmd = "cmd -r %s -u %s -p %s  --all" % (server, user, pwd)
    print cmd;
    return cmd.split(" ")

def __test():
    global script
    pwd = raw_input("pwd> ")
    sys.argv = testargs(pwd)
    script = ReportAuProfile(sys.argv[0])
    script.process()
    return script

def __main():
    global script
    script = ReportAuProfile(sys.argv[0])
    script.process()

    return 0

if __name__ == '__main__':
    __main()


