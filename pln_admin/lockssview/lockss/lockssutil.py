from lockss_util import LockssError;

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


# UI time stamp format 
UI_STRFTIME = '%H:%M:%S %m/%d/%y'

def convertSizeString(sizeStr): 
    try: 
        num = float(sizeStr[0:-2]);
    except ValueError: 
        raise LockssError("Can't interprete size number %s" % sizeStr)
    dim = sizeStr[-2:len(sizeStr)]
    fac = 0; 
    if (dim == "MB"): 
        fac = 1; 
    elif (dim == "GB"):
        fac = 1024;  
    elif (dim == "TB"): 
        fac= 1024 * 1024; 
    if (fac == 0):  
        raise LockssError("Unknown size format in $s" % sizeStr); 
    return num *fac;

def getReposState(ui): 
    data = ui._getStatusTable('RepositorySpace');
    reposInfo = data[1];
    results = [];
    for ri in reposInfo: 
        vals = {};
        try: 
            vals['repo'] = ri['repo'];
            vals['sizeMB'] = convertSizeString(ri['size']); 
            vals['usedMB'] = convertSizeString(ri['used']); 
            results.append(vals);
        except KeyError:
            raise LockssError("received garbeled RepositorySpace info"); 
    return results; 

