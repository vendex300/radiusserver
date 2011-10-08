package com.pptp.server;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class AES {
	private static final String ENC_KEY = "0721132001892044";// oldkey

	public static byte[] encrypt(byte[] input, String key) {
		byte[] raw = key.getBytes();
		SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
		Cipher cipher;
		try {
			cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
			IvParameterSpec iv = new IvParameterSpec(
					"1234567890123456".getBytes());// 使用CBC模式，需要一个向量iv，可增加加密算法的强度
			cipher.init(Cipher.ENCRYPT_MODE, skeySpec, iv);
			byte[] encrypted = cipher.doFinal(input);
			return encrypted;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public static byte[] decrypt(byte[] sSrc, String sKey) {
		try {
			byte[] raw = sKey.getBytes("ASCII");
			SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
			Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
			IvParameterSpec iv = new IvParameterSpec(
					"1234567890123456".getBytes());
			cipher.init(Cipher.DECRYPT_MODE, skeySpec, iv);
			try {
				return cipher.doFinal(sSrc);
			} catch (Exception e) {
				e.printStackTrace();
				return null;
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			return null;
		}
	}

	private static String byte2hex(byte[] b) {
		String stmp = "";
		StringBuilder builder = new StringBuilder();
		for (int n = 0; n < b.length; n++) {
			stmp = (java.lang.Integer.toHexString(b[n] & 0XFF));
			if (stmp.length() == 1) {
				builder.append('0');
			}
			builder.append(stmp);
		}
		return builder.toString();
	}

	public static void main(String[] args) throws Exception {
		int times = 1000;
		long start = System.currentTimeMillis();
		for (int i = 0; i < times; i++) {
			String input = ClientID.generateClientID().toString();
			byte[] enc = encrypt(input.getBytes(), ENC_KEY.substring(32));
			byte[] dec = decrypt(enc, ENC_KEY.substring(32));
			System.out.println(input);
			System.out.println(byte2hex(enc));
			System.out.println(new String(dec));
			System.out.println();
		}
		System.out.println("time : " + (System.currentTimeMillis() - start));
	}

}
