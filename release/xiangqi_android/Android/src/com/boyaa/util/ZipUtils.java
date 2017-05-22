package com.boyaa.util;



import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipException;
import java.util.zip.ZipFile;
import java.util.zip.ZipInputStream;

public class ZipUtils {
	private static final int BUFFER_SIZE = 4096;
	public ZipUtils() {
	}

	public static void unZipDirectory(String zipFileDirectory,
			String outputDirectory) throws ZipException, IOException {
		File file = new File(zipFileDirectory);
		File[] files = file.listFiles();
		for (int i = 0; i < files.length; i++) {
			if (files[i].getName().endsWith(".zip")) {
				unzip(zipFileDirectory + File.separator + files[i].getName(),
						outputDirectory);
			}
		}
	}

	public static void unzip(String string, String outputDirectory)
			throws ZipException, IOException {
		ZipFile zipFile = new ZipFile(string);
		Enumeration<ZipEntry> enu = (Enumeration<ZipEntry>) zipFile.entries();
		final List<ZipEntry> entries = new ArrayList<ZipEntry>();
		while (enu.hasMoreElements()) {
			ZipEntry entry = (ZipEntry) enu.nextElement();
			if (entry.getName().contains("../")) continue;
			if (entry.isDirectory()) {
				String fileName = entry.getName().substring(0,
						entry.getName().length() - 1);
				String directoryPath = outputDirectory + File.separator
						+ fileName;
				File directory = new File(directoryPath);
				directory.mkdir();
				continue;
			}
			entries.add(entry);
		}
		unzip(zipFile, entries, outputDirectory);
	}

	private static void unzip(ZipFile zipFile, List<ZipEntry> entries,
			String outputDirectory) throws IOException {
		// TODO Auto-generated method stub
		Iterator<ZipEntry> it = entries.iterator();
		while (it.hasNext()) {
			ZipEntry zipEntry = (ZipEntry) it.next();
			String entryName = zipEntry.getName();
			if (entryName.contains("../")) continue;
			BufferedInputStream bis = new BufferedInputStream(zipFile.getInputStream(zipEntry));
			byte[] data = new byte[BUFFER_SIZE];
			entryName = new String(entryName.getBytes("GBK"));
			String path = outputDirectory + File.separator + entryName;
			File file = new File(path);
			file.mkdirs();
			if( file.exists() ) {
				file.delete();
			}
			FileOutputStream fos = new FileOutputStream(path);
			if (zipEntry.isDirectory()) {

			} else {
				BufferedOutputStream bos = new BufferedOutputStream(fos,
						BUFFER_SIZE);
				int count = 0;
				while ((count = bis.read(data, 0, BUFFER_SIZE)) != -1) {
					bos.write(data, 0, count);
				}
				bos.flush();
				bos.close();
			}
		}
		deleteFile(zipFile.getName());
	}
	//读取压缩文件中的内容名称
	public static List<String> readZipFile(String file) throws Exception {  
		List<String> list = new ArrayList<String>();
        InputStream in = new BufferedInputStream(new FileInputStream(file));  
        ZipInputStream zin = new ZipInputStream(in); 
        ZipEntry ze;  
        while ((ze = zin.getNextEntry()) != null) {  
            if (ze.isDirectory()) {
            } else {  
            	String zeName = new String(ze.getName().getBytes("iso-8859-1"),"utf-8");
            	list.add(zeName);
            }  
        }  
        zin.closeEntry();
		return list;  
    }  
	//删除文件
	private static void deleteFile(String Path) {
		// TODO Auto-generated method stub
		File file = new File(Path);  
	    // 路径为文件且不为空则进行删除  
	    if (file.isFile() && file.exists()) {  
	        file.delete();  
	    }  
	}
}
