package com.pptp.bean;

public class User {
	private int id;
	private String email;
	private String userName;
	private String pwd;

	public User() {
	}

	public User(int id, String email,String name, String pwd) {
		this.id = id;
		this.email = email;
		this.userName = name;
		this.pwd = pwd;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getPwd() {
		return pwd;
	}

	public void setPwd(String pwd) {
		this.pwd = pwd;
	}
}
