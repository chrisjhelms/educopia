
function generate_dropdown_application(name) {
	var newselect = document.createElement("select");
	newselect.setAttribute('name', name);
	newselect.setAttribute('id', name);
	var newoption;
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('http'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('hyperstudio'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('mathematica'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('mpeg4-generic'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('msword'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('ogg'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('pdf'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('postscript'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('rdf+xml'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('rtf'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('sgml'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('xhtml+xml'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('xml'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('xml-dtd'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('xml-external-parsed-entity'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('zip'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('Other...'));
	newselect.appendChild(newoption);

	newselect.style.display='none';
	return newselect;
}

function generate_dropdown_audio(name) {
	var newselect = document.createElement("select");
	newselect.setAttribute('name', name);
	newselect.setAttribute('id', name);
	var newoption;
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('x-aiff'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('x-gsm'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('x-mpegurl'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('x-wav'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('x-ms-wma'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('x-ms-wax'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('x-realaudio'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('Other...'));
	newselect.appendChild(newoption);

	newselect.style.display='none';
	return newselect;
}

function generate_dropdown_image(name) {
	var newselect = document.createElement("select");
	newselect.setAttribute('name', name);
	newselect.setAttribute('id', name);
	var newoption;
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('cgm'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('gif'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('ief'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('jpeg'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('mng'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('png'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('tiff'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('Other...'));
	newselect.appendChild(newoption);

	newselect.style.display='none';
	return newselect;
}

function generate_dropdown_text(name) {
	var newselect = document.createElement("select");
	newselect.setAttribute('name', name);
	newselect.setAttribute('id', name);
	var newoption;
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('css'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('html'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('plain'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('richtext'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('sgml'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('xml'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('xml-external-parsed-entity'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('Other...'));
	newselect.appendChild(newoption);

	newselect.style.display='none';
	return newselect;
}

function generate_dropdown_video(name) {
	var newselect = document.createElement("select");
	newselect.setAttribute('name', name);
	newselect.setAttribute('id', name);
	var newoption;
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('mpeg'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('mpeg4-generic'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('quicktime'));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.appendChild(document.createTextNode('Other...'));
	newselect.appendChild(newoption);

	newselect.style.display='none';
	return newselect;
}

function addmimefield(name) {
	var new_item = name;
	var elem = document.getElementById(name);
	if(elem.value == "") {
		new_item += 0;
		next_items[name] = 1;
		elem.value = new_item;
	} else {
		new_item += next_items[name];
		next_items[name] = next_items[name] + 1;
		elem.value += "," + new_item;
	}
	var newdiv = document.createElement("div");
	newdiv.setAttribute('id', new_item + "_div");
	newdiv.setAttribute('class','type_selector');
	var newselect = document.createElement("select");
	newselect.setAttribute('id', new_item);
	newselect.setAttribute('name', new_item);
	if(navigator.userAgent.indexOf("MSIE") == -1) {
		newselect.setAttribute('onchange',
			"changemimefield('" + new_item + "')");
	} else {
		newselect.attachEvent('onchange', changemimefield_event);
	}
	newdiv.appendChild(newselect);
	var newoption;
	var childsel;
	
	newoption = document.createElement('option');
	newoption.appendChild(document.createTextNode('application'));
	newselect.appendChild(newoption);
	childsel = generate_dropdown_application(new_item+"_application",new_item);
	if(navigator.userAgent.indexOf("MSIE") == -1) {
		childsel.setAttribute('onchange', "changemimesub('" + new_item + "_application','" + new_item + "_text_other')")
	} else {
		childsel.attachEvent('onchange', changemimesub_event);
	}
	newdiv.appendChild(childsel);
	
	newoption = document.createElement('option');
	newoption.appendChild(document.createTextNode('audio'));
	newselect.appendChild(newoption);
	childsel = generate_dropdown_audio(new_item+"_audio",new_item);
	if(navigator.userAgent.indexOf("MSIE") == -1) {
		childsel.setAttribute('onchange', "changemimesub('" + new_item + "_audio','" + new_item + "_text_other')")
	} else {
		childsel.attachEvent('onchange', changemimesub_event);
	}
	newdiv.appendChild(childsel);
	
	newoption = document.createElement('option');
	newoption.appendChild(document.createTextNode('image'));
	newselect.appendChild(newoption);
	childsel = generate_dropdown_image(new_item+"_image",new_item);
	if(navigator.userAgent.indexOf("MSIE") == -1) {
		childsel.setAttribute('onchange', "changemimesub('" + new_item + "_image','" + new_item + "_text_other')")
	} else {
		childsel.attachEvent('onchange', changemimesub_event);
	}
	newdiv.appendChild(childsel);
	
	newoption = document.createElement('option');
	newoption.appendChild(document.createTextNode('text'));
	newselect.appendChild(newoption);
	childsel = generate_dropdown_text(new_item+"_text",new_item);
	if(navigator.userAgent.indexOf("MSIE") == -1) {
		childsel.setAttribute('onchange', "changemimesub('" + new_item + "_text','" + new_item + "_text_other')")
	} else {
		childsel.attachEvent('onchange', changemimesub_event);
	}
	newdiv.appendChild(childsel);
	
	newoption = document.createElement('option');
	newoption.appendChild(document.createTextNode('video'));
	newselect.appendChild(newoption);
	childsel = generate_dropdown_video(new_item+"_video",new_item);
	if(navigator.userAgent.indexOf("MSIE") == -1) {
		childsel.setAttribute('onchange', "changemimesub('" + new_item + "_video','" + new_item + "_text_other')")
	} else {
		childsel.attachEvent('onchange', changemimesub_event);
	}
	newdiv.appendChild(childsel);
	
	var newinput = document.createElement('input');
	newinput.setAttribute('name', new_item + "_text_other");
	newinput.setAttribute('id', new_item + "_text_other");
	newinput.setAttribute('type', "text");
	newinput.setAttribute('size', "40");
	newinput.setAttribute('value', "");
	newinput.style.display="none";
	newdiv.appendChild(newinput);
	elem.parentNode.appendChild(newdiv);
	var reminput = document.createElement("a");
	reminput.setAttribute('href', "javascript:remove_elem_div('"+ name +
		"','"+ new_item+ "')");
	reminput.appendChild(document.createTextNode("Remove"));
	newdiv.appendChild(reminput);
	newdiv.appendChild(document.createElement('br'));
	
	changemimefield(new_item);
}

function changemimesub_event() {
	var name = event.srcElement.name;
	var us_index = name.indexOf("_");
	name = name.substring(0,us_index);
	changemimesub(event.srcElement.name, name+"_text_other");
}

function changemimefield_event() {
	changemimefield(event.srcElement.name);
}

function changemimefield(name) {
	var elem = document.getElementById(name);
	var value;
	if(navigator.userAgent.indexOf("MSIE") == -1) {
		value = elem.value;
	} else {
		value = elem.options(elem.selectedIndex).value;
	}
	var tempselect;
	
	tempselect = document.getElementById(name+"_application");
	if(value == "application") {
		tempselect.style.display="";
		changemimesub(name+"_application",name+"_text_other");
	} else {
		tempselect.style.display="none";
	}
	
	tempselect = document.getElementById(name+"_audio");
	if(value == "audio") {
		tempselect.style.display="";
		changemimesub(name+"_audio",name+"_text_other");
	} else {
		tempselect.style.display="none";
	}
	
	tempselect = document.getElementById(name+"_image");
	if(value == "image") {
		tempselect.style.display="";
		changemimesub(name+"_image",name+"_text_other");
	} else {
		tempselect.style.display="none";
	}
	
	tempselect = document.getElementById(name+"_text");
	if(value == "text") {
		tempselect.style.display="";
		changemimesub(name+"_text",name+"_text_other");
	} else {
		tempselect.style.display="none";
	}
	
	tempselect = document.getElementById(name+"_video");
	if(value == "video") {
		tempselect.style.display="";
		changemimesub(name+"_video",name+"_text_other");
	} else {
		tempselect.style.display="none";
	}
	
}

function changemimesub(name,text) {
	var elem = document.getElementById(name);
	var other = document.getElementById(text);
	var value;
	if(navigator.userAgent.indexOf("MSIE") == -1) {
		value = elem.value;
	} else {
		value = elem.options(elem.selectedIndex).value;
	}
	if(value == "Other...") {
		other.style.display="";
	} else {
		other.style.display="none";
	}
}

