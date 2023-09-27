
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;
import org.apache.velocity.app.VelocityEngine;

import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class VelocityParser {
    public static void main(String[] args) {
        if( null instanceof String){
            System.out.printf("111");
        }

        // 初始化 Velocity 引擎
        Velocity.init();

        // 创建 Velocity 上下文
        VelocityContext context = new VelocityContext();
        Map<String,String> p = new HashMap<>();
        p.put("primary_ip_address","aa");
        Map<String,String> p2 = new HashMap<>();
        p2.put("primary_ip_address","bb");
        // 在上下文中添加数据
        context.put("node", new ArrayList<Map>(){{add(p);};{add(p2);}});

        context.put("name", "John");
        context.put("age", 30);


       // String template = "Hello, $name! You are $age years old.";
        // 定义 Velocity 模板
        String template = "#set($primary_ip_addresses = [])#foreach($item in $node) #set ($swallow = $primary_ip_addresses.add($item.primary_ip_address))#end$primary_ip_addresses";

        // 解析模板
        String result = parseVelocityTemplate(template, context);

        // 打印解析后的结果
        System.out.println(result);
    }

    public static String parseVelocityTemplate(String template, VelocityContext context) {
        // 使用 Velocity 引擎解析模板
        VelocityEngine velocityEngine = new VelocityEngine();
        StringWriter writer = new StringWriter();
        velocityEngine.evaluate(context,writer,"",template);

        return writer.toString();
    }
}
