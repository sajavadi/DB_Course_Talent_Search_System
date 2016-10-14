
<%@page import="DBWorks.DBConnection"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.SQLException"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Talent Show System</title>

    <!-- Bootstrap Core CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="css/sb-admin.css" rel="stylesheet">

    <!-- Morris Charts CSS -->
    <link href="css/plugins/morris.css" rel="stylesheet">

    <!-- Custom Fonts -->
    <link href="font-awesome-4.1.0/css/font-awesome.min.css" rel="stylesheet" type="text/css">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

</head>

<body>

    <div id="wrapper">

        <!-- Navigation -->
        <nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
            <!-- Brand and toggle get grouped for better mobile display -->
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-ex1-collapse">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="index.jsp">Talent Show System</a>
            </div>

            <!-- Sidebar Menu Items - These collapse to the responsive navigation menu on small screens -->
            <div class="collapse navbar-collapse navbar-ex1-collapse">
                <ul class="nav navbar-nav side-nav">
                     <li class="active">
                        <a href="index.jsp"><i class="fa fa-fw fa-dashboard"></i> Dashboard</a>
                    </li>
                      <li>
                        <a href="javascript:;" data-toggle="collapse" data-target="#demo">
                        <i class="fa fa-fw fa-arrows-v"></i> Schema <i class="fa fa-fw fa-caret-down"></i></a>
                        <ul id="demo" class="collapse">
                            <li>
                                <a href="ERDiagram.jsp">ER Diagram</a>
                            </li>
                            <li>
                                <a href="RelationalModel.jsp">Relational Model</a>
                            </li>
                            
                        </ul>
                    </li>
                    <li>
                        <a href="FirstQuery.jsp"><i class="fa fa-fw fa-bar-chart-o"></i> First Query Result</a>
                    </li>
                    <li>
                        <a href="SecondQuery.jsp"><i class="fa fa-fw fa-bar-chart-o"></i> Second Query Result</a>
                    </li>
                    <li>
                        <a href="ThirdQuery.jsp"><i class="fa fa-fw fa-bar-chart-o"></i> Third Query Result</a>
                    </li>
                    <li>
                        <a href="FourthQuery.jsp"><i class="fa fa-fw fa-bar-chart-o"></i> Fourth Query Result</a>
                    </li>
                    <li>
                        <a href="FifthQuery.jsp"><i class="fa fa-fw fa-bar-chart-o"></i> Fifth Query Result</a>
                    </li>
                </ul>
            </div>
            <!-- /.navbar-collapse -->
        </nav>

        <div id="page-wrapper">

            <div class="container-fluid">

                <!-- Page Heading -->
                <div class="row">
                    <div class="col-lg-12">
                        <h1 class="page-header">
                            Second Query Result
                        </h1>
                        <ol class="breadcrumb">
                            <li>
                                <i class="fa fa-dashboard"></i>  <a href="index.jsp">Dashboard</a>
                            </li>
                            <li class="active">
                                <i class="fa fa-dashboard"></i> 2nd query
                            </li>
                        </ol>
                    </div>
                </div>
                <!-- /.row -->
                
                <div class="row">
                    
                   <div class="col-lg-6">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                    Query Description
                            </div>
                            <div class="panel-body">
                                Find all pairs of contestants who happened to audition 
                                the same piece (in possibly different shows) and got 
                                the same average score for that piece.
                            </div>
                        </div>
                    </div>
   
                   <div class="col-lg-6">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                    Query Results
                            </div>
                            <div class="panel-body">
                                <table class="table table-bordered table-hover">
                                <thead>
                                    <tr>
                                        <th> First Contestant </th>
                                        <th> Second Contestant </th>    
                                    </tr>
                                </thead>
                                <tbody>
                                 <%
                                    String SecondQuery = "SELECT cid2cname(a1.contestant), cid2cname(a2.contestant)" + 
                                                        " FROM audition a1, audition a2" +
                                                        " WHERE a1.contestant != a2.contestant AND" +
                                                        " a1.piece = a2.piece AND" +
                                                        " average_audition_score(a1) = average_audition_score(a2) AND" +
                                                        " a1.contestant > a2.contestant;" ;
                                        ResultSet myResultSet = DBConnection.ExecQuery(SecondQuery);
                                        while(myResultSet.next())
                                        {
                                            %>
                                            <tr>
                                                <td> <% out.print(myResultSet.getString(1)); %> </td> 
                                                <td> <% out.print(myResultSet.getString(2)); %> </td> 
                                            </tr>   
                                            <%
                                        }
                                   
                                  %>
                                </tbody>
                                </table>
                            </div>
                        </div>
                        <!-- /.panel -->
                    </div>
               
               
                </div>
                
            </div>
            <!-- /.container-fluid -->

        </div>
        <!-- /#page-wrapper -->

    </div>
    <!-- /#wrapper -->

    <!-- jQuery Version 1.11.0 -->
    <script src="js/jquery-1.11.0.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="js/bootstrap.min.js"></script>

    <!-- Morris Charts JavaScript -->
    <script src="js/plugins/morris/raphael.min.js"></script>
    <script src="js/plugins/morris/morris.min.js"></script>
    <script src="js/plugins/morris/morris-data.js"></script>

</body>

</html>
