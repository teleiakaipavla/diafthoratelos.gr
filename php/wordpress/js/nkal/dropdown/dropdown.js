
jQuery.fn.nk_dropdown_error = function (_options) {
    var _options = $.extend({
        color: 'red',
        message: '',
        messagecolor:'red',
        withalert: false
    }, _options);

    $.each($(this), function (index, item) {
        var Opt_color = _options.color;
        var ControlID = $(item).attr("id");
        var theme = $('div[data-nkddl-id="' + ControlID + '"]').attr("data-nkddl-class");
        $('div[data-nkddl-id="' + ControlID + '"] .nk_ddl_bg_' + theme).css("border-color", Opt_color)
        if (_options.message.length > 0) {
            if (_options.withalert) {
                alert(_options.message)
            } else {
                var div = document.createElement("div");
                $(div).css("color", _options.messagecolor)
                $(div).html(_options.message)
                $(item).next().append(div)
            }
        }
    });
}


var nk_ddl_waitforbar = false;
jQuery.fn.nk_dropdown = function (_options) {
    var _options = $.extend({
        width: 200,
        theme: 'simple',
        srcText: 'Type to search',
        pointerUrl: '../dropdown/themes/simple/pointer.png',
        srcType: true,
        classname: 'simple',
        rows: 5,
        readonly: false,
        datasource: '',
        dataArgs: {},
        datavalue: 'value',
        datatext: 'text',
        resultExtraStyle: '',
        csstohide: '',
        bordercolor: ''
    }, _options);

    $.each($(this), function (index, item) {
        var Item_ID = $(item).attr("id");
        var NewDropdown = document.createElement("div");
        var nk_Top = document.createElement("div");
        var nk_Holder = document.createElement("div");
        var nk_Holder_in = document.createElement("div");
        var nk_bg_simple = document.createElement("div");
        var nk_val = document.createElement("div");
        var nk_val_textbox = document.createElement("div");
        var nk_pointer = document.createElement("div");
        var nk_clear = document.createElement("div");
        var nk_List_simple = document.createElement("div");
        var nk_srcList_simple = document.createElement("div");
        var nk_Bottom = document.createElement("div");
        var nk_example_simple = document.createElement("div");
        var Opt_Width = _options.width;
        var Opt_Height = _options.rows * 28;
        var Opt_Theme = _options.theme;
        var Opt_Class = _options.classname;
        var Opt_srcText = _options.srcText;
        var Opt_csstohide = _options.csstohide;
        //---- Nkal Controls must have these attributes


        $(item).attr("data-nkddl-controlid", Item_ID);

        $(NewDropdown).attr("data-nkddl-csstohide", Opt_csstohide);
        $(NewDropdown).attr("data-nkddl-plugin", "dropdown");
        $(NewDropdown).attr("data-nkddl-id", Item_ID);
        $(NewDropdown).attr("data-nkddl-class", Opt_Class);
        $(NewDropdown).attr("data-nkddl-status", "off");
        $(NewDropdown).attr("data-nkddl-readonly", _options.readonly);
        $(NewDropdown).attr("data-nkddl-bordercolor", _options.bordercolor);


        //---- Nkal Controls must have these attributes

        $(nk_Top).addClass("nk_ddl_Top").css("width", Opt_Width + 'px').addClass("nk_ddl_bt_" + Opt_Class);
        $(nk_Holder).addClass("nk_ddl_Holder").css("width", (Opt_Width + 2) + 'px').addClass("nk_ddl_bl_" + Opt_Class).addClass("nk_ddl_br_" + Opt_Class);
        $(nk_Holder_in).addClass("nk_ddl_Holder_in").css("width", Opt_Width + 'px').addClass("nk_ddl_blrin_" + Opt_Class);
        $(nk_bg_simple).addClass("nk_ddl_bg_" + Opt_Class).css("width", Opt_Width + 'px');
        $(nk_Bottom).addClass("nk_ddl_Bottom").css("width", Opt_Width + 'px').addClass("nk_ddl_bt_" + Opt_Class);
        $(nk_val).addClass("nk_ddl_val").css("width", (Opt_Width - 32) + 'px').addClass("nk_ddl_val_text_" + Opt_Class);
        $(nk_val_textbox).addClass("nk_ddl_val_textbox").css("width", (Opt_Width - 28) + 'px');
        $(nk_pointer).addClass("nk_ddl_pointer");


        $(nk_pointer).bind('click', function (e) {
            nk_ddl_CloseOnClick = false;
        });

        $(nk_clear).addClass("nk_clear");
        $(nk_List_simple).addClass("nk_ddl_List_" + Opt_Class).css("width", (Opt_Width + 2) + 'px').attr("data-nkddl-Listopt", "true").css("max-height", Opt_Height + 'px').css("z-index", '999');
        $(nk_srcList_simple).addClass("nk_ddl_srcList_" + Opt_Class).css("width", (Opt_Width + 2) + 'px').attr("data-nkddl-srcListopt", "true").css("max-height", Opt_Height + 'px').css("min-height", Opt_Height + 'px');
        $(nk_example_simple).addClass("nk_ddl_example_" + Opt_Class).css("width", (Opt_Width) + 'px');
        $(nk_example_simple).attr("data-nkdll-example-id", Item_ID);
        $(nk_example_simple).html('<i>' + Opt_srcText + '</i>');
        $(nk_val).attr("data-nkdll-val-id", Item_ID);


        $(nk_val).attr("data-nkdll-val-value", $(item).val());

        $(nk_val_textbox).attr("data-nkdll-txt-id", Item_ID);
        $(nk_val_textbox).attr("data-nkdll-txt-rows", _options.rows);
        $(nk_val_textbox).html('<input class="nk_ddl_textbox" style="width:' + (Opt_Width - 28) + 'px" autocomplete="off" onkeyup="nk_ddl_searchtext(this,event)"  onkeydown="if (event.keyCode == 13 || event.keyCode == 38) return false" type="text" id="nk_ddl_txt_' + Item_ID + '" />');

        $(nk_List_simple).attr("data-nkdll-list-id", Item_ID);
        $(nk_List_simple).attr("data-nkdll-list-class", Opt_Class);

        $(nk_List_simple).hover(function () {
            $('[data-nkdll-list-id="' + Item_ID + '"] .jspDrag').stop(true, true).fadeIn("slow")
        }, function () {
            $('[data-nkdll-list-id="' + Item_ID + '"] .jspDrag').stop(true, true).fadeOut("slow")
        })


        $(nk_srcList_simple).attr("data-nkdll-srclist-id", Item_ID);
        $(nk_srcList_simple).attr("data-nkdll-srclist-class", Opt_Class);

        var clickevent = "nk_ddl_opencloselist('" + Item_ID + "','" + Opt_Class + "');";
        if (_options.readonly) {
            clickevent = "return true;" + clickevent
        }
        $(nk_pointer).html('<img src="' + _options.pointerUrl + '" style="cursor:pointer" onmouseover="nk_ddl_overPointer(this)"  onmouseout="nk_ddl_outPointer(this)" onclick="' + clickevent + '" />');


        //----- get data -------------------------------
        //--- if datasource is null (default) get it from dropdown
        if (_options.datasource == '') {
            $.each($(item).children(), function (ind, select) {
                var ExtraStyle = ''
                if (_options.resultExtraStyle.length > 0) {
                    ExtraStyle = ' style = "' + _options.resultExtraStyle + '" '
                }
               
                var a = '<a class="nk_ddl_a_' + Opt_Class + '" data-nkdll-value="' + $(select).val() + '" ' + ExtraStyle + ' onclick="nk_ddl_selectOption(this)" >' + $(select).text() + '</a>';
                if ($(select).attr('data-image')) {
                    var imgurl = $(select).attr('data-image');
                }

                $(nk_List_simple).append(a);
            });
            $(nk_val).html($(item).find("option:selected").text());
            $(nk_val).attr("data-nkdll-val-text", $(item).find("option:selected").text());
        } else {
            var _data = _options.dataArgs;
            var url = _options.datasource;
            if (url.indexOf("?") > -1) {
                url = url + '&r=' + (Math.random() * 11000000)
            } else {
                url = url + '?r=' + (Math.random() * 11000000)
            }
        
            $.getJSON(url, function (data) {
                $(item).children().remove();
                $.each(data, function (index, dataitem) {
                    var _txt = nk_global_getvalues(dataitem, [_options.datatext]);
                    var _val = nk_global_getvalues(dataitem, [_options.datavalue]);
                    $(item).append('<option  value="' + _val + '" >' + _txt + '</option>')

                });
                $.each($(item).children(), function (ind, select) {
                    var ExtraStyle = ''
                    if (_options.resultExtraStyle.length > 0) {
                        ExtraStyle = ' style = "' + _options.resultExtraStyle + '" '
                    }
                    var a = '<a class="nk_ddl_a_' + Opt_Class + '" ' + ExtraStyle + ' data-nkdll-value="' + $(select).val() + '" onclick="nk_ddl_selectOption(this)" >' + $(select).text() + '</a>';
                    $(nk_List_simple).append(a);
                });
                $(nk_val).html($(item).find("option:selected").text());
                $(nk_val).attr("data-nkdll-val-text", $(item).find("option:selected").text());
            });

        }
        //--- if datasource is not null get by ajax

        //----- get data -------------------------------

        if (_options.readonly) {
            if (_options.srcType) {
                $(nk_val).attr("onclick", "return true;nk_ddl_CloseOnClick = false;nk_ddl_valClick(this);");
            } else {
                $(nk_val).attr("onclick", "return true;nk_ddl_CloseOnClick = false;nk_ddl_opencloselist('" + Item_ID + "','" + Opt_Class + "');");
            }

        } else {
            if (_options.srcType) {
                $(nk_val).attr("onclick", " nk_ddl_CloseOnClick = false;nk_ddl_valClick(this);");
            } else {
                $(nk_val).attr("onclick", " nk_ddl_CloseOnClick = false;nk_ddl_opencloselist('" + Item_ID + "','" + Opt_Class + "');");
            }
        }

        $(nk_bg_simple).append(nk_val).append(nk_val_textbox).append(nk_pointer).append(nk_clear).append(nk_List_simple).append(nk_srcList_simple);
        $(nk_Holder_in).append(nk_bg_simple);
        $(nk_Holder).append(nk_Holder_in);
        $(NewDropdown).append(nk_Top);
        $(NewDropdown).append(nk_Holder);
        $(NewDropdown).append(nk_Bottom).append(nk_example_simple);
        $(item).parent().append(NewDropdown);
        $(this).hide();

    });
};


function nk_global_getvalues(value, fields) {
    if (Array.contains == null) {
        Array.contains = function (value, item) {
            var exists = false;
            for (var i = 0; i < value.length; i++) {
                exists = (value[i] == item);
                if (exists)
                    break;
            }
            return exists;
        }
    }
    var values = [];
    for (key in value) {
        if (Array.contains(fields, key)) {
            values.push(value[key]);
        }
    }
    return values;
}



function nk_ddl_openlist(id, _class) {
    // IE 7
    //data - nkddl - controlid data-nkddl-csstohide
    // $('.data-nkddl-removecontrol').hide()
    // IE 7

    $('[data-nkddl-Listopt="true"]').hide();
    $('[data-nkddl-srcListopt="true"]').hide();
    $('.nk_ddl_val_textbox').hide();
    $('.nk_ddl_val').show();
    $('[data-nkdll-srclist-id="' + id + '"]').hide();
    $('[data-nkdll-val-id="' + id + '"]').show();
    $('[data-nkdll-txt-id="' + id + '"]').hide();
    $('[data-nkdll-list-id="' + id + '"]').slideDown(function () {
        if ($('[data-nkdll-list-id="' + id + '"]').attr("data-withbar") == 'yes') {
        } else {
            $('[data-nkdll-list-id="' + id + '"] .jspDrag').stop().hide()
            $('[data-nkdll-list-id="' + id + '"]').attr("data-withbar", "yes")
            $('[data-nkdll-list-id="' + id + '"]').jScrollPane({ animateScroll: true, horizontalGutter: 3 });
            var wjPanel = parseInt($('[data-nkdll-list-id="' + id + '"] .jspPane').width()) + 12
            $('[data-nkdll-list-id="' + id + '"] .jspPane').css("width", wjPanel + "px")
            $('[data-nkdll-list-id="' + id + '"] .jspDrag').click(function () {
                nk_ddl_CloseOnClick = false;
            });
        }
        $.each($('[data-nkdll-list-id="' + id + '"] a'), function (ind, select) {
            var offset = $(select).offset();
            var selectPos = offset.top;
            if ($(select).attr("class").indexOf("nk_ddl_selected_" + _class) > -1) {
                if (ind > 0) {
                    var ii = ((ind + 1) * 28) - 29;
                    var api = $('[data-nkdll-list-id="' + id + '"]').data('jsp');
                    api.scrollTo(0, ii);

                }
            }
        })

    })
}

function nk_ddl_selectTheOption(id, _class) {
    var selected = $('[data-nkdll-val-id="' + id + '"]').attr("data-nkdll-val-value");
    $.each($('[data-nkdll-list-id="' + id + '"] a'), function (index, option) {
        if ($(option).attr("data-nkdll-value") == selected) {
            $(option).parent().children().attr("data-nkdll-selectedOption", "false"); // unselect all
            $(option).attr("data-nkdll-selectedOption", "true"); // select the option
            $(option).removeClass("nk_ddl_selected_" + _class).addClass("nk_ddl_selected_" + _class);
        } else {
            $(option).removeClass("nk_ddl_selected_" + _class);
        }
    });
}

function nk_ddl_opencloselist(id, _class) {

    $('[data-nkdll-example-id="' + id + '"]').hide("slow");
    if ($('[data-nkdll-list-id="' + id + '"]').is(":visible")) {
        $('[data-nkdll-list-id="' + id + '"]').slideUp();
        $('div[data-nkddl-id="' + id + '"]').attr("data-nkddl-status", "off");
        // IE 7
        //$('.data-nkddl-removecontrol').show()
        // IE 7
    } else {
        nk_ddl_selectTheOption(id, _class);
        nk_ddl_openlist(id, _class);
        $('div[data-nkddl-id="' + id + '"]').attr("data-nkddl-status", "on");
    }
}

function nk_ddl_selectOption(option, type) {

    var ControlID = $(option).parent().parent().parent().attr("data-nkdll-list-id"); //allagi
    if (type) {
        ControlID = $(option).parent().parent().parent().attr("data-nkdll-srclist-id");
    }
    var value = $(option).attr("data-nkdll-value");
    var text = $(option).text();
    $(option).parent().children().attr("data-nkdll-selectedOption", "false");  // unselect all
    $(option).attr("data-nkdll-selectedOption", "true") // select the option
    $('[data-nkdll-val-id="' + ControlID + '"]').show();
    $('[data-nkdll-val-id="' + ControlID + '"]').html(text);
    $('[data-nkdll-val-id="' + ControlID + '"]').attr("data-nkdll-val-value", value);
    $('[data-nkdll-val-id="' + ControlID + '"]').attr("data-nkdll-val-text", text);
    $('select[id$=' + ControlID + ']').val(value);
    $('div[data-nkdll-txt-id="' + ControlID + '"]').hide();
    $('div[data-nkdll-srclist-id="' + ControlID + '"]').slideUp();
    $(option).parent().parent().parent().slideUp(); //allagi

//    var bordercolor = $('[data-nkddl-id="' + ControlID + '"]').attr("data-nkddl-bordercolor");
//    if (bordercolor.length > 0) {
//        $('#' + ControlID).nk_dropdown_error({ color: bordercolor })
//    }
    nkdll_onClcikEvent(ControlID, value, text);
}

function nk_ddl_overPointer(img) {
    var imgsrc = $(img).attr("src").toString();
    imgsrc = imgsrc.toString().replace("pointer", "pointeron");
    $(img).attr("src", imgsrc);
}

function nk_ddl_outPointer(img) {
    var imgsrc = $(img).attr("src").toString();
    imgsrc = imgsrc.toString().replace("pointeron", "pointer");
    $(img).attr("src", imgsrc);
}

function nk_ddl_valClick(obj) {
    var ControlID = $(obj).attr("data-nkdll-val-id");
    var value = $(obj).attr("data-nkdll-val-value");
    var text = $(obj).attr("data-nkdll-val-text");
    if (text.lenght == 0) {
        text = '*'
    }
    $(obj).hide();
    $txtDiv = $('[data-nkdll-txt-id="' + ControlID + '"]');
    $txtDiv.show();
    $('[data-nkdll-txt-id="' + ControlID + '"] input').focus();
    $('[data-nkdll-txt-id="' + ControlID + '"] input').val(text);
    $('[data-nkdll-example-id="' + ControlID + '"]').show("slow");
    if ($('div[data-nkdll-list-id="' + ControlID + '"]').is(":visible")) {

        $('div[data-nkdll-list-id="' + ControlID + '"]').slideUp();
        $('div[data-nkddl-id="' + ControlID + '"]').attr("data-nkddl-status", "off");
    }
}

function nk_ddl_searchtext(txt, event) {
    var Text = nk_ddl_ClearAccents($(txt).val());

    var id = $(txt).parent().attr('data-nkdll-txt-id');
    var rows = $(txt).parent().attr('data-nkdll-txt-rows');


    $('div[data-nkddl-id="' + id + '"]').attr("data-nkddl-status", "off");
    if (event.keyCode == 13) { // --- If it is enter
        var LastSelected = $('div[data-nkdll-srclist-id="' + id + '"] a[data-nkdll-record-selected="true"]').attr("data-nkdll-record");
        if (!LastSelected || LastSelected < 1) {
            LastSelected = 1;
        }

        nk_ddl_CloseOnClick = false;
        $('div[data-nkdll-srclist-id="' + id + '"] a[data-nkdll-record="' + LastSelected + '"]').click();
        $('div[data-nkdll-srclist-id="' + id + '"] a').remove(); //to change
        $('[data-nkdll-srclist-id="' + id + '"]').attr("data-withbar", "")
        $('[data-nkdll-srclist-id="' + id + '"]').removeClass("jspScrollable")

        return false;
    }

    var WithChildren = 0;
    var _class = $('div[data-nkdll-list-id="' + id + '"]').attr('data-nkdll-list-class');
 
    if (Text.length > 0) {

        var WithResults = false;
        if (event.keyCode != 40 && event.keyCode != 38) {

            $('div[data-nkdll-srclist-id="' + id + '"] a').remove(); //to change
            var Record = 0;
            var Recordminute = 15;
            $.each($('div[data-nkdll-list-id="' + id + '"] a'), function (index, option) {

                if (nk_ddl_ClearAccents($(option).text()).indexOf(Text) > -1 || Text == '*') {
                    WithResults = true;
                    Record++;
                    var a = '<a lass="nk_ddl_a_' + _class + '" data-nkdll-record="' + Record + '" data-nkdll-value="' + $(option).attr("data-nkdll-value") + '" onclick="nk_ddl_selectOption(this,true)" >' + $(option).text() + '</a>';
                    if ($('div[data-nkdll-srclist-id="' + id + '"]').attr("data-barisbind") == "yes") {
                        $('div[data-nkdll-srclist-id="' + id + '"] .jspPane').append(a);
                    } else {
                        $('div[data-nkdll-srclist-id="' + id + '"]').append(a);
                    }
                    $('div[data-nkdll-srclist-id="' + id + '"]').attr("data-barisbind", "yes")
                    if (Recordminute == Record && Text == '*') {
                        return false
                    }
                }

            });

        } else {
            WithChildren = $('div[data-nkdll-srclist-id="' + id + '"] a').length;
            if ($('div[data-nkdll-srclist-id="' + id + '"] a').length > 0) {
                WithResults = true;
            }
        }
        
        if (WithResults) {

            var api = $('[data-nkdll-srclist-id="' + id + '"]').data('jsp');

            $('div[data-nkddl-id="' + id + '"]').attr("data-nkddl-status", "on")
            $('[data-nkdll-example-id="' + id + '"]').hide("slow");
            $('[data-nkdll-srclist-id="' + id + '"]').slideDown(0);

            $('[data-nkdll-srclist-id="' + id + '"]').jScrollPane({ animateScroll: true, horizontalGutter: 3 });
            var wjPanel = parseInt($('[data-nkdll-srclist-id="' + id + '"] .jspPane').width()) + 12
            $('[data-nkdll-srclist-id="' + id + '"] .jspPane').css("width", wjPanel + "px")

            if (event.keyCode == 40 || event.keyCode == 38) { //---- up / down buttons
                var LastSelected = $('div[data-nkdll-srclist-id="' + id + '"] a[data-nkdll-record-selected="true"]').attr("data-nkdll-record");

                if (!LastSelected || LastSelected < 1) {
                    LastSelected = 0;
                }

                if (event.keyCode == 40) { // down button
                    if (WithChildren > LastSelected) {
                        var NewRecord = parseInt(LastSelected) + 1;
                        $('div[data-nkdll-srclist-id="' + id + '"] a').removeClass("nk_ddl_selected_" + _class);
                        $('div[data-nkdll-srclist-id="' + id + '"] a[data-nkdll-record="' + NewRecord + '"]').addClass("nk_ddl_selected_" + _class);
                        $('div[data-nkdll-srclist-id="' + id + '"] a').attr("data-nkdll-record-selected", "false");
                        $('div[data-nkdll-srclist-id="' + id + '"] a[data-nkdll-record="' + NewRecord + '"]').attr("data-nkdll-record-selected", "true");
                        if (NewRecord > rows) {
                            var scrollon = NewRecord - rows;
                            api.scrollTo(0, scrollon * 28);
                        }
                    } else {
                        $('div[data-nkdll-srclist-id="' + id + '"] a').removeClass("nk_ddl_selected_" + _class);
                        $('div[data-nkdll-srclist-id="' + id + '"] a[data-nkdll-record="1"]').addClass("nk_ddl_selected_" + _class);
                        $('div[data-nkdll-srclist-id="' + id + '"] a').attr("data-nkdll-record-selected", "false");
                        $('div[data-nkdll-srclist-id="' + id + '"] a[data-nkdll-record="1"]').attr("data-nkdll-record-selected", "true");
                        api.scrollTo(0, 0);
                    }
                } else {     // up
                    if (LastSelected > 1) {
                        var NewRecord = parseInt(LastSelected) - 1;
                        $('div[data-nkdll-srclist-id="' + id + '"] a').removeClass("nk_ddl_selected_" + _class);
                        $('div[data-nkdll-srclist-id="' + id + '"] a[data-nkdll-record="' + NewRecord + '"]').addClass("nk_ddl_selected_" + _class);
                        $('div[data-nkdll-srclist-id="' + id + '"] a').attr("data-nkdll-record-selected", "false");
                        $('div[data-nkdll-srclist-id="' + id + '"] a[data-nkdll-record="' + NewRecord + '"]').attr("data-nkdll-record-selected", "true");
                        if (NewRecord > rows) {
                            var scrollon = NewRecord - rows;
                            api.scrollTo(0, scrollon * 28);
                        } else {
                            api.scrollTo(0, 0);
                        }
                    } else {
                        $('div[data-nkdll-srclist-id="' + id + '"] a').removeClass("nk_ddl_selected_" + _class);
                        $('div[data-nkdll-srclist-id="' + id + '"] a[data-nkdll-record="' + WithChildren + '"]').addClass("nk_ddl_selected_" + _class);
                        $('div[data-nkdll-srclist-id="' + id + '"] a').attr("data-nkdll-record-selected", "false");
                        $('div[data-nkdll-srclist-id="' + id + '"] a[data-nkdll-record="' + WithChildren + '"]').attr("data-nkdll-record-selected", "true");
                        var scrollon = WithChildren - rows;
                        // $('div[data-nkdll-srclist-id="' + id + '"]').scrollTop(scrollon * 28);
                        api.scrollTo(0, scrollon * 28);
                    }
                }
            }
        } else {
            $('[data-nkdll-srclist-id="' + id + '"]').slideUp("slow", function () {
                $('[data-nkdll-example-id="' + id + '"]').show("slow");
            });
        }
    } else {
        $('[data-nkdll-srclist-id="' + id + '"]').slideUp("slow", function () {
            $('[data-nkdll-example-id="' + id + '"]').show("slow");
        });
    }
}

function nk_ddl_ClearAccents(txt) {
    txt = txt.toLowerCase();
    txt = txt.replace(new RegExp("ϊ", "gi"), "ι");
    txt = txt.replace(new RegExp("ί", "gi"), "ι");
    txt = txt.replace(new RegExp("έ", "gi"), "ε");
    txt = txt.replace(new RegExp("ή", "gi"), "η");
    txt = txt.replace(new RegExp("ό", "gi"), "ο");
    txt = txt.replace(new RegExp("ά", "gi"), "α");
    txt = txt.replace(new RegExp("ύ", "gi"), "υ");
    txt = txt.replace(new RegExp("ώ", "gi"), "ω");
    return txt;
}

var nk_ddl_CloseOnClick = true;
$(document).bind('click', function (e) {
    if (nk_ddl_CloseOnClick) {
        nk_ddl_CloseAll();
    } else {
        nk_ddl_CloseOnClick = true;
    }
});

function nk_ddl_CloseAll() {

    // IE 7
    //$('.data-nkddl-removecontrol').show()
    // IE 7

    if (nk_ddl_CloseOnClick) {
        $.each($('div[data-nkddl-plugin="dropdown"]'), function (ind, item) {
            if ($(this).attr("data-nkddl-status") == "on") {
                var id = $(this).attr("data-nkddl-id");
                var _class = $(this).attr("data-nkddl-class");
                if ($('[data-nkdll-list-id="' + id + '"]').is(":visible")) {
                    $('[data-nkdll-list-id="' + id + '"]').slideUp();
                    $('div[data-nkddl-id="' + id + '"]').attr("data-nkddl-status", "off");
                }

                if ($('[data-nkdll-srclist-id="' + id + '"]').is(":visible")) {
                    $('[data-nkdll-srclist-id="' + id + '"]').slideUp();
                    $('div[data-nkddl-id="' + id + '"]').attr("data-nkddl-status", "off");
                }
            }
        });
    }
}


//---- FUNCTIONS
function nk_ddl_ReadOnly(items, isReadOnly) {
    $.each(items, function (index, item) {
        var ReadOnlyStatus = $(item).attr("data-nkddl-readonly");
        var id = $(item).attr("data-nkddl-controlid");
        var control = $(item).parent().find('div[data-nkddl-plugin="dropdown"]');
        if (ReadOnlyStatus != isReadOnly) {
            $(control).attr("data-nkddl-readonly", isReadOnly);
            if (isReadOnly) {
                var onclick = $(control).find(".nk_ddl_pointer img").attr("onclick");
                $(control).find(".nk_ddl_pointer img").attr("onclick", "return true;" + onclick);
                onclick = $(control).find("div[data-nkdll-val-id='" + id + "']").attr("onclick");
                $(control).find("div[data-nkdll-val-id='" + id + "']").attr("onclick", "return true;" + onclick);
            } else {
                var onclick = $(control).find(".nk_ddl_pointer img").attr("onclick").replace("return true;", "");
                $(control).find(".nk_ddl_pointer img").attr("onclick", onclick);
                onclick = $(control).find("div[data-nkdll-val-id='" + id + "']").attr("onclick").replace("return true;", "");
                $(control).find("div[data-nkdll-val-id='" + id + "']").attr("onclick", onclick);
            }
        }
    });

}


function nkdll_onClcikEvent(ControlID, value, text) {

}