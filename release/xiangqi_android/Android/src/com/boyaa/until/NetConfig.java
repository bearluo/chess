package com.boyaa.until;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONException;
import org.json.JSONObject;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import org.xmlpull.v1.XmlSerializer;

import com.boyaa.chinesechess.platform91.Game;

import android.content.Context;
import android.util.Log;
import android.util.Xml;

public class NetConfig {
	private float ver ;
	private  ArrayList<String> CDNList;
	private  ArrayList<WebConfig> WebList;
	private  ArrayList<String> ConfigList;
	private  ArrayList<String> ReportList;
	private static String version  = "version";
	private static String CDN = "CDN";
	private static String CDN1 = "CDN1";
	private static String Web  = "Web";
	private static String WebUrl  = "WebUrl";
	private static String Report  = "Report";
	private static String Report1 = "Report1";
	private static String Config  = "Config";
	private static String ConfigFile  = "ConfigFile";
	private static String status  = "status";
	private static String host  = "host";
	private static String NetConfig  = "NetConfig";
	private static String num  = "num";
	public static int netstatus  = 0;
	
	private  int cndnum  = 0;
	private  int webnum  = 0;
	private  int confignum  = 0;
	private  int reportnum  = 0;
	
	public int getCndnum() {
		return cndnum;
	}

	public void setCndnum(int cndnum) {
		this.cndnum = cndnum;
	}

	public int getWebnum() {
		return webnum;
	}

	public void setWebnum(int webnum) {
		this.webnum = webnum;
	}

	public int getConfignum() {
		return confignum;
	}

	public void setConfignum(int confignum) {
		this.confignum = confignum;
	}

	public int getReportnum() {
		return reportnum;
	}

	public void setReportnum(int reportnum) {
		this.reportnum = reportnum;
	}
	
	public NetConfig()
	{
		CDNList = new ArrayList<String>();
		WebList = new ArrayList<WebConfig>();
		ConfigList = new ArrayList<String>();
		ReportList = new ArrayList<String>();
	}
	
	public float getVer() {
		return ver;
	}

	public void setVer(float ver) {
		this.ver = ver;
	}
	
	public void addCDNList(String cdn){
		CDNList.add(cdn);
	}
	
	public String getCDNList(int index){
		return CDNList.get(index);
	}
	
	public int getCDNListLen(){
		return CDNList.size();
	}
	
	public void addWebList(String webStr,int status){
		WebConfig web = new WebConfig(webStr, status);
		WebList.add(web);
	}
	
	public void addWebList(WebConfig web){
		WebList.add(web);
	}
	
	public WebConfig getWebList(int index){
		return WebList.get(index);
	}
	
	public int getWebListLen(){
		return WebList.size();
	}
	
	public void addConfigList(String config){
		ConfigList.add(config);
	}
	
	public String getConfigList(int index){
		return ConfigList.get(index);
	}
	
	public int getConfigListLen(){
		return ConfigList.size();
	}
	
	
	public void addReportList(String report){
		ReportList.add(report);
	}
	
	public String getReportList(int index){
		return ReportList.get(index);
	}
	
	public int getReportListLen(){
		return ReportList.size();
	}
	
	public static NetConfig getNetConfigs(InputStream inputStream){
		DocumentBuilderFactory factory = null;
		DocumentBuilder builder = null;
		Document document = null;
		NodeList nodes = null;
		NetConfig netConfig = null;
		netConfig = new NetConfig();
	    NodeList childnodes = null;

		factory=DocumentBuilderFactory.newInstance();
		try{
			builder=factory.newDocumentBuilder();            
			document=builder.parse(inputStream);

			Element root=document.getDocumentElement();
		
			String verStr = root.getAttribute(version);
			netConfig.ver = Float.parseFloat(verStr);			

			nodes=root.getElementsByTagName(CDN);			
			
	        for (int i = 0; i < nodes.getLength(); i++) {
	            Element CNDElement=(Element)(nodes.item(i));
	            String tag =  CNDElement.getTagName();
	            int n = Integer.parseInt(CNDElement.getAttribute(num));

	            netConfig.setCndnum(n);
	            childnodes=CNDElement.getElementsByTagName(CDN1);
	            
		        for (int k = 0; k < childnodes.getLength(); k++) {
		        	Element cnd= (Element)(childnodes.item(k));
		            String cndurl = cnd.getAttribute(host);
		            netConfig.addCDNList(cndurl);
		        }
			}
	        
			nodes=root.getElementsByTagName(Web);			
	        for (int i = 0; i < nodes.getLength(); i++) {
	            Element WebElement=(Element)(nodes.item(i));
	            String tag =  WebElement.getTagName();
	            int n = Integer.parseInt(WebElement.getAttribute(num));

	            netConfig.setWebnum(n);
	            childnodes=WebElement.getElementsByTagName(WebUrl);
	            
		        for (int k = 0; k < childnodes.getLength(); k++) {
		        	Element web= (Element)(childnodes.item(k));
		            String weburl = web.getAttribute(host);
		            String statusStr = web.getAttribute(status);
		            int s = Integer.parseInt(statusStr);

		            netConfig.addWebList(weburl,s);
		        }
			}
	        
			nodes=root.getElementsByTagName(Config);
			
	        for (int i = 0; i < nodes.getLength(); i++) {
	            Element ConfigElement=(Element)(nodes.item(i));
	            String tag =  ConfigElement.getTagName();
	            int n = Integer.parseInt(ConfigElement.getAttribute(num));
	            
	            netConfig.setConfignum(n);
	            childnodes=ConfigElement.getElementsByTagName(ConfigFile);

	            
		        for (int k = 0; k < childnodes.getLength(); k++) {
		        	Element config= (Element)(childnodes.item(k));
		            String configurl = config.getAttribute(host);
		            netConfig.addConfigList(configurl);
		        }
			}
	        
			nodes=root.getElementsByTagName(Report);
			
	        for (int i = 0; i < nodes.getLength(); i++) {
	            Element ReportElement=(Element)(nodes.item(i));
	            String tag =  ReportElement.getTagName();
	            int n = Integer.parseInt(ReportElement.getAttribute(num));

	            netConfig.setReportnum(n);
	            childnodes=ReportElement.getElementsByTagName(Report1);
		        for (int k = 0; k < childnodes.getLength(); k++) {
		        	Element report= (Element)(childnodes.item(k));
		            String reporturl = report.getAttribute(host);
		            netConfig.addReportList(reporturl);
		        }
			}

		}catch (IOException e){ 
			e.printStackTrace();        
		} catch (SAXException e) {     
			e.printStackTrace();        
		}catch (ParserConfigurationException e) {     
			e.printStackTrace();        
		}
		
		return netConfig;
	}
	
	public static String toNetConfigJosonArr(NetConfig netConfig){
		if(netConfig!=null){
			JSONObject object = new JSONObject();
	
			StringBuilder cndStrSB = new StringBuilder();
			StringBuilder webStrSB = new StringBuilder();
			StringBuilder configStrSB = new StringBuilder();
			StringBuilder reportStrSB = new StringBuilder();

			
			int cndlen = netConfig.getCDNListLen();
			for (int i = 0; i < cndlen; i++) {
				if(i!=0){
					cndStrSB.append("-");
				}
				cndStrSB.append(netConfig.getCDNList(i));
			}
			
			int weblen = netConfig.getWebListLen();
			for (int i = 0; i < weblen; i++) {
				if(i!=0){
					webStrSB.append("-");
				}
				webStrSB.append(netConfig.getWebList(i).getHost());
			}
			
			int configlen = netConfig.getConfigListLen();
			for (int i = 0; i < configlen; i++) {
				if(i!=0){
					configStrSB.append("-");
				}
				configStrSB.append(netConfig.getConfigList(i));
			}
			
			
			
			int reportlen = netConfig.getReportListLen();
			for (int i = 0; i < reportlen; i++) {
				if(i!=0){
					reportStrSB.append("-");
				}
				reportStrSB.append(netConfig.getReportList(i));
			}
			
			try {
				object.put("cnd", cndStrSB.toString());
				object.put("web", webStrSB.toString());
				object.put("config", configStrSB.toString());
				object.put("report", reportStrSB.toString());
				
		   		int status = 0;
	    		if(Util.isNetworkConnected(Game.mActivity)){
	    			status = 1;
	    		}
	    		netConfig.netstatus = status;
				object.put("netstatus", netConfig.netstatus);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			return object.toString();
		}
		
		return null;

	}
	
    /**
     * 保存数据到xml文件中
     * @param persons
     * @param out
     * @throws Exception
     */
    public static void saveNetConfigtoXml(NetConfig netConfig,Context ctx) throws Exception {    
//    	String filepath = Environment.getExternalStorageDirectory() + "/"+"netconfig.xml";
//    	File file = new File(filepath);
//    	OutputStream out = new FileOutputStream(file);

		FileOutputStream out=ctx.openFileOutput("netconfig.xml",Context.MODE_PRIVATE);
		
        XmlSerializer serializer = Xml.newSerializer();
        serializer.setOutput(out, "UTF-8");
        serializer.startDocument("UTF-8", true);
        serializer.startTag(null, NetConfig);    
        serializer.attribute(null, version, String.valueOf(netConfig.getVer()));       
        
        serializer.startTag(null, CDN);            
        serializer.attribute(null, "num", String.valueOf(netConfig.getCndnum()));  
        int cndlen = netConfig.getCDNListLen();
        for (int i = 0; i < cndlen; i++) {
        	String url = netConfig.getCDNList(i);
            serializer.startTag(null, CDN1);            
            serializer.attribute(null, host, url);  
            serializer.endTag(null, CDN1);    
		}   
        serializer.endTag(null, CDN);     
             
        serializer.startTag(null, Web);            
        serializer.attribute(null, "num", String.valueOf(netConfig.getWebnum()));  
        int weblen = netConfig.getWebListLen();
        for (int i = 0; i < weblen; i++) {
        	WebConfig webFile = netConfig.getWebList(i);
            serializer.startTag(null, WebUrl);            
            serializer.attribute(null, host, webFile.getHost());  
            serializer.attribute(null, status, String.valueOf(webFile.getStatus()));  
            serializer.endTag(null, WebUrl);    
		}   
        serializer.endTag(null, Web);     
        
        serializer.startTag(null, Config);            
        serializer.attribute(null, "num", String.valueOf(netConfig.getConfignum()));  
        int configlen = netConfig.getConfigListLen();
        for (int i = 0; i < configlen; i++) {
        	String configFile = netConfig.getConfigList(i);
            serializer.startTag(null, ConfigFile);   		
            serializer.attribute(null, host, configFile);  
            serializer.endTag(null, ConfigFile);    
		}   
        serializer.endTag(null, Config); 
        
        serializer.startTag(null, Report);            
        serializer.attribute(null, "num", String.valueOf(netConfig.getReportnum()));  
        int reportlen = netConfig.getReportListLen();
        for (int i = 0; i < reportlen; i++) {
        	String url = netConfig.getReportList(i);
            serializer.startTag(null, Report1);            
            serializer.attribute(null, host, url);  
            serializer.endTag(null, Report1);    
		}   
        serializer.endTag(null, Report); 
        serializer.endTag(null, NetConfig);
        serializer.endDocument();

      
        OutputStreamWriter osw = new OutputStreamWriter(out);  		
        osw.close();
        out.flush();
        out.close();   		  
        
//    	Game.dict_set_double("chinesechess_cache_data", "net_config_version"+bid, netConfig.getVer());
    }
    
	
	public static InputStream httpGet(String url){
		HttpClient client = new DefaultHttpClient();
		HttpGet  httpGet = new HttpGet(url);
		
		HttpResponse res;
		try {
			res = client.execute(httpGet);
			if(res.getStatusLine().getStatusCode() == HttpStatus.SC_OK){            
				HttpEntity entity = res.getEntity();  
				return entity.getContent();
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}  
		
		return null;
		
	}	
	
	
    public static boolean writeToXml(Context context,String str){    
    	try {            
//	    	String filepath = Environment.getExternalStorageDirectory() + "/"+"netconfig.xml";
//	    	File file = new File(filepath);
//	    	OutputStream out = new FileOutputStream(file);
    		FileOutputStream out=context.openFileOutput("netconfig.xml",Context.MODE_PRIVATE);
	    	
	    	
    		OutputStreamWriter outw=new OutputStreamWriter(out); 
    		try {                
    			outw.write(str);                
    			outw.close();                
    			out.close();                
    			return true;            
    		} catch (IOException e) {               
    			return false;            
    		}       
    	} catch (FileNotFoundException e) {           
    		return false;        
    	}    
    }

    public static String readLocalNetconfigStr(Context context){    
    	try {   	
    		FileInputStream in= context.openFileInput("netconfig.xml"); //获得输入流

    		NetConfig config = getNetConfigs(in);
    		return toNetConfigJosonArr(config);
    	} catch (FileNotFoundException e) {           
    		e.printStackTrace();      
    	}    
    	
    	return null;
    }
    
    public synchronized static NetConfig readLocalNetconfig(Context context){    
    	try {   
    		
    		FileInputStream in= context.openFileInput("netconfig.xml"); //获得输入流
    		NetConfig config = getNetConfigs(in);
    		
    		return config;
    	} catch (FileNotFoundException e) {           
    		e.printStackTrace();      
    	}    	
    	return null;
    }
    
    public static NetConfig readNetNetconfig(Context context,String url){    
		NetConfig config =null;
    	try{
    		InputStream input = httpGet(url);
    		config = getNetConfigs(input);
    	}catch (Exception e) {
			e.printStackTrace();
		}
		return config; 
    }

    
//    	Log.i("===writeNetNetconfig======", "writeNetNetconfig");
    public static void writeNetNetconfig(Context context){
    	
    	try {
			FileInputStream in= context.openFileInput("netconfig.xml"); //获得输入流
		} catch (Exception e) {
//			Log.i("=====FileInputStream=====", "Exception");
			
	    	try {
				InputStream assetIn = context.getResources().getAssets().open("netconfig.xml");
	    		NetConfig netConfig = getNetConfigs(assetIn);

	    		try {
					saveNetConfigtoXml(netConfig,context);
				} catch (Exception e1) {
					e1.printStackTrace();
				}
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
    }
    
    public class WebConfig {
    	public WebConfig(String host,int status) {
			this.host = host;
			this.status = status;
		}
    	
    	public String getHost() {
			return host;
		}
		public void setHost(String host) {
			this.host = host;
		}
		public int getStatus() {
			return status;
		}
		public void setStatus(int status) {
			this.status = status;
		}
		private String host;
    	private int status;
    }
	
}
