package com.pptp.server;

import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Random;

import com.pptp.bean.Order;
import com.pptp.bean.User;

public class DBLogic {
	private final static SimpleDateFormat FORMATTER = new SimpleDateFormat(
			"yyyy-MM-dd HH:mm:ss");

	private final static SimpleDateFormat ORDER_FORMAT = new SimpleDateFormat(
			"yyyyMMddHHmm");

	private final static Random RAND = new Random();

	private static int nextInt(int max) {
		return Math.abs(RAND.nextInt()) % max;
	}

	private static String generateName() {
		int first = nextInt(9) + 1;
		int secont = nextInt(1000);
		int third = nextInt(1000);
		StringBuilder builder = new StringBuilder();
		builder.append(trim(first, 1));
		builder.append(trim(secont, 2));
		builder.append(trim(third, 2));
		return builder.toString();
	}

	private static String generatePassword() {
		int first = nextInt(900) + 100;
		int secont = nextInt(10000);
		int third = nextInt(1000);
		StringBuilder builder = new StringBuilder();
		builder.append(trim(first, 3));
		builder.append(trim(secont, 3));
		builder.append(trim(third, 2));
		return builder.toString();
	}

	/**
	 * 注册加登录
	 * 
	 * @param email
	 * @param device
	 * @return
	 */
	public static String getClientID(String email, String device) {
		Connection conn = DBAccess.getConn();
		User user = DBAccess.getUser(conn, email);
		String date = FORMATTER.format(new Date());
		String name = generateName();
		String pwd = generatePassword();
		if (user == null) {
			int count = 1;
			while (DBAccess.hasUser(conn, name)) {
				name = generateName();
				count++;
			}
			System.out.println("generate name times : " + count);
			user = DBAccess.addUser(conn, email, name, pwd, device, date);
			if (user == null) {
				return null;
			}
		}
		String clientID = ClientID.generateClientID().toString();
		boolean b = DBAccess.addLoginStatus(conn, user, clientID, device, date);
		DBAccess.close(conn);
		if (b) {
			return clientID;
		}
		return null;
	}

	private static String trim(int value, int len) {
		String num = String.valueOf(value);
		if (num.length() > len) {
			return num;
		}
		int delta = len - num.length();
		StringBuilder builder = new StringBuilder();
		for (int i = 0; i < delta; i++) {
			builder.append(0);
		}
		builder.append(value);
		return builder.toString();
	}

	public static String createOrder(String clientID, int type) {
		Connection conn = DBAccess.getConn();
		User user = DBAccess.getUserFromClientID(conn, clientID);
		String orderID = null;
		boolean b = false;
		if (user != null) {
			Date d = new Date();
			String date = FORMATTER.format(d);
			String orderDate = ORDER_FORMAT.format(d);
			orderID = orderDate + trim(user.getId(), 3) + trim(type, 1)
					+ trim(Math.abs(RAND.nextInt() % 100), 2);
			Order order = new Order(0, orderID, type, user.getId(), date, null);
			b = DBAccess.addNewOrder(conn, order);
		}
		DBAccess.close(conn);
		if (b) {
			return orderID;
		}
		return null;
	}

	public static User completeOrder(String clientID, String orderID) {
		Connection conn = DBAccess.getConn();
		boolean b = false;
		User user = null;
		try {
			conn.setAutoCommit(false);
			user = DBAccess.getUserFromClientID(conn, clientID);
			if (user != null) {
				Order order = DBAccess.getNewOrder(conn, orderID);
				if (order != null) {
					String completeTime = FORMATTER.format(new Date());
					order.setCompleteTime(completeTime);
					if (DBAccess.removeNewOrder(conn, orderID)) {
						b = DBAccess.addCompleteOrder(conn, order);
					}
				}
			}
			// update radius
			if (b) {
				if (!RadiusAccess.hasUser(conn, user.getUserName())) {
					b = RadiusAccess.addUser(conn, user.getUserName(),
							user.getPwd());
					if (b) {
						b = RadiusAccess.setGroup(conn, user.getUserName());
					}
				}
			}
			conn.commit();
			if (b) {
				return user;
			}
		} catch (SQLException e) {
			try {
				conn.rollback();
			} catch (SQLException e1) {
			}
		} finally{
			try {
				conn.setAutoCommit(true);
			} catch (SQLException e) {
			}
			DBAccess.close(conn);
		}
		return null;
	}

}
