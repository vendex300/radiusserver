package com.pptp.bean;

public class InviteCode {
	private int createUser;
	private String code;
	private int useUser;

	public InviteCode() {
	}

	public InviteCode(int createUser, String code, int useUserID) {
		this.createUser = createUser;
		this.code = code;
		this.useUser = useUserID;
	}

	public int getCreateUser() {
		return createUser;
	}

	public void setCreateUser(int createUser) {
		this.createUser = createUser;
	}

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public int getUseUser() {
		return useUser;
	}

	public void setUseUser(int useUser) {
		this.useUser = useUser;
	}
}
