

$(document).ready(function(){
  
  function debug(str){
    $("#debug").append("<p>" +  str); 
  };
  
  var user;
  var http;
  var ws_url;
  
	ws_url = "ws://"+server;
  
  console.log(ws_url)
  
  http = new WebSocket(ws_url)
  
  http.onmessage = function(evt) { 
    console.log(evt)
    $("#loading").fadeOut();
    $("#msg").prepend(evt.data);
  };
  
  http.onclose = function() { 
    $("#msg").prepend("<p>socket server closed</p>"); 
  };
  
  http.onopen = function() {
    debug("WebSocket connected!");
  };

});