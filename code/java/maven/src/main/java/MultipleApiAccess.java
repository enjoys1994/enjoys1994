import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.ProtocolException;
import java.net.URL;
import java.util.Random;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class MultipleApiAccess {

    public static void main(String[] args) {
        ScheduledExecutorService executorService = Executors.newScheduledThreadPool(1);
        Random random = new Random();

        // 定义多个接口访问任务
        Runnable api1AccessTask = createApiAccessTask("http://localhost:9091/testd");
        Runnable api2AccessTask = createApiAccessTask("http://localhost:9091/login");
        Runnable api3AccessTask = createApiAccessTask("http://localhost:9091/testReadOnlyW");
        Runnable api4AccessTask = createApiAccessTask("http://localhost:9091/list");
        Runnable api5AccessTask = createApiAccessTask("http://localhost:9091/teste");



        // 启动多个任务，并随机设置访问时间间隔
        scheduleWithRandomDelay(executorService, api1AccessTask, random);
        scheduleWithRandomDelay(executorService, api2AccessTask, random);
        scheduleWithRandomDelay(executorService, api3AccessTask, random);
        scheduleWithRandomDelay(executorService, api4AccessTask, random);
        scheduleWithRandomDelay(executorService, api5AccessTask, random);
    }

    private static Runnable createApiAccessTask(String apiName) {
        return () -> {
            try {
            URL url = new URL(apiName);
            // 打开连接
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            // 设置请求方法（GET、POST 等）
            connection.setRequestMethod("GET");
            // 获取响应码
            int responseCode = 0;
            responseCode = connection.getResponseCode();
             //   System.out.println("Response Code: " + responseCode + "访问接口 " + apiName + "：" + System.currentTimeMillis());
         //   System.out.println();
            // 在这里编写访问接口的逻辑

            } catch (Exception e) {
                e.printStackTrace();
            }
        };
    }

    private static void scheduleWithRandomDelay(ScheduledExecutorService executorService, Runnable task, Random random) {
        int initialDelay = random.nextInt(1000) + 1; // 随机初始延迟时间（1）
        int interval = random.nextInt(1000) + 1; // 随机访问间隔时间（1）

        executorService.scheduleWithFixedDelay(task, initialDelay, interval, TimeUnit.MILLISECONDS);
    }
}
