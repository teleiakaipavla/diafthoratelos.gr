Auth = function() {
  var self = this;

  function initialize() {
    $('.auth-provider').live("click", function(e){
      e.preventDefault();
      var authUrl = $(this).attr('href');
      openPopup(authUrl);
    });

    $('#openid_url').parents('form').submit(function(){
      var openid = $('#openid_url').val();
      openid = openid.replace('http://','');
      openid = openid.replace('https://','');
      $('#openid_url').val(openid)
    });
  }

  function positionDropdown() {
    if(Ui.offline() && !Ui.notMember()){
      $('.providers-list').show().offset({left: $('.offline').offset().left+$('.offline').width()-$('.providers-list').width()}).hide();
        //$('.providers-list').show().offset({left: $('body').width()/2-$('#column2').width()/2}).css({width: '290px'});
    }
  }

  function dropdownToggle() {
    $('[data-toggle-dropdown]').click(function(){
      var toggleClass = $(this).data('toggle-dropdown');
      $('.dropdown-form').addClass('hidden');
      var toggleEle = $('.'+toggleClass).toggleClass('hidden');
      positionDropdown();
      $('.providers-list').show();
      return false;
    })
  }

  function openPopup(authUrl) {
    var pparg;
    if(authUrl.indexOf('{')!=-1){
      authUrl = authUrl.split('=')[1];
      $('[data-toggle-dropdown=dropdown-signin-openid]').trigger('click');
      $('#openid_url').val(authUrl);
      return false;
    } else {
      $.cookie('pp', 1);
      (authUrl.indexOf('?')==-1)? pparg = '?pp=1' : pparg = '&pp=1'
      window.open(authUrl+pparg, 'openid_popup', 'width=700,height=500');
      $('#login_dialog').dialog('close');
    }
  }

  function startLoginDialog(title,join){
    if(Ui.notMember()){
        var title = $('#join_dialog').attr('data-title');
        $('#join_dialog').dialog({title: title, modal: true, resizable: false})
    } else {
        $('.offline li:first').trigger('click');
        Messages.show($('.offline').data('signin-notice'), 'error', 5000 );
        return false;
    }
  }

  return {
    initialize:initialize,
    positionDropdown:positionDropdown,
    dropdownToggle:dropdownToggle,
    openPopup:openPopup,
    startLoginDialog:startLoginDialog
  }
}();
