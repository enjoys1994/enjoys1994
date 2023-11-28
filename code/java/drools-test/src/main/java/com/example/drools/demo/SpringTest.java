package com.example.drools.demo;

import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import org.springframework.scheduling.support.PeriodicTrigger;

import java.util.Date;
import java.util.concurrent.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SpringTest {

    public static void main(String[] args) throws InterruptedException, ExecutionException {
        // 创建一个 ScheduledThreadPoolExecutor，指定线程池大小
        LinkedBlockingDeque<Runnable> queue = new LinkedBlockingDeque<>(50);
        ThreadPoolExecutor scheduledThreadPool = new ThreadPoolExecutor(1,100,0L,TimeUnit.MILLISECONDS,queue, Executors.defaultThreadFactory(),new ThreadPoolExecutor.DiscardPolicy());

        for (int i = 0;i < 100;i++) {
            new Thread(()->{
                Future<?> submit = scheduledThreadPool.submit(() -> {
                    try {
                        Thread.sleep(500 * 1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                });
                Object o = null;
                try {
                    o = submit.get(600,TimeUnit.SECONDS);
                    System.out.println("成功");
                } catch (Exception e) {
                 //   e.printStackTrace();
                    System.out.println("失败");
                }


            }).start();
        }




        Thread.sleep(11111111);
    }

    public static void main2(String[] args) {
        String input = "metric_name{label1=\"value1\", label2=\"value2\"} 123.45";
        String pattern = "^([^\\s]+)(\\{([^\\}]+)\\})?\\s+([^\\s]+)$";
        Pattern r = Pattern.compile(pattern);
        Matcher m = r.matcher(input);

        if (m.find()) {
            String metricName = m.group(1);
            String labels = m.group(3);
            String value = m.group(4);

            System.out.println("Metric Name: " + metricName);
            System.out.println("2 " + m.group(2));
            System.out.println("Labels: " + (labels != null ? labels : "No labels"));
            System.out.println("Value: " + value);
        }

    }
}
