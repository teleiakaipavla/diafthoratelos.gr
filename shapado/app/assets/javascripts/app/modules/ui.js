Ui = function() {
  var self = this;

  function initialize() {
    initDropdowns();
    initQuickQuestion();
    Auth.dropdownToggle();
    Auth.positionDropdown();
    initializeAjaxTooltips();
    initializeSmoothScrollToTop();
    Form.initialize();
    }

    $('[rel=tipsy]').tipsy({gravity: 's'});
    $('.tipsy-plans').tipsy({gravity: 'e', opacity: 1});
    $('.lang-option').click(function(){
      var path = $('#lang-select-toggle').data('language');
      var language = $(this).data('language');
      $.ajax({type: 'POST', url: path,
              data: {'language[filter]': language},
              success: function(){window.location.reload()}
             });
    });

    sortValues('#group_language', 'option', ':last', 'text', null);
    sortValues('#user_language', 'option',  false, 'text', null);
    sortValues('#lang_opts', '.radio_option', false, 'attr', 'id');
    sortValues('select#question_language', 'option', false, 'text', null);

    if(offline()) {
      $("a[data-login-required], .toggle-action, .not_member").on('click', function(e) {
        e.preventDefault();
        Auth.startLoginDialog();
      });

//    $(document.body).delegate("#ask_question,.plans-form,.downgrade-form", "submit", function(event) {
    $(document.body).delegate("#ask_question", "submit", function(event) {
        if(Ui.offline()){
            Auth.startLoginDialog();
            return false;
        }
    });
    $(document.body).delegate("#join_dialog_link", "click", function(event) {
      Groups.join(this);
    });

    $(document.body).delegate("click",  ".join_group", function(event) {
      if(!$(this).hasClass('email')){
        Auth.startLoginDialog($(this).text(),1);
        return false;
      } else {document.location=$(this).attr('href')}
    });

    $(".toggle-action").on("ajax:success", function(xhr, data, status) {
      if(data.success) {
        var link = $(this);
        var href = link.attr('href'), title = link.attr('title'), text = link.data('ujs:enable-with');
        var dataUndo = link.data('undo'), dataTitle = link.data('title'), dataText = link.data('text');

        var img = link.children('img');
        var counter = $(link.data('counter'));

        link.attr({href: dataUndo, title: dataTitle });
        link.data({'undo': href, 'title': title, 'text': text});

        if(dataText && $.trim(dataText)!=''){
          link.text(dataText);
          link.data('ujs:enable-with', dataText);
        }

        img.attr({src: img.data('src'), 'data-src': img.attr('src')});
        if(typeof(link.data('increment'))!='undefined') {
          counter.text(parseFloat($.trim(counter.text()))+link.data('increment'));
        }
        Messages.show(data.message, "notice");
      }
    });
  }

  function initializeFeedback() {
    var feedback = $("#feedbackform");
    feedback.dialog({ title: "Feedback", autoOpen: false, modal: true, width:"420px" });
    $('#feedbackform .cancel-feedback').click(function(){
      $("#feedbackform").dialog('close');
      return false;
    });
    $('#feedback').click(function(){
      var isOpen = feedback.dialog('isOpen');
      if (isOpen){
        feedback.dialog('close');
      } else {
        feedback.dialog('open');
      }
      return false;
    });
  }

  function sortValues(selectID, child, keepers, method, arg) {
    if(keepers){
      var any = $(selectID+' '+child+keepers);
      any.remove();
    }
    var sortedVals = $.makeArray($(selectID+' '+child)).sort(function(a,b){
      return $(a)[method](arg) > $(b)[method](arg) ? 1: -1;
    });
    $(selectID).html(sortedVals);
    if(keepers)
      $(selectID).prepend(any);
    // needed for firefox:
    $(selectID).val($(selectID+' '+child+'[selected=selected]').val());
  }

  function offline() {
    return $('.offline').length>0 || notMember();
  }

  function notMember() {
    return $('.not_member').length>0;
  }

  function centerScroll(tag, container) {
    container = container || $('html,body');
    viewportHeight = $(window).height();
    if(window.innerHeight)
      viewportHeight = window.innerHeight;

    var top = tag.offset().top - (viewportHeight/2.0);

    container.scrollTop(top);
  }

  function navigateShortcuts(container, element_selector) {
    elements = container.find(element_selector);
    var first_element = elements[0];
    if(first_element) {
      $(first_element).addClass("active");
    }

    container.on("click", element_selector, function(ev) {
      elements.removeClass("active");
      next = $(this);
      next.addClass("active");
    });

    $(document).keydown(function(ev) {

      if(container.is(':visible')) {
        current_element = $(container.find(element_selector+'.active'));

        moved = false;
        next = null;
        if(ev.keyCode == 74){
          next = current_element.next(element_selector);
        } else if(ev.keyCode == 75){
          next = current_element.prev(element_selector);
        }

        if(next && next.length > 0) {
          current_element.removeClass("active");
          next.addClass("active");
          Ui.center_scroll(next);
        }
      }
    });
  }

  function initializeLangFields(container) {
    var fields = (container||$('body')).find('.lang-fields');
    if(fields.length > 0){
      fields.tabs();
    }
  }

  function initializeSmoothScrollToTop() {
    $(".top-bar").click(function(e) {
      var isTopBar = $(e.target).hasClass('top-bar');
      if(isTopBar)
        $("html, body").animate({ scrollTop: 0 }, "fast");
    });
  }

  function initializeAjaxTooltips() {
    $(document.body).on("mouseleave, scroll",".markdown, .toolbar, .Question, .comment-content, .tag-list, .user-data, .tooltip", function(event) {
      $(".tooltip").hide();
    });

    $(document.body).on("mouseenter", ".toolbar, .markdown, .Question, .comment-content, .tag-list, .user-data", function(event) {
      $(".tooltip").hide();
    });

    $(document.body).on("hover", ".ajax-tooltip", function(event) {
      var url = $(this).attr('href');
      var tag_link = $(this);
      $('.tooltip').hide();
      if(tag_link.data('tooltip')==1){
        var tooltip = tag_link.next('.tooltip');
        tooltip.show(); //.delay(1800).fadeIn(400).delay(1800);
        return false;
      }
      $.ajax({
        url: url+'?tooltip=1',
        dataType: 'json',
        success: function(data){
          $(".tooltip").hide();
          tag_link.removeAttr('title');
          tag_link.data('tooltip', 1);
          tag_link.after(data.html)
          var tooltip = tag_link.next('.tooltip');
          tooltip.css({'display': 'block'});
          tooltip.position({at: 'top center', of: tag_link, my: 'bottom', collision: 'fit fit'})
        }})
      return false;
    })

  }

  //Private
  function initDropdowns() {
    $('ul.menubar').droppy({
      className:    'dropHover',
      autoArrows:    false,
      trigger: 'click'
    });

    $('ul.menubar .has-subnav').click(function(e) {
      e.preventDefault();
    });
  }

  function initQuickQuestion() {
    var quick_question = $('.quick_question');
    quick_question.find('.buttons-quickq').hide();
    quick_question.find('form input[type=text]').focus(function(){
      quick_question.find('.buttons-quickq').show();
    });
  }

  return {
    initialize:initialize,
    initializeFeedback:initializeFeedback,
    sortValues:sortValues,
    offline:offline,
    notMember:notMember,
    centerScroll:centerScroll,
    navigateShortcuts:navigateShortcuts,
    initializeLangFields:initializeLangFields,
    initializeSmoothScrollToTop:initializeSmoothScrollToTop,
    initializeAjaxTooltips:initializeAjaxTooltips
  }
}();
