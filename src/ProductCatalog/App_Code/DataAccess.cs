using System;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;

public class DataAccess
{
    private string connectionString;

    public DataAccess()
    {
        connectionString = ConfigurationManager.ConnectionStrings["ProductCatalogDB"].ConnectionString;
    }

    public DataTable GetProducts(string searchTerm = "")
    {
        DataTable dt = new DataTable();
        
        using (MySqlConnection conn = new MySqlConnection(connectionString))
        {
            string query = @"
                SELECT ProductID, ProductName, Category, Price, Stock, Supplier, CreatedDate 
                FROM Products 
                WHERE (@searchTerm = '' OR ProductName LIKE @searchParam OR Category LIKE @searchParam OR Supplier LIKE @searchParam)
                ORDER BY ProductID";

            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@searchTerm", searchTerm);
                cmd.Parameters.AddWithValue("@searchParam", $"%{searchTerm}%");

                using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }
            }
        }
        
        return dt;
    }

    public int GetProductCount()
    {
        using (MySqlConnection conn = new MySqlConnection(connectionString))
        {
            string query = "SELECT COUNT(*) FROM Products";
            using (MySqlCommand cmd = new MySqlCommand(query, conn))
            {
                conn.Open();
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }
}
