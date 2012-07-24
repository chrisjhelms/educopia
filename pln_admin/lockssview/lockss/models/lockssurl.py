from django.db import models

from lockss.models.locksscacheauid        import LockssCacheAuId
from lockss.models.austatus     import LockssCacheAuSummary; 

class LockssUrl(models.Model):
    auId = models.ForeignKey(LockssCacheAuId)
    auSummary = models.ForeignKey(LockssCacheAuSummary, db_index=True)
    name = models.TextField(max_length=1024)
    childCount = models.IntegerField()
    treeSize = models.BigIntegerField()
    size = models.IntegerField()
    version = models.IntegerField(blank=True,null=True)  
    
    list_display = ( 'auSummary', 'name', 'version' )
    
