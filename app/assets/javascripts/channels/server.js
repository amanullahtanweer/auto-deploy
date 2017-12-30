$( function() {
	var server_id = $("[data-server-id]").data('server-id');
	if (server_id) {
		App.server = App.cable.subscriptions.create({channel: "ServerChannel", id: server_id}, {
		  received: function(data) {
		    $('#start').show();
		    console.log(data.id)
		    var n
		    if (data.html) return n = $("[data-behavior='server-logs'][data-record='" + server_id + "']"), n.append(data.html), n[0].scrollTop = n[0].scrollHeight
		  }
		});
	}
});