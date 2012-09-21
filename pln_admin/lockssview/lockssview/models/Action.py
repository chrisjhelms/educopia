import inspect; 
#print ">> ", inspect.getfile(inspect.currentframe())


'''
GETAUIDLIST    - request AUIDs from server and store as know archival units 
GETAUSUMMARY   - request archival unit summary of selectd archival units  
GETCRAWLSTATUS - request crawl information of selected archival units    
GETURLLIST     - request urllist of selected archival units 
GETCOMMPEERS   - request info from Comm Peers Table 
GETREPOSSPACE  - request info on repository space 

PRTAUIDLIST    - print know archival units 
PRTAUSUMMARY   - print profile summary of selectd archival units  
PRTURLLIST     - print urllist for selected auids 
PRTCRAWLSTATUS - print crawl information of selected archival units  
PRTCOMMPEERS   - print comm peers info  
GETREPOSSPACE  - print repository space info 
'''
class Action:
    GETAUSUMMARY = 'getausummary'
    GETCRAWLSTATUS = 'getcrawlstatus'
    GETURLLIST = 'geturllist'
    GETAUIDLIST = 'getauidlist'
    GETCOMMPEERS = "getcommpeers"
    GETREPOSSPACE = 'getreposspace';
     
    PRTAUSUMMARY = 'printausummary'
    PRTURLLIST = 'printurllist'
    PRTAUIDLIST = 'printauidlist'
    PRTCRAWLSTATUS = "printcrawlstatus"
    PRTCOMMPEERS = "printcommpeers"
    PRTREPOSSPACE = 'printreposspace';
 
    values = [GETAUSUMMARY, GETCRAWLSTATUS, GETURLLIST, GETAUIDLIST, 
                    GETREPOSSPACE, GETCOMMPEERS,
                    PRTAUSUMMARY, PRTCRAWLSTATUS, PRTURLLIST, PRTAUIDLIST, 
                    PRTREPOSSPACE, PRTCOMMPEERS,
                ]

    need_auids = [GETAUSUMMARY, GETCRAWLSTATUS, GETURLLIST, 
                    PRTAUSUMMARY, PRTCRAWLSTATUS, PRTURLLIST ]

    need_credentials = [GETAUSUMMARY, GETCRAWLSTATUS, GETURLLIST, GETAUIDLIST, 
                   GETREPOSSPACE, GETCOMMPEERS]

    need_dir = [PRTAUSUMMARY, PRTCRAWLSTATUS, PRTURLLIST, PRTAUIDLIST, 
                   PRTREPOSSPACE, PRTCOMMPEERS ]

