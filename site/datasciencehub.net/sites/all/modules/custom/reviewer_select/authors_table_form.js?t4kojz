(function($) {
	Drupal.behaviors.AuthorsTableForm = {
		attach : function(context, settings) {
			function toggleEmailBtn() {
				if ($('td input[id^=edit-authors]:checked').length == 0) {
					$('input[id^=edit-authors-email]').attr('disabled', 'disabled').addClass('form-button-disabled');
				} else {
					$('input[id^=edit-authors-email]').removeAttr('disabled').removeClass('form-button-disabled');
				}
			}
			
			toggleEmailBtn();
			$('td input[id^=edit-authors]').click(function() {
				toggleEmailBtn();
			});
		}
	}
})(jQuery);