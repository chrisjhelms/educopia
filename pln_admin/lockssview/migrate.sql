ALTER TABLE `status_locksscache`  RENAME TO lockssview_locksscache;
ALTER TABLE `status_locksscacheauid`  RENAME TO lockssview_locksscacheauid;
ALTER TABLE `status_locksscacheausummary`  RENAME TO lockssview_locksscacheausummary;
ALTER TABLE `status_locksscrawlstatus`  RENAME TO lockssview_locksscrawlstatus;
ALTER TABLE `status_masterauid`  RENAME TO lockssview_masterauid;
ALTER TABLE `status_repositoryspace`  RENAME TO lockssview_repositoryspace;
ALTER TABLE `status_url`  RENAME TO lockssview_url;
ALTER TABLE `status_urlreport`  RENAME TO lockssview_urlreport;
DROP TABLE status_lockssurl;

