//PopUp

if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)) { //test for MSIE x.x;
    var ieversion = new Number(RegExp.$1) // capture x.x portion and store as a number
    if (ieversion >= 9) {
    }
    else if (ieversion >= 8) {
    }
    else if (ieversion >= 7) {
        $('.Innovation_MainContent').css({ top: "-5px" })
    }
    else if (ieversion >= 6) {
    }
    else if (ieversion >= 5) {
    }
}

function toggle(div_id) {
    var el = document.getElementById(div_id);
    if (el.style.display == 'none') { el.style.display = 'block'; }
    else { el.style.display = 'none'; }
}
function blanket_size(popUpDivVar) {
    if (typeof window.innerWidth != 'undefined') {
        viewportheight = window.innerHeight;
    } else {
        viewportheight = document.documentElement.clientHeight;
    }
    if ((viewportheight > document.body.parentNode.scrollHeight) && (viewportheight > document.body.parentNode.clientHeight)) {
        blanket_height = viewportheight;
    } else {
        if (document.body.parentNode.clientHeight > document.body.parentNode.scrollHeight) {
            blanket_height = document.body.parentNode.clientHeight;
        } else {
            blanket_height = document.body.parentNode.scrollHeight;
        }
    }
    var blanket = document.getElementById('blanket');
    blanket.style.height = blanket_height + 'px';
    //        //var popUpDiv = document.getElementById(popUpDivVar);
    //        //popUpDiv_height = blanket_height / 2 - 500; //200 is half popup's height
    //        //popUpDiv.style.top = popUpDiv_height + 'px';
    var popUpDiv = document.getElementById(popUpDivVar);
    popUpDiv.style.top = '-150px';
}
function window_pos(popUpDivVar) {
    if (typeof window.innerWidth != 'undefined') {
        viewportwidth = window.innerHeight;
    } else {
        viewportwidth = document.documentElement.clientHeight;
    }
    if ((viewportwidth > document.body.parentNode.scrollWidth) && (viewportwidth > document.body.parentNode.clientWidth)) {
        window_width = viewportwidth;
    } else {
        if (document.body.parentNode.clientWidth > document.body.parentNode.scrollWidth) {
            window_width = document.body.parentNode.clientWidth;
        } else {
            window_width = document.body.parentNode.scrollWidth;
        }
    }
    var blanket = document.getElementById('blanket');
    blanket.style.width = window_width + 'px';
    //        var popUpDiv = document.getElementById(popUpDivVar);
    //        window_width = window_width / 2 - 490; //200 is half popup's width
    //        popUpDiv.style.left = window_width + 'px';
    var popUpDiv = document.getElementById(popUpDivVar);
    window_width = window_width / 2 - 562; //200 is half popup's width
    popUpDiv.style.left = '200px';
}

function popup(windowname, url) {
    //$('[id$=PopUp_Content]').show();
    blanket_size(windowname);
    window_pos(windowname);
    toggle('blanket');
    toggle(windowname);

    if ($('#popUpDiv').is(":visible")) {
        var video_content = "<object width='562' height='363'><param name='movie' value='http://www.youtube.com/v/" + url + "?version=3&amp;hl=el_GR'></param><param name='allowFullScreen' value='true'></param><param name='allowscriptaccess' value='always'></param><embed src='http://www.youtube.com/v/" + url + "?version=3&amp;hl=el_GR' type='application/x-shockwave-flash' width='562' height='363' allowscriptaccess='always' allowfullscreen='true'></embed></object>"
        $('[id$=PopUp_Content]').html(video_content);
    }
    else {
        $('[id$=PopUp_Content]').html("");
    }

}