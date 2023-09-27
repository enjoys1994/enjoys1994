import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class HashMapExample {
    public static void main(String[] args) {
        // 创建一个HashMap
        HashMap<String, String> hashMap = new HashMap<>();

        // 添加键值对
        hashMap.put("apple", "red");
        hashMap.put("banana", "yellow");
        hashMap.put("cherry", "red");

        // 要查找的字符串
        String searchString = "app";

        // 创建一个迭代器来遍历HashMap的键集合

        // 遍历键集合
        // 判断键是否包含指定字符串
        // 如果包含，则删除对应的键值对
        hashMap.keySet().removeIf(key -> key.contains(searchString));

        // 打印剩余的键值对
        for (Map.Entry<String, String> entry : hashMap.entrySet()) {
            System.out.println("Key: " + entry.getKey() + ", Value: " + entry.getValue());
        }
    }
}
