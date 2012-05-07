-- MySQL dump 10.11
--
-- Host: localhost    Database: ma_conspectus
-- ------------------------------------------------------
-- Server version	5.0.68-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `alternative_title`
--

DROP TABLE IF EXISTS `alternative_title`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `alternative_title` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `catalogueor`
--

DROP TABLE IF EXISTS `catalogueor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `catalogueor` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `collection`
--

DROP TABLE IF EXISTS `collection`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `collection` (
  `collection_title` text,
  `about` text,
  `accrualpolicy` text,
  `extent` bigint(20) default NULL,
  `collection_desc` text,
  `provenance` text,
  `risk_factors` text,
  `accrualperiodicity` enum('null','no longer','daily','weekly','monthly','quarterly','yearly') default NULL,
  `accessrights` enum('null','unrestricted','restricted') default NULL,
  `harvestproc` enum('null','webcrawl','OAI harvest') default NULL,
  `riskrank` enum('null','5','4','3','2','1') default NULL,
  `manifestation_access` enum('true','false') default NULL,
  `manifestation_preservation` enum('true','false') default NULL,
  `manifestation_replacement` enum('true','false') default NULL,
  `catalogued_status_radio` enum('null','catalogued','partial','none') default NULL,
  `catalogued_status_text` text,
  `id` int(10) unsigned NOT NULL auto_increment,
  `public` enum('true','false') default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=187 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `created`
--

DROP TABLE IF EXISTS `created`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `created` (
  `start_year` int(10) unsigned default NULL,
  `start_month` int(10) unsigned default NULL,
  `end_year` int(10) unsigned default NULL,
  `end_month` int(10) unsigned default NULL,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `creator`
--

DROP TABLE IF EXISTS `creator`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `creator` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `date_contents_created`
--

DROP TABLE IF EXISTS `date_contents_created`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `date_contents_created` (
  `start_year` int(10) unsigned default NULL,
  `start_month` int(10) unsigned default NULL,
  `end_year` int(10) unsigned default NULL,
  `end_month` int(10) unsigned default NULL,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `esc_subject`
--

DROP TABLE IF EXISTS `esc_subject`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `esc_subject` (
  `value` varchar(64) default NULL,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `format`
--

DROP TABLE IF EXISTS `format`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `format` (
  `first` varchar(64) default NULL,
  `second` varchar(64) default NULL,
  `other` varchar(255) default NULL,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `haspart`
--

DROP TABLE IF EXISTS `haspart`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `haspart` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `identifier`
--

DROP TABLE IF EXISTS `identifier`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `identifier` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `isavailablevia`
--

DROP TABLE IF EXISTS `isavailablevia`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `isavailablevia` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `ispartof`
--

DROP TABLE IF EXISTS `ispartof`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `ispartof` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `isreferencedby`
--

DROP TABLE IF EXISTS `isreferencedby`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `isreferencedby` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `language`
--

DROP TABLE IF EXISTS `language`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `language` (
  `value` varchar(255) default NULL,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `lcsh_subject`
--

DROP TABLE IF EXISTS `lcsh_subject`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `lcsh_subject` (
  `value` varchar(255) default NULL,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `manifest`
--

DROP TABLE IF EXISTS `manifest`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `manifest` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mesh_subject`
--

DROP TABLE IF EXISTS `mesh_subject`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mesh_subject` (
  `value` varchar(255) default NULL,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `oai_provider`
--

DROP TABLE IF EXISTS `oai_provider`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `oai_provider` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `parameters`
--

DROP TABLE IF EXISTS `parameters`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `parameters` (
  `value` text NOT NULL,
  `collection_id` int(10) unsigned NOT NULL default '0',
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `plugin`
--

DROP TABLE IF EXISTS `plugin`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `plugin` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `publisher`
--

DROP TABLE IF EXISTS `publisher`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `publisher` (
  `value` varchar(255) default NULL,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `relation`
--

DROP TABLE IF EXISTS `relation`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `relation` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `rights`
--

DROP TABLE IF EXISTS `rights`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `rights` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `spatialcoverage`
--

DROP TABLE IF EXISTS `spatialcoverage`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `spatialcoverage` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `temporalcoverage`
--

DROP TABLE IF EXISTS `temporalcoverage`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `temporalcoverage` (
  `value` text,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `type`
--

DROP TABLE IF EXISTS `type`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `type` (
  `type_comp_anim` enum('true','false') default NULL,
  `type_comp_anim_count` int(10) unsigned default NULL,
  `type_complex` enum('true','false') default NULL,
  `type_complex_count` int(10) unsigned default NULL,
  `type_databases` enum('true','false') default NULL,
  `type_databases_count` int(10) unsigned default NULL,
  `type_datasets` enum('true','false') default NULL,
  `type_datasets_count` int(10) unsigned default NULL,
  `type_events` enum('true','false') default NULL,
  `type_events_count` int(10) unsigned default NULL,
  `type_interactive` enum('true','false') default NULL,
  `type_interactive_count` int(10) unsigned default NULL,
  `type_moving` enum('true','false') default NULL,
  `type_moving_count` int(10) unsigned default NULL,
  `type_physical` enum('true','false') default NULL,
  `type_physical_count` int(10) unsigned default NULL,
  `type_services` enum('true','false') default NULL,
  `type_services_count` int(10) unsigned default NULL,
  `type_software` enum('true','false') default NULL,
  `type_software_count` int(10) unsigned default NULL,
  `type_sound` enum('true','false') default NULL,
  `type_sound_count` int(10) unsigned default NULL,
  `type_still` enum('true','false') default NULL,
  `type_still_count` int(10) unsigned default NULL,
  `type_text` enum('true','false') default NULL,
  `type_text_count` int(10) unsigned default NULL,
  `collection_id` int(10) unsigned default NULL,
  KEY `collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `users` (
  `uid` int(10) unsigned NOT NULL auto_increment,
  `username` varchar(255) default NULL,
  `password` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  PRIMARY KEY  (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2008-12-01 14:45:49
