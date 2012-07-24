from django.db import models

from status.models.locksscacheauid        import LockssCacheAuId
from status.models.austatus     import LockssCacheAuSummary; 

class LockssUrl(models.Model):
    class Meta: 
        app_label = "status"

    auId = models.ForeignKey(LockssCacheAuId)
    auSummary = models.ForeignKey(LockssCacheAuSummary, db_index=True)
    name = models.TextField(max_length=1024)
    childCount = models.IntegerField()
    treeSize = models.BigIntegerField()
    size = models.IntegerField()
    version = models.IntegerField(blank=True,null=True)  
    
    list_display = ( 'auSummary', 'name', 'version' )
    
