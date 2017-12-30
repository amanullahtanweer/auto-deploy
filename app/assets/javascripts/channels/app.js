$( function() {
	var app_id = $("[data-app-id]").data('app-id');
	if (app_id) {
		App.app = App.cable.subscriptions.create({channel: "AppChannel", id: app_id}, {
		  received: function(data) {
		    $('#start').show();
		    console.log(data.id)
		    var n
		    if (data.html) return n = $("[data-behavior='app-logs'][data-record='" + app_id + "']"), n.append(data.html), n[0].scrollTop = n[0].scrollHeight
		  }
		});
	}
});