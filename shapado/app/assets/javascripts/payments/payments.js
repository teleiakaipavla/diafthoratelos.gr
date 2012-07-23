var Payments = {
  initialize: function() {
    var form = $("#payment-form");
    Stripe.setPublishableKey(form.attr("data-token"));
    form.submit(function(event) {
      // disable the submit button to prevent repeated clicks
      $('.submit-button').attr("disabled", "disabled");

      console.log(form.find('.card-number').val())
      console.log(form.find('.card-cvc').val())
      console.log(form.find('.card-expiry-month').val())
      console.log(form.find('.card-expiry-year').val())
      Stripe.createToken({
          number: form.find('.card-number').val(),
          cvc: form.find('.card-cvc').val(),
          exp_month: form.find('.card-expiry-month').val(),
          exp_year: form.find('.card-expiry-year').val()
      }, Payments.handler);

      // prevent the form from submitting with the default action
      return false;
    });
  },
  handler: function(status, response) {
    if (response.error) {
      $(".payment-errors").html(response.error.message);
    } else {
      var form$ = $("#payment-form");
      var token = response['id'];

      form$.append("<input type='hidden' name='stripeToken' value='" + token + "'/>");
      form$.get(0).submit();
    }
  }
};

$(document).ready(function() {
  Payments.initialize();
});