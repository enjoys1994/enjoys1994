import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;

import java.io.IOException;
import java.io.OutputStream;
import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.net.InetSocketAddress;

public class SimpleHttpServer {

    public static void main(String[] args) throws Exception {
        int port = 1111; // 设置监听端口

        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);

        // 创建一个上下文，指定路径为 /test，处理 POST 请求
        server.createContext("/test", new TestHandler());

        server.setExecutor(null); // 使用默认的线程池
        System.out.println("启动端口："+port);
        server.start(); // 启动服务器
    }

    static class TestHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            // 获取 POST 请求的输入流
            InputStreamReader isr = new InputStreamReader(exchange.getRequestBody());
            BufferedReader br = new BufferedReader(isr);

            // 读取 POST 请求的参数
            String line;
            StringBuilder requestBody = new StringBuilder();
            while ((line = br.readLine()) != null) {
                requestBody.append(line);
            }

            // 处理请求参数
            String response = "Received POST request with data: " + requestBody.toString();
            try {
                Thread.sleep(30 * 1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(response);
            // 发送响应
            exchange.sendResponseHeaders(200, response.length());
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }
    }
}
