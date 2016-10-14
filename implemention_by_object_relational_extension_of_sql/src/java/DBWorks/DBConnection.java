package DBWorks;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *  @class DBConnection statically stores PostgreSQL server info,
 * 	and contains a single static method that executes a query passed info
 *  as a string from the JSP pages.
 */
public class DBConnection {
     
    static String driver = "org.postgresql.Driver";
    static String url = "jdbc:postgresql://localhost:5432/Talent_Sys";  
    static String username = "talent_manager";
    static String password = "C0mputer5cience";
    static String myDataField = null;
    static Connection myConnection = null;
    static PreparedStatement myPreparedStatement = null;
   
    /**
	 *  @method ExecQuery 
	 *	takes in query as a string, connects to PostgreSQL server (if not currently connected),
	 *  creates a prepared statement (of that query), and executes it.
	 *
	 * 	returns query results as a ResultSet, which can be iterated over
	 */
    public static ResultSet ExecQuery(String query){
        ResultSet myResultSet = null;
        try{
            if(myConnection == null || (myConnection !=null && !myConnection.isValid(0) ))
            {
                Class.forName(driver).newInstance();
                myConnection = DriverManager.getConnection(url,username,password);
            }
            myPreparedStatement = myConnection.prepareStatement(query);
            myResultSet = myPreparedStatement.executeQuery();
        } catch(ClassNotFoundException e)
        {
            e.printStackTrace();
        }
        catch (SQLException e){
            e.printStackTrace();
        } catch (InstantiationException ex) {
            Logger.getLogger(DBConnection.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IllegalAccessException ex) {
            Logger.getLogger(DBConnection.class.getName()).log(Level.SEVERE, null, ex);
        }
        return  myResultSet;
    }
                                        
}
