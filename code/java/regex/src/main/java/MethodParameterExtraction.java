import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MethodParameterExtraction {
    public static void main(String[] args) {
        String expression = "plus>method(a,b,c) || p < method(d,e,f)";
        String methodName = "method";

        // 构建正则表达式，匹配 method() 调用并提取参数
        String regex = methodName + "\\((.*?)\\)";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(expression);

        // 提取参数并打印
        while (matcher.find()) {
            String parameters = matcher.group(1); // 提取参数列表
            System.out.println("Method Call: " + matcher.group());
            System.out.println("Parameters: " + parameters);
        }
    }
}
