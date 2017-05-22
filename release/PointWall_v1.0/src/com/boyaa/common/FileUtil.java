package com.boyaa.common;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import android.text.TextUtils;

public class FileUtil {

	/** 删除一个文件 */
	public static void deleteFile(String filePath) {
		if (TextUtils.isEmpty(filePath)) return;

		File file = new File(filePath);
		if (file != null && file.exists() && file.isFile()) {
			file.delete();
		}
	}

	/** 判断是否存在一个文件 */
	public static boolean existFile(String filePath) {
		if (filePath==null) {
			return false;
		}
		File file = new File(filePath);
		if (file.exists() && file.isFile()) {
			return true;
		}
		return false;
	}

	/** 如果不存在此目录便生成此目录 */
	public static void createDirectoryIfNotExist(String directoryPath) {
		File file = new File(directoryPath);
		if (!file.exists() || !file.isDirectory()) {
			file.mkdirs();
		}
	}
	
	public static void createFileIfNotExist(String filePath) throws IOException {
		File file = new File(filePath);
		if (!file.exists() || !file.isFile()) {
			file.createNewFile();
		}
	}

	public static void copyFile(String sourceFilePath, String targetFilePath) throws IOException {
        BufferedInputStream inBuff = null;
        BufferedOutputStream outBuff = null;
        try {
            inBuff = new BufferedInputStream(new FileInputStream(sourceFilePath));
            outBuff = new BufferedOutputStream(new FileOutputStream(targetFilePath));

            byte[] b = new byte[1024 * 5];
            int len;
            while ((len = inBuff.read(b)) != -1) {
                outBuff.write(b, 0, len);
            }
            outBuff.flush();
        } finally {
            if (inBuff != null)
                inBuff.close();
            if (outBuff != null)
                outBuff.close();
        }
    }

	public static void copyFile(File sourceFile, File targetFile) throws IOException {
        BufferedInputStream inBuff = null;
        BufferedOutputStream outBuff = null;
        try {
            inBuff = new BufferedInputStream(new FileInputStream(sourceFile));
            outBuff = new BufferedOutputStream(new FileOutputStream(targetFile));

            byte[] b = new byte[1024 * 5];
            int len;
            while ((len = inBuff.read(b)) != -1) {
                outBuff.write(b, 0, len);
            }
            outBuff.flush();
        } finally {
            if (inBuff != null)
                inBuff.close();
            if (outBuff != null)
                outBuff.close();
        }
    }
}
