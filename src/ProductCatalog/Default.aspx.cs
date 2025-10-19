using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadProducts();
        }
    }

    private void LoadProducts(string searchTerm = "")
    {
        try
        {
            DataAccess da = new DataAccess();
            DataTable dt = da.GetProducts(searchTerm);
            
            gvProducts.DataSource = dt;
            gvProducts.DataBind();
            
            lblRecordCount.Text = $"Total Records: {dt.Rows.Count}";
        }
        catch (Exception ex)
        {
            lblRecordCount.Text = $"Error loading products: {ex.Message}";
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        LoadProducts(txtSearch.Text.Trim());
    }

    protected void btnShowAll_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        LoadProducts();
    }

    protected void gvProducts_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvProducts.PageIndex = e.NewPageIndex;
        LoadProducts(txtSearch.Text.Trim());
    }
}
