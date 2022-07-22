import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class test {

    public static void main(String[] args) throws IOException {

        BufferedReader bf = new BufferedReader(new InputStreamReader(System.in));
        String bb = bf.readLine();
        String fromToStr = "1 9";
        String[] fromTo = fromToStr.split(" ");
        Integer from = Integer.valueOf(fromTo[0]);
        Integer to = Integer.valueOf(fromTo[1]);
        String pointStr = "1-4,1-6,2-4,2-6,3-5,3-6,4-5,5-6,3-7,7-8,8-9";
        String[] points = pointStr.split(",");
        Integer n = 0;
        for (String point : points) {
            String[] split = point.split("-");
            Integer pointA = Integer.valueOf(split[0]);
            Integer pointB = Integer.valueOf(split[1]);
            if (pointA > n) {
                n = pointA;
            }
            if (pointB > n) {
                n = pointB;
            }
        }
        n++;
        int[][] a = new int[n][n];
        int[][] b = new int[n][n];
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                a[i][j] = Integer.MAX_VALUE >> 1;
            }
            a[i][i] = 0;
        }
        for (String point : points) {
            String[] split = point.split("-");
            Integer pointA = Integer.valueOf(split[0]);
            Integer pointB = Integer.valueOf(split[1]);
            a[pointA][pointB] = 1;
            a[pointB][pointA] = 1;
        }
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                b[i][j] = i;
            }
        }
        floyd(a, n, b, from, to);
    }

    private static void floyd(int[][] a, int n, int[][] b, int from, int to) {
        for (int k = 0; k < n; k++) {
            for (int i = 0; i < n; i++) {
                for (int j = 0; j < n; j++) {
                    if (a[i][j] > a[i][k] + a[k][j] && a[i][k] + a[k][j] > 0) {
                        b[i][j] = b[k][j];
                        a[i][j] = a[i][k] + a[k][j];
                    }
                }
            }
        }
        int next = b[from][to];
        System.out.print(to);
        while (true) {
            System.out.print(next);
            next = b[from][next];
            if (next == b[from][next]) {
                break;
            }

        }
        System.out.println(from);
    }
}

