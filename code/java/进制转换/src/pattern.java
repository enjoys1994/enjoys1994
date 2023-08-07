import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class pattern {


    public static void main(String[] args) {
        String input = ">>>>>>>>>> User [lightdb] database [see] schema [public] (lightdb@10.20.144.165:see(public)#db1)";

        // 使用正则表达式匹配参数部分
        String regex = ">>>>>>>>>> User \\[(.*?)\\](.*?)\\((.*?)\\)";

        //String regex = ">>>>>>>>>> User \\[(.*?)\\](.*?)\\((.*?)\\((.*?)\\)(.*?)\\)";

        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(input);

        // 提取参数值
        if (matcher.find()) {
            int count = matcher.groupCount();// 提取参数名
            for (int i = 1; i <= count; i++) {
                System.out.println(matcher.group(i));
            }

        }
    }


    public static void main1(String[] args) {
        String input = ">>>>>>>>>> User [lightdb] database [see] schema [public] (lightdb@10.20.144.165:see(public)#db2)";
        String regex = "\\((.*?)\\)#";
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(input);
        //String regex = ">>>>>>>>>> User \\[(.*?)\\](.*?)\\((.*?)\\((.*?)\\)(.*?)\\)";

        if (matcher.find()) {
            String matchedText = matcher.group(1);
            System.out.println("Matched Text: " + matchedText);
        }
    }
}

