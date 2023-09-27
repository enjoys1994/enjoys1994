package demo.eval;

import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.InputEvent;

public class MouseClickExample {
    public static void main(String[] args) {
        try {
            // 创建 Robot 对象
            Robot robot = new Robot();

            // 设置鼠标点击的坐标 (x, y)
            int x = 100;
            int y = 200;

            // 移动鼠标到指定坐标
            robot.mouseMove(x, y);

            // 模拟鼠标左键点击
            robot.mousePress(InputEvent.BUTTON1_DOWN_MASK);
            robot.mouseRelease(InputEvent.BUTTON1_DOWN_MASK);
        } catch (AWTException e) {
            e.printStackTrace();
        }
    }
}
