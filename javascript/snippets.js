// Misc snippet code

var x = (window.pageXOffset || doc.scrollLeft) - (doc.clientLeft || 0);
var w = (document.width  || document.body.offsetWidth);
var pos = document.documentElement.scrollTop || document.body.scrollTop;
localStorage.removeItem('scrollRelPos');
