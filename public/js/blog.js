$(document).ready(function() {
	$('a.tree-toggler').click(function () {
		$(this).parent().children("ul").toggle(300);
	});
});

$(document).ready(function() {
    $("time.timeago").timeago();
});
