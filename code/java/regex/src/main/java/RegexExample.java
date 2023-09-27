import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class RegexExample {
    public static void main(String[] args) {
        String input = "客户端连接数：dynamicThreshold(mean,{baseInfo:clientSize},1)。当前堆大小：dynamicThreshold(min,{memoryInfo:usingMemory},\n" +
                "\n" +
                "回收期名称:{heapInfo:type} 内存类型 dynamicThreshold(min,{heapInfo:type},2)";
        String regex = "(?s)(\\w+)\\((.*)\\)";

        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(input);

        if (matcher.find()) {

            System.out.println("函数名: " + matcher.group());
        } else {
            System.out.println("没有匹配的内容。");
        }
    }
}
