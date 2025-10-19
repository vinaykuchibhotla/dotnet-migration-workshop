<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Product Catalog - Legacy Application</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .grid-container { margin-top: 20px; }
        .grid { width: 100%; border-collapse: collapse; }
        .grid th, .grid td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .grid th { background-color: #4CAF50; color: white; }
        .grid tr:nth-child(even) { background-color: #f2f2f2; }
        .search-box { margin-bottom: 20px; }
        .search-box input { padding: 8px; margin-right: 10px; }
        .search-box button { padding: 8px 16px; background-color: #4CAF50; color: white; border: none; cursor: pointer; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="header">
            <h1>Legacy Product Catalog System</h1>
            <p>This is a .NET Framework 4.8 WebForms application running on Windows Server 2019 with MySQL backend.</p>
            <p><strong>Migration Workshop:</strong> This application will be modernized using AWS services.</p>
        </div>
        
        <div class="search-box">
            <asp:TextBox ID="txtSearch" runat="server" placeholder="Search products..."></asp:TextBox>
            <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" />
            <asp:Button ID="btnShowAll" runat="server" Text="Show All" OnClick="btnShowAll_Click" />
        </div>
        
        <div class="grid-container">
            <asp:GridView ID="gvProducts" runat="server" CssClass="grid" AutoGenerateColumns="false" 
                          AllowPaging="true" PageSize="20" OnPageIndexChanging="gvProducts_PageIndexChanging">
                <Columns>
                    <asp:BoundField DataField="ProductID" HeaderText="ID" />
                    <asp:BoundField DataField="ProductName" HeaderText="Product Name" />
                    <asp:BoundField DataField="Category" HeaderText="Category" />
                    <asp:BoundField DataField="Price" HeaderText="Price" DataFormatString="{0:C}" />
                    <asp:BoundField DataField="Stock" HeaderText="Stock" />
                    <asp:BoundField DataField="Supplier" HeaderText="Supplier" />
                    <asp:BoundField DataField="CreatedDate" HeaderText="Created" DataFormatString="{0:MM/dd/yyyy}" />
                </Columns>
            </asp:GridView>
        </div>
        
        <div style="margin-top: 20px;">
            <asp:Label ID="lblRecordCount" runat="server" Text=""></asp:Label>
        </div>
    </form>
</body>
</html>
