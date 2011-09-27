package com.pptp.client;

import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

import com.pptp.server.AES;
import com.pptp.share.StreamPrinter;
import com.pptp.share.StreamReader;

public class ClientMain {
	protected static final String ENC_KEY = "0721132001892044";// oldkey

	private byte[] confirmOrder(String clientID, String orderID,
			String receiptData) throws IOException {
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		StreamPrinter printer = new StreamPrinter(stream);
		printer.printString("confirmOrder");
		printer.printString(clientID);
		printer.printString(orderID);
		printer.printString(receiptData);
		return stream.toByteArray();
	}

	private byte[] getOrderID(String clientID, int orderType)
			throws IOException {
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		StreamPrinter printer = new StreamPrinter(stream);
		printer.printString("createOrder");
		printer.printString(clientID);
		printer.printInt(orderType);
		return stream.toByteArray();
	}

	private byte[] getClientID(String email, String device) throws IOException {
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		StreamPrinter printer = new StreamPrinter(stream);
		printer.printString("getClientID");
		printer.printString(email);
		printer.printString(device);
		return stream.toByteArray();
	}

	private StreamReader rpc(byte[] data) throws IOException {
		URL url = new URL("http://localhost:8080/PPTPServer/Client");
		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setDoOutput(true);
		conn.setRequestMethod("POST");
		StreamPrinter printer = new StreamPrinter(conn.getOutputStream());
		// printer.printInt(data.length);

		printer.printInt(100);
		byte[] encData = AES.encrypt(data, ENC_KEY);
		printer.printData(encData);

		printer.printData(data);
		printer.flush();
		printer.close();
		conn.getResponseCode();
		StreamReader reader = new StreamReader(new BufferedInputStream(
				conn.getInputStream()));
		byte[] encOutData = reader.readData();
		byte[] outData = AES.decrypt(encOutData, ENC_KEY);
		reader = new StreamReader(new ByteArrayInputStream(outData));
		if (reader.readInt() == 1) {
			return reader;
		}
		System.out.println("error : " + reader.readString());
		reader.close();
		return null;
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		ClientMain client = new ClientMain();
		try {
			StreamReader reader = client.rpc(client.getClientID(
					"yedawei002@snaplore.com", "device-007-001"));
			String clientID = reader.readString();
			System.out.println("clientID : " + clientID);
			reader.close();
			reader = client.rpc(client.getOrderID(clientID, 1));
			String orderID = reader.readString();
			System.out.println("orderID : " + orderID);
			reader.close();

			reader = client.rpc(client.confirmOrder(clientID, orderID,
					"date-->001002003"));
			String userName = reader.readString();
			String pwd = reader.readString();
			System.out.println("user : " + userName);
			System.out.println("pwd : " + pwd);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

}
