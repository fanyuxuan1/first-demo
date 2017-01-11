<%@ page import="db.PoolConn" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %><%--
  Created by IntelliJ IDEA.
  User: 28713
  Date: 2016/12/27
  Time: 16:20
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>我的购物车</title>
</head>
<body>
<header>
    <%
        session = request.getSession();
        String Email = (String) session.getAttribute("Email");
        if (Email == null) {
        response.sendRedirect("user_error?Email=eamil&name=name&error=21");
    } else {
    %>
    欢迎您<a href="user_center.jsp"><%=Email%></a>
    <%
        }
    %>
</header>
<section id="nav">
    <ul>
        <li><a href="index.jsp">首页</a></li>
        <li><a href="all_goods.jsp">所有商品</a></li>
        <li><a href="my_cart.jsp">购物车</a></li>
        <li><a href="my_order.jsp">我的订单</a></li>
        <li><a href="user_center.jsp">个人中心</a></li>
    </ul>
</section>
<%
    String sql = "SELECT cart.orderid,cart.gid,cart.number,good.gname,good.number,good.price FROM cart,good " +
            "WHERE cart.email=?&&cart.gid=good.gid";
    PoolConn poolConn = PoolConn.getPoolConn();
    try (Connection con = poolConn.getConnection();
         PreparedStatement statement = con.prepareStatement(sql)) {
        statement.setString(1, Email);
        ResultSet resultSet = statement.executeQuery();
%>
<form method="post" action="servlet/Buy">
    <table>
        <%
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy年MM月dd日HH时mm分");
            Date date;
            long gid;
            String time;
            int i = 0;
            while (resultSet.next()) {
                gid = resultSet.getLong(2);
                date = new Date(gid);
                time = formatter.format(date);
        %>
        <tr>
            <td><label for="checkbox<%=i%>"></label>
                <input id="checkbox<%=i%>" type="checkbox" name="checkbox" value="<%=i%>">
            </td>
            <td>
                <%=time%>
            </td>
            <td>
                <a href="good.jsp?gid=<%=gid%>"><%=resultSet.getString(4)%>
                </a>
            </td>
            <td>
                <label for="number<%=i%>"></label>
                <input class="number" type="number" id="number<%=i%>" name="number<%=i%>"
                       min="1" max="<%=resultSet.getInt(5)%>" value="<%=resultSet.getInt(3)%>"
                       onchange="numChange(<%=i%>)">
            </td>
            <td class="price" id="price<%=i%>">
                单价：￥<%=resultSet.getString(6)%>
            </td>
            <td>
                <a href="servlet/Delete?gid=<%=gid%>"></a>
            </td>
            <td>
                <p class="stock" id="stock<%=i%>"></p>
            </td>
        </tr>
        <%
                    i++;
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        %>
    </table>
    <input type="submit" id="submit" value="立刻购买">
    <%--TODO 删除--%>
    <a href="servlet/Delete">删除所选</a>
    <p id="totalPrice"></p>
</form>
<script>
    //加载页面时执行一次，显示库存总价信息
    function check() {
        var num = document.getElementsByClassName("number");
        var pri = document.getElementsByClassName("price");
        var totalPrice = document.getElementById("totalPrice");
        var numAtBegin = [];
        var total = 0;
        for (var n = 0; n < num.length; n++) {
            numAtBegin[n] = (num[n].value);
            var stock = document.getElementById("stock" + n);
            if (parseInt(num[n].max) < parseInt([n].value)) {
                stock.innerHTML = "库存不足！当前仅剩" + num[n].max + "件";
            } else {
                stock.innerHTML = "";
            }
            total = parseInt(num[n].value) * parseInt(pri[n].innerHTML.split("￥")[1]) + total;
            console.log("value:", parseInt(num[n].value));
            console.log("price:", parseInt(pri[n].innerHTML.split("￥")[1]));
        }
        totalPrice.innerHTML = "总价：￥" + total;
        return numAtBegin;
    }
    var numAtBegin = check();

    //数量改变，修改总价
    function numChange(nu) {
        var num = document.getElementById("number" + nu);
        var totalPrice = document.getElementById("totalPrice");
        var tPrice = parseInt(totalPrice.innerHTML.split("￥")[1]);
        var pri = parseInt(document.getElementById("price" + nu).innerHTML.split("￥")[1]);
        tPrice = tPrice + (parseInt(num.value) - numAtBegin[nu]) * pri;
        numAtBegin[nu]=parseInt(num.value);
        totalPrice.innerHTML = "总价：￥" + tPrice;
    }
</script>
</body>
</html>
