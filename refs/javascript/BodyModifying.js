// Body modifying
var string = '<div xmlns="http://www.w3.org/999/xhtml"><h1>Hello World!</h1></div>';
var parser = new DOMParser();
var documentFragment = parser.parseFromString(string, "text/xml");
body.appendChild(documentFragment); // assuming 'body' is the body element

// ALT
document.getElementById("s0001").innerHTML = "New text!";
