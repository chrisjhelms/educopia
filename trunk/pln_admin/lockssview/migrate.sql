--
-- Table structure for table `lockssview_locksscrawlstatus`
--

ALTER TABLE `thetable` 
  DROP KEY `oldkey`; 

ALTER TABLE `thetable` 
  ADD KEY `newkey` (`field`); 

