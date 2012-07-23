var Plans = {
  initialize: function() {
    $('.users-qty input').change(function(){
        $('.total_private').html('$'+$(this).val()*2);

    });
  }
}