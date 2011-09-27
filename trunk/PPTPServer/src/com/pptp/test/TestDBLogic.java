package com.pptp.test;

import com.pptp.bean.User;
import com.pptp.server.DBLogic;

public class TestDBLogic {
	public static void main(String[] args) {
		test3();
		test2();
		test1();
	}

	private static void test3() {
		String clientID = DBLogic.getClientID("yedawei@gmail.com",
				"device-xxxx-xxxx");
		System.out.println("clientID : " + clientID);
		String orderID = DBLogic.createOrder(clientID, 1);
		System.out.println("orderID : " + orderID);
		User user = DBLogic.completeOrder(clientID, orderID);
		System.out.println("complete Order : " + (user != null));
	}

	private static void test2() {
		String clientID = DBLogic.getClientID("yedawei@gmail.com",
				"device-xxxx-xxxx");
		System.out.println("clientID : " + clientID);
		String orderID = DBLogic.createOrder(clientID+"?", 1);
		System.out.println("orderID : " + orderID);
		User user = DBLogic.completeOrder(clientID, orderID);
		System.out.println("complete Order : " + (user != null));
	}

	private static void test1() {
		String clientID = DBLogic.getClientID("yedawei@gmail.com",
				"device-xxxx-xxxx");
		System.out.println("clientID : " + clientID);
		String orderID = DBLogic.createOrder(clientID, 1);
		System.out.println("orderID : " + orderID);
		User user = DBLogic.completeOrder(clientID, orderID);
		System.out.println("complete Order : " + (user != null));
	}

}
