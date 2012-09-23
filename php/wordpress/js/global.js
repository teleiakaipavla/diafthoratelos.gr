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

    $('.home-bluebox-new').mouseover(function () {
        $(this).addClass('home-bluebox-new-over').removeClass('home-bluebox-new')
    });
    $('.home-bluebox-new').mouseout(function () {
        $(this).addClass('home-bluebox-new').removeClass('home-bluebox-new-over')
    });


    $('.home-bluebox-small-new').mouseover(function () {
        $(this).addClass('home-bluebox-small-new-over').removeClass('home-bluebox-small-new')
    });
    $('.home-bluebox-small-new').mouseout(function () {
        $(this).addClass('home-bluebox-small-new').removeClass('home-bluebox-small-new-over')
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
        $(this).attr("src", "images/global/facebookon.png")
    });
    $('.social .fb img').mouseout(function () {
        $(this).attr("src", "images/global/facebook.png")
    });

    $('.social .tw img').mouseover(function () {
        $(this).attr("src", "images/global/twitteron.png")
    });
    $('.social .tw img').mouseout(function () {
        $(this).attr("src", "images/global/twitter.png")
    });

    $('.social .mail img').mouseover(function () {
        $(this).attr("src", "images/global/mailon.png")
    });
    $('.social .mail img').mouseout(function () {
        $(this).attr("src", "images/global/mail.png")
    });

    $('.social .bb img').mouseover(function () {
        $(this).attr("src", "images/global/bon.png")
    });
    $('.social .bb img').mouseout(function () {
        $(this).attr("src", "images/global/b.png")
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

function groupThousands(str) {
    var amount = new String(str);
    amount = amount.split("").reverse();

    var output = "";
    for ( var i = 0; i <= amount.length-1; i++ ){
        output = amount[i] + output;
        if ((i+1) % 3 == 0 && (amount.length-1) !== i)output = '.' + output;
    }
    return output;
}