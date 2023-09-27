package demo.eval;

import java.awt.MouseInfo;
import java.awt.Point;

public class MouseCoordinatesExample {
    public static void main(String[] args) {
        // 使用 MouseInfo 获取鼠标当前位置
        Point mouseLocation = MouseInfo.getPointerInfo().getLocation();

        // 获取鼠标的 x 和 y 坐标
        int x = (int) mouseLocation.getX();
        int y = (int) mouseLocation.getY();

        System.out.println("Mouse Coordinates - X: " + x + ", Y: " + y);
    }
}