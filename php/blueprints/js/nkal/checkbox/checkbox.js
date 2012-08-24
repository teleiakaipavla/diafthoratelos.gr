jQuery.fn.nk_checkbox = function (_options) {
    var _options = $.extend({
        multi: true,
        unselect: true,
        imgChkselected: '../checkbox/themes/simple/chkselected.png',
        imgChk: '../checkbox/themes/simple/chk.png',
        imgDisable: '../checkbox/themes/simple/disable.png',
        isDisable: false,
        readonly: false,
        datasource: '',
        dataArgs: {},
        datavalue: 'value',
        datatext: 'text',
        columnrow: 2,
        onClick:'',
        onMousOver:'',
        onMouseOut: '',
        attribute:''
    }, _options);
    var AllChecbox = new Array()
    $.each($(this), function (index, item) {
        $(item).attr("data-nkchk-imgChk", _options.imgChk);
        $(item).attr("data-nkchk-imgChkselected", _options.imgChkselected);
        $(item).attr("data-nkchk-imgDisable", _options.imgDisable);
        $(item).attr("data-nkchk-readonly", _options.readonly);
       
        

        if ($(item).is("span")) { // is simple checkbox
            $(item).find("input").hide();
            $(item).find("label").hide();
            var chk_Text = $(item).find("label").text();
            var chk_Value = $(item).find("input").val();
            var Item_ID = $(item).find("input").attr("id");
            var LabelText = $(item).find("label").text();
            var checked = $(item).find("input").attr("checked");
            $(item).attr("data-nkchk-multiid", Item_ID);
            nk_chk_replaceChk(item, Item_ID, LabelText, true, null, checked, _options.unselect, _options.imgChkselected, _options.imgChk, chk_Text, chk_Value, _options.readonly, _options.onClick, _options.onMousOver, _options.onMouseOut, _options.attribute);
        } else { // is checkbox list
            var MainID = $(item).attr("id")
           
            //--- get data ----
            if (_options.datasource.length > 0) {

                var _data = _options.dataArgs;
                var url = _options.datasource;
                if (url.indexOf("?") > -1) {
                    url = url + '&r=' + (Math.random() * 11000000)
                } else {
                    url = url + '?r=' + (Math.random() * 11000000)
                }
                $.ajax({
                    url: url,
                    type: 'POST',
                    data: _data,
                    context: document.body,
                    success: function (data) {
                        $(item).children().remove();
                        var controlid = 'nk_chk_newid_' + (Math.random() * 99999999999).toString().replace(".", "")
                        var str = '<table id="' + controlid + '"><tbody>'
                        var NewRow = true
                        var RowCount = 0
                        var ColumnCount = 0
                        var idcount = 0
                        $.each(data, function (index, dataitem) {
                            var _txt = nk_global_getvalues(dataitem, [_options.datatext]);
                            var _val = nk_global_getvalues(dataitem, [_options.datavalue]);
                            ColumnCount++;
                            idcount++;
                            if (NewRow) {
                                NewRow = false;
                                str = str + '<tr><td><input id="' + controlid + '_' + idcount + '" type="checkbox" name="' + controlid + '$' + idcount + '" value="' + _val + '"/><label for="' + controlid + '_' + idcount + '">' + _txt + '</label></td>'
                            } else {
                                if (ColumnCount != _options.columnrow) {
                                    str = str + '<td><input id="' + controlid + '_' + idcount + '" type="checkbox" name="' + controlid + '$' + idcount + '" value="' + _val + '"/><label for="' + controlid + '_' + idcount + '">' + _txt + '</label></td>'
                                }
                            }

                            if (ColumnCount == _options.columnrow) {
                                str = str + '<td><input id="' + controlid + '_' + idcount + '" type="checkbox" name="' + controlid + '$' + idcount + '" value="' + _val + '"/><label for="' + controlid + '_' + idcount + '">' + _txt + '</label></td></tr>'
                                NewRow = true;
                                ColumnCount = 0;
                            }

                        });
                        str = str + '</tbody></table>'
                        $(item).append(str)
                        $.each($(item).find("td"), function (ind, chk) {
                            if ($(chk).find("input").val().length > 0) {
                                $(chk).find("input").hide();
                                $(chk).find("label").hide();
                                var chk_Text = $(chk).find("label").text();
                                var chk_Value = $(chk).find("input").val();

                                var Item_ID = $(chk).find("input").attr("id");
                                var LabelText = $(chk).find("label").text();
                                var checked = $(chk).find("input").attr("checked");
                                $(item).attr("data-nkchk-multiid", MainID);
                                $(item).attr("data-nkchk-readonly", _options.readonly);
                                nk_chk_replaceChk(chk, Item_ID, LabelText, _options.multi, MainID, checked, _options.unselect, _options.imgChkselected, _options.imgChk, chk_Text, chk_Value, _options.readonly, _options.onClick, _options.onMousOver, _options.onMouseOut, _options.attribute);
                            }
                        })
                        AllChecbox[AllChecbox.length] = item;
                        if (_options.isDisable) {
                            nk_chk_Disable(AllChecbox, true, false, null)
                        }
                    }
                });
            } else {
                $.each($(item).find("td"), function (ind, chk) {
                    if ($(chk).find("input").val().length > 0) {
                        $(chk).find("input").hide();
                        $(chk).find("label").hide();
                        var chk_Text = $(chk).find("label").text();
                        var chk_Value = $(chk).find("input").val();

                        var Item_ID = $(chk).find("input").attr("id");
                        var LabelText = $(chk).find("label").text();
                        var checked = $(chk).find("input").attr("checked");
                        $(item).attr("data-nkchk-multiid", MainID);
                        $(item).attr("data-nkchk-readonly", _options.readonly);
                        nk_chk_replaceChk(chk, Item_ID, LabelText, _options.multi, MainID, checked, _options.unselect, _options.imgChkselected, _options.imgChk, chk_Text, chk_Value, _options.readonly, _options.onClick, _options.onMousOver, _options.onMouseOut, _options.attribute);
                    }
                })
                AllChecbox[AllChecbox.length] = item;
                if (_options.isDisable) {
                    nk_chk_Disable(AllChecbox, true, false, null)
                }
            }
            //--- get data ----
        }
    });

    return AllChecbox
};

function nk_chk_replaceChk(item, item_id, txt, multi, MainID, checked, unselect, imgChkselected, imgChk, chk_Text, chk_Value, readonly, onClickEvent, onMousOverEvent, onMouseOutEvent,_attribute) {
    var NewCheckbox = document.createElement("div");
    //---- Nkal Controls must have these attributes
    $(NewCheckbox).attr("data-nkchk-plugin", "checkbox");
    var attrs = _attribute.split(",")
    $.each(attrs,function(ind,_attr){
        var attrName = "data-nkchk-attr-" + _attr.split("=")[0]
        var attrVal = _attr.split("=")[1]
        $(NewCheckbox).attr(attrName, attrVal);
    });


    $(NewCheckbox).attr("data-nkchk-plugin", "checkbox");
    
    $(NewCheckbox).attr("data-nkchk-id", item_id);
    $(NewCheckbox).attr("data-nkchk-text", chk_Text);
    $(NewCheckbox).attr("data-nkchk-value", chk_Value);
    if (MainID == null) {
        MainID = item_id
    }
    $(NewCheckbox).attr("data-nkchk-multiid", MainID);
  
    //---- Nkal Controls must have these attributes
    $(NewCheckbox).addClass("nk_chk_img_div");
    var Click = "nk_chk_Click('" + item_id + "'," + multi + ",'" + MainID + "'," + unselect + ",'" + imgChkselected + "','" + imgChk + "');" + onClickEvent;
    var IsSelected = 'false';
    var Img = imgChk;
    if (checked == 'checked') {
        IsSelected = 'true';
        Img = imgChkselected;
    }
    if (readonly) {
        Click = "return true;" + Click
    }

    if (onMousOverEvent.length > 0) {
        onMousOverEvent = 'onmouseover="' + onMousOverEvent + '"'
    }
    if (onMouseOutEvent.length > 0) {
        onMouseOutEvent = 'onmouseout="' + onMouseOutEvent + '"'
    }
    
    $(NewCheckbox).html('<img class="nk_chk_img" data-checked="' + IsSelected + '" data-id="' + item_id + '" onclick="' + Click + '" ' + onMousOverEvent + ' ' + onMouseOutEvent + ' src="' + Img + '"/>');
    var NewLabel = document.createElement("div");
    $(NewLabel).addClass("nk_chk_label");
    $(NewLabel).html(txt);
    $(item).append(NewCheckbox);
    $(item).append(NewLabel);
    var Clear = document.createElement("div");
    $(Clear).addClass("nk_clear");
    $(item).append(Clear);
}

function nk_chk_Click(Item_ID, multi, MainID, unselect, imgChkselected, imgChk) {
    if (multi) {
        if ($('img[data-id="' + Item_ID + '"]').attr("data-checked") == 'false') {
            $('img[data-id="' + Item_ID + '"]').attr("data-checked", "true");
            $('img[data-id="' + Item_ID + '"]').attr("src", imgChkselected);
            $('input[id="' + Item_ID + '"]').click()
        } else {
            if (unselect) {
                $('img[data-id="' + Item_ID + '"]').attr("data-checked", "false");
                $('img[data-id="' + Item_ID + '"]').attr("src", imgChk);
                $('input[id="' + Item_ID + '"]').click()
            }
        }
    } else {
      
        if ($('img[data-id="' + Item_ID + '"]').attr("data-checked") == 'false') {
            $('table[id="' + MainID + '"] img').attr("data-checked", "false");
            $('table[id="' + MainID + '"] img').attr("src", imgChk);
            $('table[id="' + MainID + '"] input').removeAttr("checked");
            $('img[data-id="' + Item_ID + '"]').attr("data-checked", "true");
            $('img[data-id="' + Item_ID + '"]').attr("src", imgChkselected);
            $('table[id="' + MainID + '"] input[id="' + Item_ID + '"]').attr("checked", "checked");
        } else {
            if (unselect) {
           
                $('img[data-id="' + Item_ID + '"]').attr("data-checked", "false");
                $('img[data-id="' + Item_ID + '"]').attr("src", imgChk);
                $('table[id="' + MainID + '"] input[id="' + Item_ID + '"]').removeAttr("checked");
            }
        }
    }
}


function nk_chk_ReadOnly(items, isReadOnly) {
    $.each(items, function (index, item) {
            var ReadOnlyStatus = $(item).attr("data-nkchk-readonly")
            if (ReadOnlyStatus != isReadOnly) {
            $(item).attr("data-nkchk-readonly", isReadOnly)
            if ($(item).is("span")) { // is simple checkbox
                if (isReadOnly) {
                    var onclick = $(item).find("img").attr("onclick")
                    $(item).find("img").attr("onclick", "return true;" + onclick);
                } else {
                    var onclick = $(item).find("img").attr("onclick").replace("return true;", "")
                    $(item).find("img").attr("onclick", onclick);
                }
            } else {
               if (isReadOnly) {
                    $.each($(item).find("td"), function (ind, chk) {
                        var onclick = $(chk).find("img").attr("onclick")
                        $(chk).find("img").attr("onclick", "return true;" + onclick);
                    })
                } else {
                    $.each($(item).find("td"), function (ind, chk) {
                        var onclick = $(chk).find("img").attr("onclick").replace("return true;", "")
                        $(chk).find("img").attr("onclick", onclick);
                        
                    })
                }
            }
        }

    });
}

function nk_chk_Disable(items, isDisable,isCheked,CheckedValue) {
    $.each(items, function (index, item) {
        var imgChk = $(item).attr("data-nkchk-imgChk");
        var imgChkselected = $(item).attr("data-nkchk-imgChkselected");
        var imgDisable = $(item).attr("data-nkchk-imgDisable");
        if ($(item).is("span")) { // is simple checkbox
            if (isDisable) {
                $(item).find("img").attr("src", imgDisable);
                $(item).find("img").unbind('click');
                var onclick = $(item).find("img").attr("onclick")
                $(item).find("img").attr("onclick", "return false;" + onclick);
                $(item).find("img").attr("data-checked", "false");
                $(item).find("input").removeAttr("checked")
            } else {
                if (isCheked) {
                    $(item).find("img").attr("src", imgChkselected);
                    $(item).find("img").attr("data-checked", "true");
                    $(item).find("input").attr("checked", "checked")
                } else {
                    $(item).find("img").attr("src", imgChk);
                    $(item).find("img").attr("data-checked", "false");
                    $(item).find("input").removeAttr("checked")
                }
                var onclick = $(item).find("img").attr("onclick").replace("return false;", "")
                $(item).find("img").attr("onclick", onclick);
            }
        } else {
            if (isDisable) {
                $.each($(item).find("td"), function (ind, chk) {
                    $(chk).find("img").attr("src", imgDisable);
                    var onclick = $(chk).find("img").attr("onclick")
                    $(chk).find("img").attr("onclick", "return false;" + onclick);
                    $(chk).find("img").attr("data-checked", "false");
                    $(chk).find("input").removeAttr("checked")
                })
            } else {
                $.each($(item).find("td"), function (ind, chk) {
                    var onclick = $(chk).find("img").attr("onclick").replace("return false;", "")
                    $(chk).find("img").attr("onclick", onclick);

                    if (isCheked) {
                        $(chk).find("img").attr("src", imgChk);
                        $(chk).find("img").attr("data-checked", "false");
                        $(chk).find("input").removeAttr("checked");
                        if ($(chk).find('div[data-nkchk-plugin="checkbox"]').attr("data-nkchk-value") == CheckedValue) {
                            $(chk).find("img").attr("src", imgChkselected);
                            $(chk).find("img").attr("data-checked", "true");
                            $(chk).find("input").attr("checked", "checked")
                        }
                    } else {
                        $(chk).find("img").attr("src", imgChk);
                        $(chk).find("img").attr("data-checked", "false");
                        $(chk).find("input").removeAttr("checked");
                    }
                })
            }
        }
    });
}

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
