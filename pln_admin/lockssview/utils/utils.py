class Utils:
    
    @staticmethod
    def stringToArray(str, fieldlist):
        hdrs =[] 
        for h in str.split(","):
            h = h.strip() 
            if (h in fieldlist):
                hdrs.append(h) 
            else: 
                raise RuntimeError, "'%s' not valid" % (h)
        return hdrs
