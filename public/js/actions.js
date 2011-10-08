var limit = 10;
var current = 0;
var server = '127.0.0.1:7000'

$(document).ready(function(){
	console.log("ready...");
	
	function debug(str){
    $("#debug").append("<p>" +  str); 
  };
  
  var user;
  var http;
  var ws_url;
  ws_url = "ws://"+server;

	// irc input item
	// can send "typing"
	$("#irc_input_txt").bind("focus",function(){
		console.log("input in focus");
	});
	
	// can send "no-longer-typing"
	$("#irc_input_txt").bind("blur",function(){
		console.log("input no longer in focus");
	});
	
	$("#irc_message_btn").bind("click",function(){
		console.log("button has been clicked");
		var msg = $("#irc_input_txt").val();
		http.send(msg);
		msg.delete
	});
	
	var GUI = {
		loading: function(bool)
		{
			if(!bool)
			{
				$("#loader").hide();
			}
			else
			{
				$("#loader").show();
			}
		},
		update_data: function(div,data)
		{
			
		}
	};
  
  http = new WebSocket(ws_url)
  
  http.onmessage = function(evt) { 
    console.log(evt);
		console.log(JSON.parse(evt));
		if(evt.data)
    if(evt.data === "connected")
		{
			GUI.loading(false);
		}
		
    $("#msg").prepend(evt.data);
  };
  
  http.onclose = function() { 
    $("#msg").prepend("<p>socket server closed</p>"); 
  };
  
  http.onopen = function() {
    debug("WebSocket connected!");
  };
	
	
	
});