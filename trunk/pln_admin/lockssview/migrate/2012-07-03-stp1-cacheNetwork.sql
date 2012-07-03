ALTER TABLE `status_locksscache` ADD `network` VARCHAR( 16 ) NOT NULL ;
UPDATE `status_locksscache` SET `network` = 'production' ;

