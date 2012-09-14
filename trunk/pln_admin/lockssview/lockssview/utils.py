
from lockss.lockss_util import LockssError;

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

def stringToArray(strng, fieldlist):
        hdrs =[] 
        for h in strng.split(","):
            h = h.strip() 
            if (h in fieldlist):
                hdrs.append(h) 
            else: 
                raise RuntimeError, "'%s' not valid" % (h)
        return hdrs
