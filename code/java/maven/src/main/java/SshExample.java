//import com.jcraft.jsch.*;
//
//public class SshExample {
//    public static void main(String[] args) {
//        String host = "your_remote_host";
//        String username = "your_username";
//        String password = "your_password";
//
//        JSch jsch = new JSch();
//        Session session = null;
//
//        try {
//            session = jsch.getSession(username, host, 22);
//            session.setPassword(password);
//            session.setConfig("StrictHostKeyChecking", "no");
//            session.connect();
//
//            // Upload a file to the remote server
//            ChannelSftp channelSftp = (ChannelSftp) session.openChannel("sftp");
//            channelSftp.connect();
//            String localFilePath = "local_path/to/your/file.txt";
//            String remoteFilePath = "remote_path/file.txt";
//            channelSftp.put(localFilePath, remoteFilePath);
//            channelSftp.disconnect();
//
//            // Unzip the uploaded file
//            ChannelExec channelExec = (ChannelExec) session.openChannel("exec");
//            String unzipCommand = "unzip " + remoteFilePath + " -d remote_path/";
//            channelExec.setCommand(unzipCommand);
//            channelExec.connect();
//            channelExec.disconnect();
//
//            // Execute a shell script
//            String scriptCommand = "sh remote_path/your_script.sh";
//            channelExec.setCommand(scriptCommand);
//            channelExec.connect();
//            channelExec.disconnect();
//        } catch (JSchException | SftpException e) {
//            e.printStackTrace();
//        } finally {
//            if (session != null && session.isConnected()) {
//                session.disconnect();
//            }
//        }
//    }
//}
