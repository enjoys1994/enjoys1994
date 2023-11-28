package demo.eval;

import com.jcraft.jsch.*;

import java.io.InputStream;

/**
 * app
 *
 * @author levi
 * @date 2023/3/13
 */
public class Jsch {

    public static void main(String[] args) {
        Session session = null;
        try {
            JSch js = new JSch();
            session = js.getSession("root","10.20.191.51",22);
            session.setPassword("ERTzxc@#$123");
            session.setConfig("StrictHostKeyChecking", "no");
            /*Socket socket = new Socket("10.20.144.180", 22);
            SocketFactory factory = new SocketFactory() {
                @Override
                public Socket createSocket(String host, int port) throws IOException, UnknownHostException {
                    return socket;
                }

                @Override
                public InputStream getInputStream(Socket socket) throws IOException {
                    return socket.getInputStream();
                }

                @Override
                public OutputStream getOutputStream(Socket socket) throws IOException {
                    return socket.getOutputStream();
                }
            };
            session.setSocketFactory(factory);*/


            String[] ss = new String[]{
                    "egrep \"^trade_yx:\" /etc/passwd >& /dev/null; if [ $? -ne 0 ];then echo 0;else if [ -f '/home/o45_yx/trade_yx/ips/ips-businpub/ips-businpub/scripts/javaserver/businpub/stop_javaserver.sh' ];then cd '/home/o45_yx/trade_yx/ips/ips-businpub/ips-businpub'; sh '/home/o45_yx/trade_yx/ips/ips-businpub/ips-businpub/scripts/javaserver/businpub/stop_javaserver.sh'  forceKill=false;else echo 0; fi; fi"
            ,"egrep \"^trade_yx:\" /etc/passwd >& /dev/null; if [ $? -ne 0 ]; then echo 0; else if [ -f '/home/o45_yx/trade_yx/ips/ips-businpub/ips-businpub/scripts/javaserver/businpub/validateStop.sh' ];then cd '/home/o45_yx/trade_yx/ips/ips-businpub/ips-businpub';sh '/home/o45_yx/trade_yx/ips/ips-businpub/ips-businpub/scripts/javaserver/businpub/validateStop.sh'  forceKill=false; else echo 0; fi; fi"
            ,"cd '/home/o45_yx/trade_yx/ips/ips-businpub/ips-businpub'; sh '/home/o45_yx/trade_yx/ips/ips-businpub/ips-businpub/scripts/javaserver/businpub/run_javaserver.sh' ;"
            ,"egrep \"^trade_yx:\" /etc/passwd >& /dev/null; if [ $? -ne 0 ]; then echo 0; else if [ -f '/home/o45_yx/trade_yx/ips/ips-businpub/ips-businpub/scripts/javaserver/businpub/validateStart.sh' ];then cd '/home/o45_yx/trade_yx/ips/ips-businpub/ips-businpub';sh '/home/o45_yx/trade_yx/ips/ips-businpub/ips-businpub/scripts/javaserver/businpub/validateStart.sh' ;else echo 0; fi; fi"
            };
            session.connect();
            for (String command:ss){

                command = "source /etc/profile; source /etc/bashrc; source ~/.bashrc;  source ~/.bash_profile ;" +
                        "su trade_yx -c \"" +
                        command +
                        "\"";
                Channel channel = session.openChannel("exec");

                System.out.println("Command input :");
                System.out.println(command);
                ((ChannelExec) channel).setCommand(command);
                channel.setInputStream(null);
                ((ChannelExec) channel).setErrStream(System.err);

                InputStream in = channel.getInputStream();
                long startTime = System.currentTimeMillis();
                channel.connect();
                byte[] buffer = new byte[1024];
                int bytesRead;
                StringBuilder output = new StringBuilder();
                while ((bytesRead = in.read(buffer)) != -1) {
                    output.append(new String(buffer, 0, bytesRead));
                }
                channel.disconnect();

                long endTime = System.currentTimeMillis(); // 获取结束时间
                long executionTime = endTime - startTime; // 计算执行时间，单位毫秒

                System.out.println("Method execution time: " + executionTime + " milliseconds");

                System.out.println("Command output:");
                System.out.println(output.toString());
            }
            session.disconnect();
//            for (int i = 0; i < 3; i++) {
//                Session finalSession = session;
//                final int index = i;
//                Thread t = new Thread(new Runnable() {
//                    @Override
//                    public void run() {
//                        try {
//                            ChannelSftp sftp = (ChannelSftp) finalSession.openChannel("sftp");
//                            sftp.connect();
//                            sftp.cd("/home/levi");
//                            FileInputStream fis = new FileInputStream("/Users/liuyinghao/Downloads/ideaIU-2022.3.2.exe");
//                            sftp.put(fis, "ideaIU.exe" + index);
//                            sftp.disconnect();
//                        } catch (Exception e) {
//                            e.printStackTrace();
//                        }
//                    }
//                });
//                t.start();
//                threadList.add(t);
//            }
//            for (Thread thread : threadList) {
//                thread.join();
//            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (session != null) {
                session.disconnect();
            }

        }
    }
}
