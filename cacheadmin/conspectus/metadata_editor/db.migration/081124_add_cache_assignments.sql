CREATE TABLE IF NOT EXISTS `cache_assignments` (
`value` text NOT NULL ,
`collection_id` int( 10 ) unsigned NOT NULL default '0',
KEY `collection_id` ( `collection_id` )
) ENGINE = InnoDB DEFAULT CHARSET = latin1;
