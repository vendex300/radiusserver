package com.pptp.bean;

public class Order {
	private int id;
	private String orderID;
	private int orderType;
	private String createTime;
	private String completeTime;
	private int userID;

	public Order() {
	}

	public Order(int id, String orderID, int orderType, int userID,
			String createTime, String completeTime) {
		this.id = id;
		this.orderID = orderID;
		this.orderType = orderType;
		this.createTime = createTime;
		this.completeTime = completeTime;
		this.userID = userID;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getOrderID() {
		return orderID;
	}

	public void setOrderID(String orderID) {
		this.orderID = orderID;
	}

	public int getOrderType() {
		return orderType;
	}

	public void setOrderType(int orderType) {
		this.orderType = orderType;
	}

	public String getCreateTime() {
		return createTime;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	public String getCompleteTime() {
		return completeTime;
	}

	public void setCompleteTime(String completeTime) {
		this.completeTime = completeTime;
	}

	public int getUserID() {
		return userID;
	}

	public void setUserID(int userID) {
		this.userID = userID;
	}
}
