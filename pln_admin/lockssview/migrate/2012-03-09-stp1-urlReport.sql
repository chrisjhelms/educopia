-- phpMyAdmin SQL Dump
-- version 3.3.10deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Mar 09, 2012 at 12:02 PM
-- Server version: 5.1.54
-- PHP Version: 5.3.5-1ubuntu7.4

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `lockssview`
--

-- --------------------------------------------------------

--
-- Table structure for table `status_url`
--

CREATE TABLE IF NOT EXISTS `status_url` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `urlReport_id` int(11) NOT NULL,
  `name` longtext NOT NULL,
  `childCount` int(11) NOT NULL,
  `treeSize` bigint(20) NOT NULL,
  `size` int(11) NOT NULL,
  `version` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `status_url_15a4e98c` (`urlReport_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `status_url`
--


-- --------------------------------------------------------

--
-- Table structure for table `status_urlreport`
--

CREATE TABLE IF NOT EXISTS `status_urlreport` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reportDate` datetime NOT NULL,
  `auId_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auId_id` (`auId_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `status_urlreport`
--


