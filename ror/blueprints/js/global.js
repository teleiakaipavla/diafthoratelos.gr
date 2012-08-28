$(document).ready(function () {
    var DataUrl = 'datasource/menu.htm?rnd=' + Math.random(100000);
    $.getJSON(DataUrl, function (data) {
        $.each(data, function (index, item) {
            $('#menu').append('<li><a href="' + item.link + '">' + item.title + '</a></li>')
        })
    });

    $('.home-bluebox').mouseover(function () {
        $(this).addClass('home-bluebox-over').removeClass('home-bluebox')
    });
    $('.home-bluebox').mouseout(function () {
        $(this).addClass('home-bluebox').removeClass('home-bluebox-over')
    });


    $('.home-bluebox-last').mouseover(function () {
        $(this).addClass('home-bluebox-last-over').removeClass('home-bluebox-last')
    });
    $('.home-bluebox-last').mouseout(function () {
        $(this).addClass('home-bluebox-last').removeClass('home-bluebox-last-over')
    });


    $('.readmore .link a').click(function () {
        $('.popupMain').css('height', $(document).height() + 'px')
        $('.popupMain').show()
    });


    $('.social .fb img').mouseover(function () {
        $(this).attr("src", "images/Global/facebookon.png")
    });
    $('.social .fb img').mouseout(function () {
        $(this).attr("src", "images/Global/facebook.png")
    });

    $('.social .tw img').mouseover(function () {
        $(this).attr("src", "images/Global/twitteron.png")
    });
    $('.social .tw img').mouseout(function () {
        $(this).attr("src", "images/Global/twitter.png")
    });

    $('.social .mail img').mouseover(function () {
        $(this).attr("src", "images/Global/mailon.png")
    });
    $('.social .mail img').mouseout(function () {
        $(this).attr("src", "images/Global/mail.png")
    });


    try { // cant work to home page
        $('.popup-holder').jScrollPane({ animateScroll: true, horizontalGutter: 3, autoReinitialise: true })
    }
    catch (e) {
    }
    

   


});



function ClearTxt(obj, text) {
    if ($(obj).val() == text) {
        $(obj).val('')
    }
}

function ResetTxt(obj, text) {
    if ($(obj).val() == '') {
        $(obj).val(text)
    }
}