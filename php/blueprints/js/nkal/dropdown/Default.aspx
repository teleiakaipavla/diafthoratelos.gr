<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="Plugins_dropdown_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title> ddl</title>
    <script src="jquery-1.6.2.js" type="text/javascript"></script>
    <link href="scroll/jquery.jscrollpane.css" rel="stylesheet" type="text/css" />
    <script src="scroll/jquery.mousewheel.js" type="text/javascript"></script>
    <script src="scroll/jquery.jscrollpane.js" type="text/javascript"></script>
    <link href="dropdown.css" rel="stylesheet" type="text/css" />
    <script src="dropdown.js" type="text/javascript"></script>
   
    <script>
        $(document).ready(function () {
            $('.ena').nk_dropdown({ width: 350, theme: 'nkal', srcText: 'Αναζήτηση μοντελου', classname: 'nkal', rows: 5, datasource: 'datasource.ashx', datatext: 'Title', datavalue: 'MenuID' });
            $('.dio').nk_dropdown({ width: 250, rows: 5, srcType: false });
        })
    </script>  
</head>

<body>
    <form id="form1" runat="server">
    <div>
    </div>
    <div>
           <table>
            <tr>
                <td ><asp:DropDownList ID="drop1" CssClass="ena" runat="server" >
                    <asp:ListItem Text="text 11" Value="11"></asp:ListItem>
                    <asp:ListItem Text="text 12" Value="12"></asp:ListItem>
                </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td><asp:DropDownList ID="DropDownList1" CssClass="dio" runat="server" >
                    <asp:ListItem Text="text 11" Value="11"></asp:ListItem>
                    <asp:ListItem Text="text 12" Value="12"></asp:ListItem>
                    <asp:ListItem Text="text 13" Value="13"></asp:ListItem>
                    <asp:ListItem Text="text 14" Value="14"></asp:ListItem>
                    <asp:ListItem Selected="True"   Text="text 15" Value="15"></asp:ListItem>
                    <asp:ListItem Text="text 16" Value="16"></asp:ListItem>
                    <asp:ListItem  Text="text 17" Value="17"></asp:ListItem>
                    <asp:ListItem Text="text 18" Value="18"></asp:ListItem>
                    <asp:ListItem Text="text 19" Value="19"></asp:ListItem>
                    <asp:ListItem Text="text 24" Value="24"></asp:ListItem>
                    <asp:ListItem  Text="text 25" Value="25"></asp:ListItem>
                    <asp:ListItem Text="text 26" Value="26"></asp:ListItem>
                    <asp:ListItem  Text="text 27" Value="27"></asp:ListItem>
                </asp:DropDownList></td>
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
                    jquery.jscrollpane.css<br />
                    jquery.mousewheel.js<br />
                    jquery.jscrollpane.js<br />
                    dropdown.css<br />
                    dropdown.js<br /> <br /><hr />
                </td>
           </tr>
           <tr>
                <td><b>Init</b></td>
           </tr>
           <tr>
                <td>
                   <b>Simple</b> <br />$('.cssname').nk_dropdown(); <br /> <br /><hr />
                </td>
           </tr>
           <tr>
                <td>
                   <b>Set width</b> <br />$('.cssname').nk_dropdown({ width: 200 });</b> <br /> <br /><hr />
                </td>
           </tr>
           <tr>
                <td>
                   <b>Set theme</b> <br />$('.cssname').nk_dropdown({ theme: 'nkal' });</b> <br /> <br /><hr />
                </td>
           </tr>
            <tr>
                <td>
                   <b>Set Search text</b> <br />$('.cssname').nk_dropdown({ srcText: 'type to search' });</b> <br /> <br /><hr />
                </td>
           </tr>

            <tr>
                <td>
                   <b>Change Pointer Image</b> <br />$('.cssname').nk_dropdown({ pointerUrl: '../dropdown/themes/simple/pointer.png' });</b> <br /> <br /><hr />
                </td>
           </tr>

            <tr>
                <td>
                   <b>Disable Search </b> <br />$('.cssname').nk_dropdown({ srcType: false });</b> <br /> <br /><hr />
                </td>
           </tr>

            <tr>
                <td>
                   <b>Set classname </b> <br />$('.cssname').nk_dropdown({ classname: 'nkal' });</b> <br /> <br /><hr />
                </td>
           </tr>
           <tr>
                <td>
                   <b>Set Extra style to result row </b> <br />$('.cssname').nk_dropdown({ resultExtraStyle: 'font-size:12px' });</b> <br /> <br /><hr />
                </td>
           </tr>
           
             <tr>
                <td>
                   <b>Set numbers of rows that u want to show </b> <br />$('.cssname').nk_dropdown({ rows: 5 });</b> <br /> <br /><hr />
                </td>
           </tr>

            <tr>
                <td>
                   <b>Set dropdown Readonly </b> <br />$('.cssname').nk_dropdown({ readonly: true });</b> <br /> <br /><hr />
                </td>
           </tr>
           <tr>
                <td>
                   <b>Handle onchange event </b> <br /></b>You can overwrite  function nk_ddl_OnChange(ControlID, value) {}<br />ControlID = the id of your control <br />value = the new selected value <br /> <br /><hr />
                </td>
           </tr>

           
           
            <tr>
                <td style="font-size:17px"><b><u>Function to Readonly</u></b> &nbsp;----&nbsp;&nbsp;<span style="font-size:14px">nk_ddl_ReadOnly(items, isReadOnly);</span></td>
           </tr>
           <tr>
                <td><b>if u want to make the DROPDOWN to READONLY status </b><br />
                       <a onclick="nk_ddl_ReadOnly($('.ena'),true)" style="cursor:pointer;color:blue">nk_ddl_ReadOnly($('checkboxid'),true)</a><br /><br />
                       <b>if u want to make the DROPDOWN from READONLY status to NORMAL STATUS</b><br /><br />
                       <a onclick="nk_ddl_ReadOnly($('.ena'),false)" style="cursor:pointer;color:blue">nk_ddl_ReadOnly($('checkboxid'),false)</a><br /><br /><hr />
                 </td>
           </tr>
           </table>
    </div>
    </form>
</body>
</html>
