package com.boyaa.data;

public class UserInfo {

		private String uid;
		private String nick;
		private String email;
		private String password;
		private static UserInfo s_instance;
		private boolean isLogin = false;
		
		private UserInfo(){
			
		}
		public static UserInfo getInstance(){
			if(s_instance == null){
				s_instance = new UserInfo();
			}
			
			return s_instance;

		}
		public String getUid() {
			return uid;
		}
		public void setUid(String uid) {
			this.uid = uid;
		}
		public String getNick() {
			return nick;
		}
		public void setNick(String nick) {
			this.nick = nick;
		}
		public String getPassword() {
			return password;
		}
		public void setPassword(String password) {
			this.password = password;
		}
		public String getEmail() {
			return email;
		}
		public void setEmail(String email) {
			this.email = email;
		}
		public boolean isLogin() {
			return isLogin;
		}
		public void setLogin(boolean isLogin) {
			this.isLogin = isLogin;
		}
}
