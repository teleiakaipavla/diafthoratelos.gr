<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="Plugins_dropdown_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="jquery-1.6.2.js" type="text/javascript"></script>
    <link href="checkbox.css" rel="stylesheet" type="text/css" />
    <script src="checkbox.js" type="text/javascript"></script>
    <script>

        function checkiiii(obj) {
            alert($(obj).attr("data-id"))
        }
        var item1 = null
        var item2 = null
        $(document).ready(function () {
           // $('.ena').nk_checkbox();
           // $('.enas').nk_checkbox();
            $('.dios').nk_checkbox({ multi: false, imgChkselected: '../checkbox/themes/nkal/chkselected.png', datasource: 'datasource.ashx', datatext: 'Title', datavalue: 'MenuID', columnrow: 3, onClick: 'checkiiii(this);', onMousOver: '', onMouseOut: '' })
            $('.dioss').nk_checkbox({ multi: false, unselect: false, imgChkselected: '../checkbox/themes/nkal/chkselected.png' })
        })

    </script>  
</head>
<body>
    <form id="form1" runat="server">
    <div onclick="nk_chk_Disable($('.dio'), true);nk_chk_Disable($('.dios'), true);">disable
    </div>
    <div onclick="nk_chk_Disable($('.dios'), false,false);">enable unchecked
    </div>
    <div onclick="nk_chk_ReadOnly($('.dios'),true);">ReadOnly</div>
     <div onclick="nk_chk_ReadOnly($('.dios'), false);">From Readonly to normal</div>
    <div>
           <table >
            <tr>
                <td ><asp:CheckBoxList CssClass="dios" ID="CheckBox2" runat="server" RepeatColumns="2">
                    <asp:ListItem Text="text1a" Value="text1" ></asp:ListItem>
                </asp:CheckBoxList> 
                </td>
            </tr>
            <tr>
                <td ><div id="mychk"></div>
                <asp:CheckBoxList CssClass="dioss" ID="CheckBoxList1" runat="server" RepeatColumns="4">
                    <asp:ListItem Text="text1a" Value="text1" ></asp:ListItem>
                    <asp:ListItem Text="text1a" Value="text2" ></asp:ListItem>
                    <asp:ListItem Text="text1a" Value="text2" ></asp:ListItem>
                    <asp:ListItem Text="text1a" Value="text2" ></asp:ListItem>
                    <asp:ListItem Text="text1a" Value="text2" ></asp:ListItem>
                </asp:CheckBoxList> 
                </td>
            </tr>
           
           </table>
           <table>
            <tr>
                <td colspan="2" style="font-size:20px"><b>How To</b> <br /> <br /><hr /></td>
            </tr>
           <tr>
                <td><b>files</b></td>
           </tr>
           <tr>
                <td>
                    jquery-1.6.2.js<br />
                    checkbox.css<br />
                    checkbox.js<br /> <br /><hr />
                </td>
           </tr>
           <tr>
                <td><b>Init</b></td>
           </tr>
           <tr>
                <td>
                   <b>Simple</b> <br />$('.cssname').nk_checkbox(); <br /> <br /><hr />
                </td>
           </tr>

           <tr>
                <td>
                   <b>Set OnClick Event</b> <br />$('.cssname').nk_checkbox({ onClick: 'alert(this);' });</b> <br /> <br /><hr />
                </td>
           </tr>

           <tr>
                <td>
                   <b>Set omouseOver & onmouseOut Event</b> <br />$('.cssname').nk_checkbox({ onMousOver: 'alert(this);', onMouseOut: 'alert(this);' });</b> <br /> <br /><hr />
                </td>
           </tr>

           <tr>
                <td>
                   <b>Start Disabled</b> <br />$('.cssname').nk_checkbox({ isDisable: true });</b> <br /> <br /><hr />
                </td>
           </tr>
           <tr>
                <td>
                   <b>Start Readonly</b> <br />$('.cssname').nk_checkbox({ readonly: true });</b> <br /> <br /><hr />
                </td>
           </tr>
           <tr>
                <td>
                   <b>If you use checkbox list and u want to check only one per click</b> <br />$('.cssname').nk_checkbox({ multi: false });<b> <br /> <br /><hr />
                </td>
           </tr>
            <tr>
                <td>
                   <b>If you use checkbox list and u want always one of the checkboxes to be checked</b> <br />$('.cssname').nk_checkbox({ unselect: false }); <br /> <br /><hr />
                </td>
           </tr>
            <tr>
                <td>
                   <b>If you want to change checkbox image</b> <br />
                   <b>unchecked ---></b> $('.cssname').nk_checkbox({  imgChk: '../checkbox/themes/nkal/chk.png' });<br />
                   <b>checked ---></b> $('.cssname').nk_checkbox({  imgChkselected: '../checkbox/themes/nkal/chk.png' });<br />
                   <b>disable ---></b> $('.cssname').nk_checkbox({  imgDisable: '../checkbox/themes/nkal/disable.png' });<br /><br /><br /><hr />
                </td>
           </tr>
           <tr>
                <td style="font-size:17px"><b><u>Function to Disable/Enable</u></b> &nbsp;----&nbsp;&nbsp;<span style="font-size:14px">nk_chk_Disable(items, isDisable,isCheked,CheckedValue);</span></td>
           </tr>
           <tr>
                <td><b>if u want to disable the CHECKBOX or all the CHECKBOXLIST</b><br />
                       nk_chk_Disable($('checkboxid'),true)<br /><br />
                    <b>if u want to enable the CHECKBOX or all the CHECKBOXLIST</b><br />
                       nk_chk_Disable($('checkboxid'),false)<br /><br />
                    <b>if u want to enable the CHECKBOX and to auto check the CHECKBOX</b><br />
                       nk_chk_Disable($('checkboxid'),false,true)<br /><br />
                       <b>if u want to enable the CHECKBOXLIST and to auto check the one specific checkbox (by the value) and the value for example is 'testvalue1'</b><br /<br />
                       nk_chk_Disable($('checkboxid'),false,true,'testvalue1')<br /><br /><br /><hr />
                 </td>
           </tr>

           <tr>
                <td style="font-size:17px"><b><u>Function to select</u></b></td>
           </tr>
           <tr>
                <td><b>if u want to enable the CHECKBOX and to auto check the CHECKBOX</b><br />
                       nk_chk_Disable($('checkboxid'),false,true)<br /><br />
                       <b>if u want to enable the CHECKBOXLIST and to auto check the one specific checkbox (by the value) and the value for example is 'testvalue1'</b><br /><br />
                       nk_chk_Disable($('checkboxid'),false,true,'testvalue1')<br /><br /><hr />
                 </td>
           </tr>
            <tr>
                <td style="font-size:17px"><b><u>Function to Readonly</u></b> &nbsp;----&nbsp;&nbsp;<span style="font-size:14px">nk_chk_ReadOnly(items, isReadOnly);</span></td>
           </tr>
           <tr>
                <td><b>if u want to make the CHECKBOX or CHECKBOXLIST to READONLY status </b><br />
                       nk_chk_ReadOnly($('checkboxid'),true)<br /><br />
                       <b>if u want to make the CHECKBOX or CHECKBOXLIST from READONLY status to NORMAL STATUS</b><br /><br />
                       nk_chk_ReadOnly($('checkboxid'),false)<br /><br /><hr />
                 </td>
           </tr>
           </table>
    </div>
    </form>
 
</body>
</html>
