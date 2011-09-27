package com.pptp.server;

import java.io.IOException;

import com.pptp.bean.User;
import com.pptp.share.StreamPrinter;
import com.pptp.share.StreamReader;

public class ActionExecutorImpl implements ActionExecutor {

	private static void printSuccess(StreamPrinter printer) {
		try {
			printer.printInt(1);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private static void printFail(StreamPrinter printer) {
		try {
			printer.printInt(0);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void getClientID(StreamReader reader, StreamPrinter printer) {
		try {
			String email = reader.readString();
			String deviceID = reader.readString();
			String clientID = DBLogic.getClientID(email, deviceID);
			if (validateEmail(email)) {
				printSuccess(printer);
				printer.printString(clientID);
				return;
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		printFail(printer);
	}

	private boolean validateEmail(String email) {
		// @ TODO
		return true;
	}

	// input : email, output :
	public void createOrder(StreamReader reader, StreamPrinter printer) {
		try {
			String clientID = reader.readString();
			int orderType = reader.readInt();
			String orderID = DBLogic.createOrder(clientID, orderType);
			printSuccess(printer);
			printer.printString(orderID);
			return;
		} catch (Exception e) {
			e.printStackTrace();
		}
		printFail(printer);
	}

	private boolean confirmOrder(String receiptData) {
		// @ TODO
		System.out.println("receiptData : " + receiptData);
		return true;
	}

	public void confirmOrder(StreamReader reader, StreamPrinter printer) {
		try {
			String clientID = reader.readString();
			String orderID = reader.readString();
			String receiptData = reader.readString();
			if (confirmOrder(receiptData)) {
				User user = DBLogic.completeOrder(clientID, orderID);
				if (user != null) {
					printSuccess(printer);
					printer.printString(user.getUserName());
					printer.printString(user.getPwd());
					printer.flush();
					return;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		printFail(printer);
		try {
			printer.printString("get order failed");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void getInvitationCode(StreamReader reader, StreamPrinter printer) {
		try {
			String clientID = reader.readString();

		} catch (Exception e) {
			e.printStackTrace();
		}
		printFail(printer);
	}

	public void useInvitationCode(StreamReader reader, StreamPrinter printer) {
		try {
			String clientID = reader.readString();
			String invitationCode = reader.readString();
		} catch (Exception e) {
			e.printStackTrace();
		}
		printFail(printer);
	}

	public void getPurchaseList(StreamReader reader, StreamPrinter printer) {
		try {
			String clientID = reader.readString();
		} catch (Exception e) {
			e.printStackTrace();
		}
		printFail(printer);
	}

}
