var limit = 10;
var current = 0;
var server = '127.0.0.1:7000'

$(document).ready(function(){
	console.log("ready...");
	
	function debug(str){
    $("#debug").append("<p>" +  str); 
  };
  
  var User = {};
  var http;
  var ws_url;
	
	var uuid = Math.floor(Math.random()*9999);

  ws_url = "ws://"+server+'/'+uuid;

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
		delete msg
	});
	
	/**
	 * GUI related actions
  */
	var GUI = {
		loading: function(bool)
		{
			if(!bool)
			{
				$("#loader").hide();
			}
			else
			{
				$("#loader").hide();
			}
		},
		update_gui: function(obj_id,message)
		{
			var contents = "<div class='message'>";
			contents += "<ul class='message'>";
			contents += "<li>"+message+"</li>";
			contents += "</ul>";
			contents += "</div>";
			$("."+obj_id).prepend(contents);
			delete contents;
		}
	};
  
  http = new WebSocket(ws_url)
  
  http.onmessage = function(evt) { 
    //console.log(evt);
		//console.log(evt.data);
		var message = evt.data;
		//console.log(typeof message);
		var msg_p = JSON.parse(message);
		//console.log(msg_p);
		
		if(msg_p.code === 200)
		{
			if(msg_p.type === "message")
			{
				GUI.update_gui("irc_contents",msg_p.text);
			}
			else if(msg_p.type === "uuid")
			{
				User.uuid = msg_p.text;
				console.log(User);
				GUI.loading(false);
				GUI.update_gui("irc_contents","your registered with uuid of: "+User.uuid);
			}
			else if(msg_p.type === "connection")
			{
				
			}
		}
		else
		{
			// error or other
		}
  };
  
  http.onclose = function() { 
    $("#msg").prepend("<p>socket server closed</p>"); 
  };
  
  http.onopen = function() {
    debug("WebSocket connected!");
  };
	
	
	
});