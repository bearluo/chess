package com.boyaa.entity.update;

/**
 * 
 * @FileName: 	 DownloadFile.java
 * @Author:   	 Jayshon.Liu
 * @Date:     	 2012.09.13
 * @Description: Download common file under protocol of standard HTTP
 * 
 */


import java.io.File;  
import java.io.FileNotFoundException;  
import java.io.FileOutputStream;  
import java.io.IOException;  
import java.io.InputStream;  
import java.io.OutputStream;  
import java.net.HttpURLConnection;  
import java.net.MalformedURLException;  
import java.net.URL;  
  
public class DownloadFile {  
    //������λ4K 
    private static final int FILESIZE = 4*1024;
    //�����൥��
    private static DownloadFile instance = null;
    //ԭʼ��Դ��λ��
    private String url_seed;
    
    
    /**
     * inner constructor
     * @param url
     */
    private DownloadFile(String url){
    	this.url_seed = url;
    }
    
    
    
    /**
     * Get Single Instance, some code like cocos2d-x...
    
     * @Title: sharedDownloadFile
    
     * @Description: TODO(������һ�仰�����������������)
    
     * @param: @return   
    
     * @return: DownloadFile   
    
     * @throws
     */
    public static DownloadFile sharedDownloadFile(String url){
    	return (null == instance ? new DownloadFile(url) : instance);
    }
    
    
    
    /**
     * ��URL�ж����������ļ���(����չ��,�� "a.png"...)
    
     * @Title: getFileName
    
     * @Description: TODO(������һ�仰�����������������)

     * @param: @return   
    
     * @return: String   
    
     * @throws
     */
	public String getFileName() {
		String url_origin = this.url_seed;
		String[] names = url_origin.split("/");  
        return names[names.length-1];
	}
    
	
	
    /**
     *  Statr download file in any type
    
     * @Title: downFile
    
     * @Description: TODO(��׼httpЭ�������ļ�,����/�����ļ���֧��)
    
     * @param: @param pStorePath	�洢·��(�����ļ���)
     * @param: @return   
    
     * @return: boolean   			�Ƿ����سɹ�
    
     * @throws
     */
    public boolean downloadFileTo(String pStorePath){
    	
    	File dirFile = new File(pStorePath);
    	if(!dirFile.exists()){
    		dirFile.mkdir();
    	}
    	
        String name = this.getFileName();
          
        OutputStream outputStream = null;  
        InputStream inputStream = null;  
        HttpURLConnection urlConnection;  
        boolean bSuccess = false;  
        URL url;  
        //�������ļ�  
        File file = new File(pStorePath + "/" + name);  
        if((file != null)&& !file.exists()){  
            try {  
                file.createNewFile();  
            } catch (IOException e) {  
                // TODO Auto-generated catch block  
                e.printStackTrace();  
            }  
            try {  
                outputStream = new FileOutputStream(file);  
            } catch (FileNotFoundException e) {  
                // TODO Auto-generated catch block  
                e.printStackTrace();  
            }  
            try {  
                url = new URL(this.url_seed);  
                urlConnection = (HttpURLConnection)url.openConnection();  
                urlConnection.setDoInput(true);  
                urlConnection.connect();  
                  
                inputStream = urlConnection.getInputStream();  
                int len =  urlConnection.getContentLength();  
                //System.out.println("file size is:"+len);  
                byte[] buffer = new byte[FILESIZE];  
                int byteRead = -1;
                
                //byte count
                int bytesCount = 0;
                
                while((byteRead=(inputStream.read(buffer)))!= -1){  
                    outputStream.write(buffer, 0, byteRead);
                    bytesCount += byteRead;
                    //System.out.println("how many bytes downloaded: "+ bytesCount + ",totalLen: " + len);
                }  
                outputStream.flush();  
                  
                  
                inputStream.close();  
                outputStream.close();  
                
                bSuccess = bytesCount >= len ? true : false;
                
                if(bSuccess){
                	//System.out.println("download file success...");
                }else{
                	//System.out.println("download file failed due to some reason...try to check the url.");
                }
                
            } catch (MalformedURLException e) {  
                // TODO Auto-generated catch block  
                e.printStackTrace();  
                bSuccess = false;  
            }catch (IOException e) {  
                // TODO Auto-generated catch block  
                e.printStackTrace();  
                bSuccess = false;
            }  
        }  
          
        return bSuccess;  
    }  
}  