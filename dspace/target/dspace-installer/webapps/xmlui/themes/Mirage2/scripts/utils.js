/*
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
(function($) {
    DSpace.getTemplate = function(name) {
        if (DSpace.dev_mode || DSpace.templates === undefined || DSpace.templates[name] === undefined) {
            $.ajax({
                url : DSpace.theme_path + 'templates/' + name + '.hbs',
                success : function(data) {
                    if (DSpace.templates === undefined) {
                        DSpace.templates = {};
                    }
                    DSpace.templates[name] = Handlebars.compile(data);
                },
                async : false
            });
        }
        return DSpace.templates[name];
    };
  
 
	$("a[name='community-browser-link']:contains('BioMed Central')").parent().css('display', 'none');

   $(".abstract").click( function(e) {
	e.preventDefault();
        $(this).parent().find("div.artifact-description div.artifact-abstract").slideToggle();
   });

	$("#main-container").append('<button id="totop">&#8593;</button>');
	$(window).scroll( function(){
        	$(window).scrollTop()>300?($("#totop:hidden").fadeIn(),$("#totop").css("top",$(window).scrollTop()+$(window).height()-100)):$("#totop:visible").fadeOut()
	});

	$("#totop").click(function(){
        	$("html, body").animate({scrollTop:0})
	});

	if ($('#email').length > 0) {
        	$(':checkbox').attr('checked', false);
		$('#email').attr('class', 'hidden');
            	$(':checkbox').change(function () {
              		$('#no_email').toggleClass('hidden');
              		$('#email').toggleClass('hidden');
		});
        	$('#no_email').click(function (event) {
              		$('#warn').css('color', 'red');
          	});
        }

	$('.bookmark').click(function (e) {
    		e.stopPropagation();
	 	var t = $(this).width();
		    $(this).hide().after('<input class="bookmark-input" type="text" value="' + $(this).text() + '" />'),
		    $('.bookmark-input').width(t + 2).select(),
		    $('body').click(function () {
		      $('.bookmark-input').remove(),
		      $('.bookmark').show(),
		      $('body').unbind('click')
		})
  	})

	$("#export").appendTo("body");
	$("#share").appendTo("body");

})(jQuery);
