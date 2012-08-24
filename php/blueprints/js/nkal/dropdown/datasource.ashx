<%@ WebHandler Language="VB" Class="datasource" %>

Imports System
Imports System.Web

Public Class datasource : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        
        context.Response.ContentType = "application/json"
        context.Response.Write(OnlineMenuContext.GetOnlineMenu("default.aspx", "categories").GetJson())
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class