import org.influxdb.InfluxDB;
import org.influxdb.InfluxDBFactory;
import org.influxdb.dto.Point;

import java.util.concurrent.TimeUnit;

public class InfluxDBExample {

    public static void main(String[] args) {
        // 连接到 InfluxDB 服务器
        String serverUrl = "http://10.40.2.24:18086"; // InfluxDB 服务器地址
        String username = "root"; // 用户名
        String password = "r#dcenter9"; // 密码

        InfluxDB influxDB = InfluxDBFactory.connect(serverUrl, username, password);
        // 插入数据点到数据库
        String dbName = "see"; // 数据库名称
        influxDB.setDatabase(dbName);
        for (int i = 0; i < 250 * 100 * 100; i++) {
            // 创建要插入的数据点
            Point point = Point.measurement("ci_linux_cpu")
                    .time(System.currentTimeMillis(), TimeUnit.MILLISECONDS)
                    .tag("monitorKey", "value1")
                    .tag("host", "10.40.2.23")
                    .addField("use", String.valueOf(i % 100))
                    .build();
            influxDB.write(point);
        }

      /*  // 查询数据示例
        String query = "SELECT * FROM your_measurement WHERE tag1 = 'value1'";
        QueryResult queryResult = influxDB.query(new Query(query, dbName));

        // 处理查询结果
        System.out.println("Query Result:");
        System.out.println(queryResult);*/

        // 关闭连接
        influxDB.close();
    }
}
