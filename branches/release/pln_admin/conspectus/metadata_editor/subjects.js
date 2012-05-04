
function generate_dropdown_esc_subjects(name) {
	var newselect = document.createElement("select");
	newselect.setAttribute('name', name);
	newselect.setAttribute('id', name);
	var newoption;
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "transportation");
	newoption.appendChild(document.createTextNode("Transportation"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "history_and_manners");
	newoption.appendChild(document.createTextNode("History, Manners, and Myth"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "foodways");
	newoption.appendChild(document.createTextNode("Foodways"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "geography");
	newoption.appendChild(document.createTextNode("Geography"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "religion");
	newoption.appendChild(document.createTextNode("Religion"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "ethnic_life");
	newoption.appendChild(document.createTextNode("Ethnicity"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "race");
	newoption.appendChild(document.createTextNode("Race"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "environment");
	newoption.appendChild(document.createTextNode("Environment"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "language");
	newoption.appendChild(document.createTextNode("Language"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "literature");
	newoption.appendChild(document.createTextNode("Literature"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "music");
	newoption.appendChild(document.createTextNode("Music"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "law_and_pol");
	newoption.appendChild(document.createTextNode("Law and Politics"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "media");
	newoption.appendChild(document.createTextNode("Media"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "recreation");
	newoption.appendChild(document.createTextNode("Recreation"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "folklife");
	newoption.appendChild(document.createTextNode("Folklife"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "folk_art");
	newoption.appendChild(document.createTextNode("Folk Art"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "art_and_architecture");
	newoption.appendChild(document.createTextNode("Art and Architecture"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "gender");
	newoption.appendChild(document.createTextNode("Gender"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "social_class");
	newoption.appendChild(document.createTextNode("Social Class"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "bus_agr_ind");
	newoption.appendChild(document.createTextNode("Business, Agriculture, and Industry"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "science_and_medicine");
	newoption.appendChild(document.createTextNode("Science and Medicine"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "urbanization");
	newoption.appendChild(document.createTextNode("Urbanization"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "violence");
	newoption.appendChild(document.createTextNode("Violence"));
	newselect.appendChild(newoption);
	
	newoption = document.createElement("option");
	newoption.setAttribute('value', "education");
	newoption.appendChild(document.createTextNode("Education"));
	newselect.appendChild(newoption);
	

	return newselect;
}

function add_esc_field(name) {
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
	newdiv.appendChild(generate_dropdown_esc_subjects(new_item));
	elem.parentNode.appendChild(newdiv);
	var reminput = document.createElement("a");
	reminput.setAttribute('href', "javascript:remove_elem_div('"+ name +
		"','"+ new_item+ "')");
	reminput.appendChild(document.createTextNode("Remove"));
	newdiv.appendChild(reminput);
	newdiv.appendChild(document.createElement('br'));
}

