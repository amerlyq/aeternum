// Misc snippet code

var x = (window.pageXOffset || doc.scrollLeft) - (doc.clientLeft || 0);
var w = (document.width  || document.body.offsetWidth);
var pos = document.documentElement.scrollTop || document.body.scrollTop;
localStorage.removeItem('scrollRelPos');

// ALT:
<button id="but-upload" onclick="document.getElementById('file-input').click();"> Load </button>

try {
    // Array.isArray(xfilter)
    // REF: http://stackoverflow.com/questions/20881213/converting-json-object-into-javascript-array
    // ALT: var xfilter = $.parseJSON(localStorage.getItem(storageKey));
    var xfilter = $.map(JSON.parse(localStorage.getItem(storageKey)), function(x) { return x });
    if (-1 == xfilter.indexOf(whref)) { xfilter.push(whref) }
    xfilter.pop();
    // ALT: localStorage.setItem(storageKey, $.toJSON(xfilter));
    localStorage.setItem(storageKey, JSON.stringify(xfilter));
    console.log(xfilter.length)

    // Dict
    // SEE: http://stackoverflow.com/questions/218798/in-javascript-how-can-we-identify-whether-an-object-is-a-hash-or-an-array
    var xfilter = JSON.parse(localStorage.getItem(storageKey)).reduce((obj, x) => Object.assign(obj, { [x]: true }), {});
    if (xfilter.hasOwnProperty(key)) { }
    delete xfilter[h];
    localStorage.setItem(storageKey, JSON.stringify(Object.keys(xfilter)));
    console.log(Object.keys(xfilter).length)

} catch (e) { }

/// SEE: event listeners -- for filter-on-button-click
// http://stackoverflow.com/questions/12627443/jquery-click-vs-onclick
$("#pop-butt").click(function() {
    console.log(Object.keys(xfilter).length)
});
