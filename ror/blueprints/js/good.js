$(document).ready(function () {
  
    $('.month_dll').nk_dropdown({ width: 162, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png', classname: 'telia', srcType: false, resultExtraStyle: 'font-size:12px' });
    $('.day_dll').nk_dropdown({ width: 96, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png', classname: 'telia', srcType: false, resultExtraStyle: 'font-size:12px' });
    $('.category_dll').nk_dropdown({ width: 262, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png', classname: 'telia', srcType: false, resultExtraStyle: 'font-size:12px', datasource: 'datasource/category.htm', datatext: 'name', datavalue: 'id' });
    $('.org_dll').nk_dropdown({ width: 262, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png', classname: 'telia', srcType: true, srcText: 'Αναζήτηση..', resultExtraStyle: 'font-size:12px', datasource: 'datasource/foreas.htm', datatext: 'name', datavalue: 'id' });
    $('.place_dll').nk_dropdown({ width: 262, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png', classname: 'telia', srcType: true, srcText: 'Αναζήτηση..', resultExtraStyle: 'font-size:12px' });
    
});
var RecaptchaOptions = {
    tabindex: 1,
    theme: 'custom',
    custom_theme_widget: 'recaptcha_widget'
};


function Validation() {
    var IsValid = true
    if ($('.month_dll').val() == 0) {
        IsValid = false
        $('.month_dll').nk_dropdown_error({ color: 'red' });
    } else {
        $('.month_dll').nk_dropdown_error({ color: '#b1b1b1' });
    }

    if ($('.day_dll').val() == 0) {
        IsValid = false
        $('.day_dll').nk_dropdown_error({ color: 'red' });
    } else {
        $('.day_dll').nk_dropdown_error({ color: '#b1b1b1' });
    }

    if ($('.category_dll').val() == 0) {
        IsValid = false
        $('.category_dll').nk_dropdown_error({ color: 'red' });
    } else {
        $('.category_dll').nk_dropdown_error({ color: '#b1b1b1' });
    }

    if ($('.org_dll').val() == 0) {
        IsValid = false
        $('.org_dll').nk_dropdown_error({ color: 'red' });
    } else {
        $('.org_dll').nk_dropdown_error({ color: '#b1b1b1' });
    }

    if ($('.place_dll').val() == 0) {
        IsValid = false
        $('.place_dll').nk_dropdown_error({ color: 'red' });
    } else {
        $('.place_dll').nk_dropdown_error({ color: '#b1b1b1' });
    }


    if ($('.recaptchatxtinput').val().length == 0 || $('.recaptchatxtinput').val() == 'Γράψε το κείμενο δίπλα') {
        IsValid = false
        $('.recaptchatxt').removeClass('txt').addClass('txt-error')
    } else {
        $('.recaptchatxt').removeClass('txt-error').addClass('txt')
    }


    if ($('.comment textarea').val().length == 0 || $('.comment textarea').val() == 'Γράψε εδώ μία σύντομη περιγραφή του περιστατικού') {
        IsValid = false
        $('.comment').removeClass('commentstxt-big').addClass('commentstxt-big-error')
    } else {
        $('.comment').removeClass('commentstxt-big-error').addClass('commentstxt-big')
    }

    if (IsValid) {
        $('.errormessage').hide()
    } else {
        $('.errormessage').show()
    }

}