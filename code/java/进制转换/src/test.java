public class test{
    public static void main(String[] args) {
        test a = new test();
        int abc = a.BaseNToBase10("AAA", 32);
        a.Base10ToBaseN(1121, 16,"");
       // System.out.println(abc);
    }
    int BaseNToBase10(String src, int iBase) {
        int result = 0;
        for (int i = 0; i < src.length(); i++) {
            int res = 0;
            char c = src.charAt(i);
            if (c >= 'A'){
                res = 10 + c - 'A'  ;
            }else {
                res = Integer.parseInt(c+"");
            }
            result = result * iBase + res;
        }

        return result;
    }


    int Base10ToBaseN(int src, int iBase, String result) {
        int res = 0;
        while (res != src  && src != 0 ){
            res = src % iBase;
            int aa = res -10;
            String bb = "";
            if ( aa > 0){
                char c = (char)('A' + aa);
                bb = String.valueOf(c);
            }else {
                bb = res+"";
            }
            result = bb + result;
            src = (src - res) / iBase;
        }

        System.out.println(result);
        return 0;
    }


}

