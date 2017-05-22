package com.boyaa.snslogin;

public class UserInfo {
	private String openid;
	private String accessToken;
	private String expiresIn;
	private String nickname;
	private String gender;
	private String avatarLarge;
	
	public String getAvatarLarge() {
		return avatarLarge;
	}

	public void setAvatarLarge(String avatarLarge) {
		this.avatarLarge = avatarLarge;
	}

	public String getNickname() {
		return nickname;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	public String getGender() {
		return gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}

	public String getOpenid() {
		return openid;
	}
	
	public void setOpenid(String openid) {
		this.openid = openid;
	}
	
	public String getAccessToken() {
		return accessToken;
	}
	
	public void setAccessToken(String accessToken) {
		this.accessToken = accessToken;
	}
	
	public String getExpiresIn() {
		return expiresIn;
	}
	
	public void setExpiresIn(String expiresIn) {
		this.expiresIn = expiresIn;
	}

}
