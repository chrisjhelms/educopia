CREATE TABLE IF NOT EXISTS `status_repositoryspace` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cache_id` int(11) NOT NULL,
  `sizeMB` double NOT NULL,
  `usedMB` double NOT NULL,
  `repo` varchar(32) NOT NULL,
  `reportDate` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `status_repositoryspace_f9d3b7c3` (`cache_id`),
  KEY `cache_id` (`cache_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;
