import java.io.IOException;
import java.sql.*;

public class main {
    public static void main(String[] args) throws IOException {
        //System.out.println("2024-01-01 00:00:00".substring(0,10));
       // System.out.println("2024-01-01 ".substring(0,10));
        // JDBC连接参数
        String url = "jdbc:mysql://10.20.144.166:3306/mysql"; // 数据库连接URL，根据实际情况修改
        String user = "root"; // 数据库用户名，根据实际情况修改
        String password = "r#dcenter9"; // 数据库密码，根据实际情况修改

        try {
            // 加载MySQL的JDBC驱动
            Class.forName("com.mysql.cj.jdbc.Driver");

            // 建立数据库连接
            Connection connection = DriverManager.getConnection(url, user, password);

            // 创建Statement对象用于执行SQL语句

            // 定义要执行的SQL语句

            Statement statement = connection.createStatement();
            String a = "0.01";
            for (int i = 0;i <=1000000000 ;i++) {
                String b = String.valueOf(Double.parseDouble(a)+0.01);
                if (a.equals(b)){
                    System.out.println(a);
                    break;
                }
                a = b;
                String sql = "select ROUND("+b+" + 0.01, 2) from dual"; // 根据实际情况修改SQL语句
                // 执行SQL语句并获取结果集
                ResultSet resultSet = statement.executeQuery(sql);
                // 遍历结果集并输出数据
                while (resultSet.next()) {
                    // 通过列名或索引获取数据
                    int id = resultSet.getInt("id");
                    String name = resultSet.getString("name");
                    int age = resultSet.getInt("age");

                    // 在此处处理数据，例如打印输出
                    System.out.println("ID: " + id + ", Name: " + name + ", Age: " + age);
                }
                // 关闭连接和释放资源
                resultSet.close();
            }

            statement.close();
            connection.close();

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

//        try {
//            File file = new File("/Users/stt/Desktop/wgy/workspace/go/wangguoyan/code/java/进制转换/src/a.txt");
//            FileReader reader = new FileReader(file);
//            BufferedReader bufferedReader = new BufferedReader(reader);
//            String line;
//            while ((line = bufferedReader.readLine()) != null) {
//                byte[] bytes = line.getBytes(StandardCharsets.UTF_8);
//                String aa = new String(bytes);
//                System.out.println(line);
//            }
//            bufferedReader.close();
//            reader.close();
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
    }
