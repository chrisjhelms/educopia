var next_items = new Array();

function unhidediv(name) {
    var elem = document.getElementById(name);

    if(elem.style.display != "none") {
        elem.style.display = "none";
    } else {
        elem.style.display = "";
    }
	
}

function show_radio_summary(name) {

}

function show_content(name) {
	unhidediv(name + "-content");

    var elem = document.getElementById(name + "-content");
	
	var link_elem = document.getElementById(name+"-link");
    if(elem.style.display != "none") {
		link_elem.firstChild.nodeValue = "-";
	} else {
		link_elem.firstChild.nodeValue = "+";
	}
}

function create_month_select(name) {
	var months = [[1,'January'],[2,'February'], [3,'March'], [4,'April'],
		[5, 'May'], [6, 'June'], [7, 'July'], [8, 'August'], [9, 'September'],
		[10, 'October'], [11, 'November'], [12, 'December'], [0, 'None']];

	var new_select = document.createElement('select');
	new_select.setAttribute('name', name);
	new_select.setAttribute('id', name);
	var new_option;

	for(var i =0; i< months.length; i++) {
		new_option = document.createElement("option");
		new_option.setAttribute('value', months[i][0]);
		new_option.appendChild(document.createTextNode(months[i][1]));
		new_select.appendChild(new_option);
	}

	return new_select;
}

function add_date_field(name) {
	var new_item = name;
	var elem = document.getElementById(name);
	if(elem.value == "" || elem.value == "undefined") {
		new_item += 0;
		next_items[name] = 1;
		elem.value = new_item;
	} else {
		new_item += next_items[name];
		next_items[name] = next_items[name] + 1;
		elem.value += "," + new_item;
	}

	var newdiv= document.createElement("div");
	newdiv.setAttribute('id', new_item);

	newdiv.appendChild(document.createTextNode('Start:'));
	var newinput = document.createElement("input");
	newinput.setAttribute('name', new_item + "_start_year");
	newinput.setAttribute('type', "text");
	newinput.setAttribute('size', "10");
	newinput.setAttribute('value', "");
	newdiv.appendChild(newinput);
	newdiv.appendChild(create_month_select(new_item + "_start_month"));
	newdiv.appendChild(document.createElement("br"));

	newdiv.appendChild(document.createTextNode('End:'));
	newinput = document.createElement("input");
	newinput.setAttribute('name', new_item + "_end_year");
	newinput.setAttribute('type', "text");
	newinput.setAttribute('size', "10");
	newinput.setAttribute('value', "");
	newdiv.appendChild(newinput);
	newdiv.appendChild(create_month_select(new_item + "_end_month"));

	newdiv.appendChild(document.createElement("br"));
	var reminput = document.createElement("a");
	reminput.setAttribute('href', "javascript:remove_elem('"+ name +
		"','"+ new_item +"')");
	reminput.appendChild(document.createTextNode('Remove'));
	newdiv.appendChild(reminput);
	
	elem.parentNode.appendChild(newdiv);

}	

function initiate_mime_field(name, count) {
	next_items[name] = count;
	var elem = document.getElementById(name + "-add");
	elem.setAttribute("href", "javascript:addmimefield('" + name + "')");
	addmimefield(name);
}

function initiate_esc_field(name, count) {
	next_items[name] = count;
	var elem = document.getElementById(name + "-add");
	elem.setAttribute("href", "javascript:add_esc_field('" + name + "')");
	add_esc_field(name);
}

function initiate_multi_text_field(name, count) {
	next_items[name] = count;
	var elem = document.getElementById(name + "-add");
	elem.setAttribute("href", "javascript:addfield('" + name + "')");
	addfield(name);
}

function initiate_date_field(name, count) {
	next_items[name] = count;
	var elem = document.getElementById(name + "-add");
	elem.setAttribute("href", "javascript:add_date_field('" + name + "')");
	add_date_field(name);
}

function addfield(name) {
	var new_item = name;
	var elem = document.getElementById(name);
	if(elem.value == "" || elem.value == "undefined") {
		new_item += 0;
		next_items[name] = 1;
		elem.value = new_item;
	} else {
		new_item += next_items[name];
		next_items[name] = next_items[name] + 1;
		elem.value += "," + new_item;
	}

	var newinput = document.createElement("input");
	newinput.setAttribute('name', new_item);
	newinput.setAttribute('type', "text");
	newinput.setAttribute('size', "40");
	newinput.setAttribute('value', "");

	var reminput = document.createElement("a");
	reminput.setAttribute('href', "javascript:remove_elem('"+ name +
		"','"+ new_item +"')");
	reminput.appendChild(document.createTextNode('Remove'));
	
	var newdiv= document.createElement("div");
	newdiv.setAttribute('id', new_item);
	newdiv.appendChild(newinput);
	newdiv.appendChild(reminput);
	newdiv.appendChild(document.createElement("br"));

	elem.parentNode.appendChild(newdiv);

}	

function set_elem_count(name, count) {
	next_items[name] = count;
}

function remove_elem(name, item) {
	var elem = document.getElementById(item);
	elem.parentNode.removeChild(elem);

	var elem = document.getElementById(name);
	var arr = elem.value.split(",");

	elem.value = "";

	if(arr[0] == item) {
		elem.value += arr[1];
		for(var i=2;i<arr.length;i++) {
			elem.value += "," + arr[i];
		}
	} else {
		elem.value += arr[0];
		for(var i=2;i<arr.length;i++) {
			if(arr[i].value != item) elem.value += "," + arr[i];
		}
	}

}

function remove_elem_div(name, item) {
	var elem = document.getElementById(item + "_div");
	elem.parentNode.removeChild(elem);

	var elem = document.getElementById(name);
	var arr = elem.value.split(",");

	elem.value = "";

	if(arr[0] == item) {
		elem.value += arr[1];
		for(var i=2;i<arr.length;i++) {
			elem.value += "," + arr[i];
		}
	} else {
		elem.value += arr[0];
		for(var i=2;i<arr.length;i++) {
			if(arr[i].value != item) elem.value += "," + arr[i];
		}
	}

}

function validate_and_submit(required) {
	var done = true;

	for(var i=0;i<required.length;i++) {
		var elem = document.getElementById(required[i][0]);
		var table_elem = document.getElementById("table_"+required[i][0]);
		if(!elem || elem.value == '' || elem.value == 'undefined') {
			if(elem.checked) {
				table_elem.style.backgroundColor="#ffffff";
			} else {
				table_elem.style.backgroundColor="#ff0000";
				alert(required[i][1] + " is a required field");
				done = false;
			}
		} else {
			table_elem.style.backgroundColor="#ffffff";
		}
	}
	
	if(done) {
		if(document.mainform.Submit) {
			document.mainform.Submit();
		} else {
			document.mainform.submit();
		}
	}
	
	return false;
}

