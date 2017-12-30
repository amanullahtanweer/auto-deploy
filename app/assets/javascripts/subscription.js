$(document).on('turbolinks:load', function() {
	var stripe = Stripe($("meta[name='stripe-key']").attr("content"));
	var elements = stripe.elements();
	var style = {
		base: {
			color: '#32325d',
			lineHeight: '18px',
			fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
			fontSmoothing: 'antialiased',
			fontSize: '16px',
			'::placeholder': {
				color: '#aab7c4'
			}
		},
		invalid: {
			color: '#fa755a',
			iconColor: '#fa755a'
		}
	};

	var card = elements.create('card', {style: style});
	card.mount('#card-element');

	card.addEventListener('change', function(event) {
		var displayError = document.getElementById('card-errors');
		if (event.error) {
			displayError.textContent = event.error.message;
		} else {
			displayError.textContent = '';
		}
	});

	// Handle form submission

	$('#payment-form').submit(function(event) {
		var $form;
		$form = $(this);
		$form.find('button').prop('disabled', true);
		event.preventDefault();

		stripe.createToken(card).then(function(result) {
			if (result.error) {
				// Inform the user if there was an error
				var errorElement = document.getElementById('card-errors');
				errorElement.textContent = result.error.message;
				$form.find('button').prop('disabled', false);
			} else {
				// stripeTokenHandler(result.token);
				token = result.token.id;
				$form.append($('<input type="hidden" name="stripeToken" />').val(token));
				$form.append($('<input type="hidden" name="card_last4" />').val(result.token.card.last4));
				$form.append($('<input type="hidden" name="card_exp_month" />').val(result.token.card.exp_month));
				$form.append($('<input type="hidden" name="card_exp_year" />').val(result.token.card.exp_year));
				$form.append($('<input type="hidden" name="card_brand" />').val(result.token.card.brand));
				$form.get(0).submit();
			}
		});
	});
});
