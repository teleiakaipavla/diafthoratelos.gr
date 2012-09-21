jQuery(document).ready(function($) {   
    $( "#tabs" ).tabs();

    var thickDims, tbWidth, tbHeight; 
    thickDims = function() {
        var tbWindow = $('#TB_window'), H = $(window).height(), W = $(window).width(), w, h;
    
        w = (tbWidth && tbWidth < W - 90) ? tbWidth : W - 90;
        h = (tbHeight && tbHeight < H - 60) ? tbHeight : H - 60;
        if ( tbWindow.size() ) {
            tbWindow.width(w).height(h);
            $('#TB_iframeContent').width(w).height(h - 27);
            tbWindow.css({'margin-left': '-' + parseInt((w / 2),10) + 'px'});
            if ( typeof document.body.style.maxWidth != 'undefined' )
                tbWindow.css({'top':'30px','margin-top':'0'});
        }
    };

    $('a.thickbox-preview').click( function() {
        
        var previewLink = this;
        
        var $inputs = $('#LoginRadius_settings :input');

        var values = {};
        $.each($('#LoginRadius_settings').serializeArray(), function(i, field) {
            
            var thisName = field.name
            if (thisName.indexOf("LoginRadius_settings[") != -1 )
            {
                thisName = thisName.replace("LoginRadius_settings[", '');
                thisName = thisName.replace("]", '');
            }
            
            values[thisName] = field.value;
        });

        var stuff = $.param(values, true);

        var data = {
            action: 'lr_save_transient',
            value : stuff
        };
        

        jQuery.post(ajaxurl, data, function(response) {

            // Fix for WP 2.9's version of lightbox 
            if ( typeof tb_click != 'undefined' &&  $.isFunction(tb_click.call))
            {
               tb_click.call(previewLink); 
            }
            var href = $(previewLink).attr('href');
            var link = '';


        if ( tbWidth = href.match(/&tbWidth=[0-9]+/) ) 
            tbWidth = parseInt(tbWidth[0].replace(/[^0-9]+/g, ''), 10); 
        else 
            tbWidth = $(window).width() - 90; 

        if ( tbHeight = href.match(/&tbHeight=[0-9]+/) ) 
            tbHeight = parseInt(tbHeight[0].replace(/[^0-9]+/g, ''), 10);
        else
            tbHeight = $(window).height() - 60;
            
        $('#TB_title').css({'background-color':'#222','color':'#dfdfdf'}); 
        $('#TB_closeAjaxWindow').css({'float':'left'}); 
        $('#TB_ajaxWindowTitle').css({'float':'right'}).html(link); 

        $('#TB_iframeContent').width('100%'); 

        thickDims(); 

        });
        return false;
    });
});
