package com.example.upload;

import com.jcraft.jsch.*;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.stream.Collectors;

public class UpgradeSEE {

    public static void main(String[] args) {


        List<String> strings = Arrays.asList(
//                "10.20.45.174,root,Preview@see2023,/Users/wgy/Downloads/upgrade,/home/wgy/upgrade,mysql",
                "10.20.144.166,root,Test@orca,/Users/wgy/Downloads/upgrade,/home/wgy/upgrade,mysql",
//                "10.20.144.165,wgy,Test@orca,/Users/wgy/Downloads/upgrade,/home/wgy/upgrade,lightdb",
//               "10.20.158.249,root,r#dcenter8,/Users/wgy/Downloads/sync,/home/update",
                ""
        );
        // 是否删除文件·
        AtomicBoolean deleteFlag = new AtomicBoolean(false); // 默认值
        if (args != null && args.length > 0) {
            // java -jar 调用
            strings = Arrays.asList(args);
            strings = strings.stream().map(s -> {
                        if (s.startsWith("--delete=")) {
                            deleteFlag.set(Boolean.parseBoolean(s.substring(s.indexOf("=") + 1)));
                            System.out.println("是否删除文件: " + deleteFlag);
                            return null;
                        }
                        if (s.startsWith("--config=")) {
                            System.out.println("config :" + s);
                            return s.substring(s.indexOf("=") + 1);
                        }
                        return null;
                    }
            ).filter(Objects::nonNull).collect(Collectors.toList());
        }

        String envCommand = " source ~/.bash_profile  ";
        strings.forEach(s -> {
            String[] split = s.split(",");
            if (split.length != 6) {
                return;
            }
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
                                System.out.println("开始升级服务器：" + host + " 文件：" + file.getName() + "开始。。。");
                                upload(session, file, remoteFolderPath + "/" + file.getName());
                                // 删除文件
                                if (deleteFlag.get()) {
                                    file.delete();
                                }
                                // 执行远程命令
                                execCommand(session, " cd " + remoteFolderPath + " && rm -fr see ", 60);
                                execCommand(session, " cd " + remoteFolderPath + " && unzip " + file.getName(), 60);
                                if (type.equals("lightdb")) {
                                    execCommand(session, envCommand + "&& cd " + remoteFolderPath + "/see && sh lightdb_upgrade.sh", 120);
                                } else {
                                    execCommand(session, envCommand + "&& cd " + remoteFolderPath + "/see && sh upgrade.sh", 120);

                                }
                                execCommand(session, " cd " + remoteFolderPath + " && rm -fr " + file.getName(), 60);
                                execCommand(session, " cd " + remoteFolderPath + " && rm -fr see ", 60);

                                if (type.equals("lightdb")) {
//                                    execCommand(session, envCommand + "&& cd $SEE20_INSTALL_HOME && rm -fr tomcat/.lightdb_sql_md5.properties  &&  sh lightdb_startUp.sh   ", 360);
                                    execCommand(session, envCommand + "&& cd $SEE20_INSTALL_HOME   &&  sh lightdb_startUp.sh   ", 360);
                                } else {
                                    //  execCommand(session, envCommand + "&& cd $SEE20_INSTALL_HOME && rm -fr tomcat/.sql_md5.properties  &&  sh startUp.sh  ", 360);
                                    execCommand(session, envCommand + "&& cd $SEE20_INSTALL_HOME   &&  sh startUp.sh  ", 360);
                                }
                                System.out.println("升级服务器：" + host + " 文件：" + file.getName() + "结束。。。");
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


    private static void execCommand(Session session, String command, Integer timeout) throws Exception {
        System.out.println("远程服务器执行命令：" + command + " 开始...");
        ExecutorService executorService = Executors.newSingleThreadExecutor();
        ChannelExec channelExec = (ChannelExec) session.openChannel("exec");
        channelExec.setCommand(command);
        InputStream commandOutput = channelExec.getInputStream();
        channelExec.connect();
        // 获取输入和输出流
        BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(channelExec.getOutputStream()));
        Future<?> future = executorService.submit(() -> {
            try {
                // 读取并打印命令输出
                BufferedReader reader = new BufferedReader(new InputStreamReader(commandOutput, StandardCharsets.UTF_8));
                String line;
                while ((line = reader.readLine()) != null) {
                    System.out.println(line);
                    if (line.contains("[note] check last install workspace end ......") || line.contains("The SEE2.0 main program upgrade is complete.")) {
                        writer.write("no\n");
                        writer.flush();
                    }
                    if (line.contains("is successfully started.")) {
                        System.out.println("升级SEE2.0成功...");
                        break;
                    }
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
        final double[] speed = {0};
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
                        System.out.printf("Upload progress: %.2f%% \n", progress);
                    }
                }, interval, interval);
            }

            @Override
            public boolean count(long count) {
                speed[0] = count;
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
