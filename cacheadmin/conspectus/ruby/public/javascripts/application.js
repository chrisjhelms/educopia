// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// from http://plugins.jquery.com/project/createXMLDocument
// Submitted by JustinN on June 11, 2008 - 11:45am
//
// Name: createXMLDocument
// Input: String
// Output: XML Document
jQuery.createXMLDocument = function(string)
{
  var browserName = navigator.appName;
  var doc;
  if (browserName == 'Microsoft Internet Explorer')
  {
    doc = new ActiveXObject('Microsoft.XMLDOM');
    doc.async = 'false'
    doc.loadXML(string);
  } else {
    doc = (new DOMParser()).parseFromString(string, 'text/xml');
  }
  return doc;
}

