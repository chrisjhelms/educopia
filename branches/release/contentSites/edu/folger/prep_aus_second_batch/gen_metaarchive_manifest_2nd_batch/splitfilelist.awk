function round(x,   ival, aval, fraction)
     {
        ival = int(x)    # integer part, int() truncates
     
        # see if fractional part
        if (ival == x)   # no fraction
           return ival   # ensure no decimals
        return ival + 1;  
     }

BEGIN { OFS = "\t"; } 
{ print $1, $2, $3, $4, round($4/$2), $5; } 
END { print "avg(GB)", "naus", "total(GB)", "nfiles", "nfiles/au", "dir"; }
