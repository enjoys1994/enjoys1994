package com.example.upload;

import com.jcraft.jsch.*;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.*;

public class SSHFileUploader {

    public static void main(String[] args) throws Exception {


        List<String> strings = Arrays.asList(
                "10.20.144.166,root,Test@orca,/Users/wgy/Downloads/upgrade,/home/wgy/upgrade,mysql"
                , "10.20.144.165,wgy,Test@orca,/Users/wgy/Downloads/upgrade,/home/wgy/upgrade,lightdb"
                , "10.40.2.24,root,deploy@r#dcenter9,C:\\Users\\wanggy29750\\Downloads\\sync,/home/wgy/upgrade,mysql"
//              ,  "10.20.158.249,root,r#dcenter8,/Users/wgy/Downloads/sync,/home/update"

        );

        String envCommand = " source ~/.bash_profile  ";


        strings.forEach(s -> {
            String[] split = s.split(",");
            String host = split[0];
            String username = split[1];
            String password = split[2];
            String localFolderPath = split[3];
            String remoteFolderPath = split[4]; // 服务器上保存文件的文件夹路径
            String type = split[5];
            try {
                File localFolder = new File(localFolderPath);
                if (localFolder.exists() && localFolder.isDirectory()) {
                    JSch jsch = new JSch();
                    Session session = jsch.getSession(username, host, 22);
                    session.setPassword(password);
                    session.setConfig("StrictHostKeyChecking", "no"); // 不验证服务器的主机密钥
                    session.connect();
                    File[] files = localFolder.listFiles();
                    if (files != null) {
                        for (File file : files) {
                            if (file.isFile() && file.getName().contains("SEE2.0-linux")) {
                                if (type.equals("lightdb") && !file.getName().contains("lightdb")) {
                                    continue;
                                }
                                if (type.equals("mysql") && file.getName().contains("lightdb")) {
                                    continue;
                                }
                                System.out.println("开始升级服务器：" + host + " 文件：" + file.getName());
                                upload(session, file, remoteFolderPath + "/" + file.getName());
                                // 删除文件
                                file.delete();
                                // 执行远程命令
                                execCommand(session, " cd " + remoteFolderPath + " && rm -fr see ", 60);
                                execCommand(session, " cd " + remoteFolderPath + " && unzip " + file.getName(), 60);
                                File upgradeShellFile = write(type);
                                upload(session, upgradeShellFile, remoteFolderPath + "/see/" + upgradeShellFile.getName());
                                upgradeShellFile.delete();
                                execCommand(session, envCommand + "&& cd " + remoteFolderPath + "/see && chmod 750 upgradeseeOnServer.sh && sh upgradeseeOnServer.sh  ", 180);
                                execCommand(session, " cd " + remoteFolderPath + " && rm -fr " + file.getName(), 60);
                                execCommand(session, " cd " + remoteFolderPath + " && rm -fr see ", 60);
                                if (type.equals("lightdb")) {
                                    execCommand(session, envCommand + "&& cd $SEE20_INSTALL_HOME && rm -fr tomcat/.lightdb_sql_md5.properties  &&  sh lightdb_startUp.sh   ", 360);
                                } else {
                                    execCommand(session, envCommand + "&& cd $SEE20_INSTALL_HOME && rm -fr tomcat/.sql_md5.properties  &&  sh startUp.sh  ", 360);
                                }
                            }
                        }
                    }
                    session.disconnect();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
        System.exit(1);
    }

    private static File write(String type) throws Exception {
        String cmd = "set -e\n" +
                "set -x\n" +
                "\n" +
                "if command -v expect &>/dev/null; then\n" +
                "    echo \"expect 命令存在\"\n" +
                "else\n" +
                "    echo \"expect 命令不存在\"\n" +
                "    exit\n" +
                "fi\n" +
                "\n" +
                "expect -c \"\n" +
                "  set timeout -1\n";
        if (type.equals("lightdb")) {
            cmd = cmd + "  spawn sh lightdb_upgrade.sh\n";
        } else {
            cmd = cmd + "  spawn sh upgrade.sh\n";
        }
        cmd = cmd + "  expect {\n" +
                "     \\\"*Back up see*\\\"      {send \\\"no\\r \\\";exp_continue}\n" +
                "     \\\"*successfully upgraded*\\\"      {send \\\"no\\r \\\";exp_continue}\n" +
                "     expect eof\n" +
                "  }\n" +
                "  \"\n";
        String filePath = "upgradeseeOnServer.sh";
        // 创建一个输出流
        FileOutputStream outputStream = new FileOutputStream(filePath);
        outputStream.write(cmd.getBytes(StandardCharsets.UTF_8));
        // 关闭流
        outputStream.close();
        return new File(filePath);
    }

    private static void execCommand(Session session, String command, Integer timeout) throws Exception {
        System.out.println("远程服务器执行命令：" + command + " 开始...");
        ExecutorService executorService = Executors.newSingleThreadExecutor();
        ChannelExec channelExec = (ChannelExec) session.openChannel("exec");
        channelExec.setCommand(command);
        InputStream commandOutput = channelExec.getInputStream();
        channelExec.connect();
        Future<?> future = executorService.submit(() -> {
            try {
                // 读取并打印命令输出
                BufferedReader reader = new BufferedReader(new InputStreamReader(commandOutput, StandardCharsets.UTF_8));
                String line;
                while ((line = reader.readLine()) != null) {
                    System.out.println(line);
                }
            } catch (Exception ignored) {
            }
        });
        try {
            future.get(timeout, TimeUnit.SECONDS);
            System.out.println("远程服务器执行命令：" + command + " 成功...");
        } catch (TimeoutException e) {
            // Handle timeout exception
            future.cancel(true);
            System.out.println("远程服务器执行命令：" + command + " 超时...");
        } finally {
            commandOutput.close();
            channelExec.disconnect();
            executorService.shutdown();
            // 关闭连接
            channelExec.disconnect();
        }
    }

    private static void upload(Session session, File file, String remoteFilePath) throws Exception {
        ChannelSftp channelSftp = (ChannelSftp) session.openChannel("sftp");
        channelSftp.connect();
        // 上传文件
        final double[] uploadedBytes = {0};
        double totalSize = file.length();
        channelSftp.put(file.getAbsolutePath(), remoteFilePath, new SftpProgressMonitor() {
            private final Timer timer = new Timer();

            @Override
            public void init(int op, String src, String dest, long max) {
                System.out.println("File upload started: " + src + " -> " + dest);
                // 1秒输出一次
                long interval = 1000;
                timer.scheduleAtFixedRate(new TimerTask() {
                    @Override
                    public void run() {
                        double progress = (uploadedBytes[0] / totalSize) * 100;
                        System.out.printf("Upload progress: %.2f%%\n", progress);
                    }
                }, interval, interval);
            }

            @Override
            public boolean count(long count) {
                uploadedBytes[0] += count;
                return true;
            }

            @Override
            public void end() {
                System.out.println("File upload completed.");
                timer.cancel();
            }
        });
        channelSftp.disconnect();
    }
}
