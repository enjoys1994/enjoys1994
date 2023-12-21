package com.example.upload;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

class TaskRunner {
    private static final int TASK_RESULT = 42; // 假设任务的结果为42
    private static AtomicBoolean executed = new AtomicBoolean(false);
    private static CountDownLatch latch = new CountDownLatch(1);

    public int executeTask() throws InterruptedException {
        latch.countDown();
        if (!executed.compareAndSet(false, true)) {
            System.out.println("任务已执行，等待结果");
            latch.await(); // 等待任务结果
            return TASK_RESULT;
        }

        try {
            System.out.println("任务执行中...");
            TimeUnit.SECONDS.sleep(30); // 模拟任务执行时间
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            latch.countDown(); // 任务完成，释放等待
        }
        return TASK_RESULT;
    }
}

public class TaskExecution {
    public static void main(String[] args) throws InterruptedException {
        TaskRunner runner = new TaskRunner();
        int numberOfThreads = 5;
        for (int i = 0; i < numberOfThreads; i++) {
            final int id = i + 1;
            new Thread(() -> {
                try {
                    int result = runner.executeTask();
                    System.out.println("任务执行完成，结果为: " + result);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }).start();

            TimeUnit.SECONDS.sleep(5); // 控制线程创建间隔
        }
    }
}
