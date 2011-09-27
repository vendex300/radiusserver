package com.pptp.server;

import java.math.BigInteger;
import java.util.UUID;

public class ClientID {
	private static final String KEY = "aksdkkl1023EKIR!K';==1,,,~`];asdklsjdfdsadfsaf";

	private UUID uuid;

	private ClientID() {
		uuid = UUID.randomUUID();
	}

	private ClientID(UUID uuid) {
		this.uuid = uuid;
	}

	public boolean equals(Object object) {
		if (object == null) {
			return false;
		}
		if (object instanceof ClientID) {
			return uuid.equals(((ClientID) object).uuid);
		}
		return false;
	}

	public static ClientID generateClientID() {
		return new ClientID();
	}

	/**
	 * 把clientID解析出uuid
	 * 
	 * @param clientID
	 * @return
	 */
	public static ClientID fromString(String clientID) {
		if (clientID == null || clientID.length() != 35) {
			return null;
		}
		String hString = clientID.substring(0, 14);
		long high = parserLong(replace(hString), 35);
		String lString = clientID.substring(14, 27);
		long low = parserLong('-' + replace(lString), 35);
		String oldmd5 = clientID.substring(27);
		byte[] outMD5 = parserByteArray(replace(oldmd5), 35, 4);
		UUID u = new UUID(high, low);
		byte[] md5 = getMD5((u.toString() + KEY).getBytes());
		byte[] shortMD5 = shortByteArray(shortByteArray(md5));
		if (compareByteArray(shortMD5, outMD5)) {
			return new ClientID(u);
		} else {
		}
		return null;
	}

	/**
	 * 把uuid生成clientID
	 */
	public String toString() {
		byte[] md5 = getMD5((uuid.toString() + KEY).getBytes());
		byte[] shortMD5 = shortByteArray(shortByteArray(md5));
		return merge(uuid, shortMD5);
	}

	/**
	 * 如果input首个不为0的字符是'z'就把'z'换成'-'，否则把前面的0都去掉
	 * 
	 * @param input
	 * @return
	 */
	private static String replace(String input) {
		int index = 0;
		int len = input.length();
		char[] data = input.toCharArray();
		while (index < len && data[index] == '0') {
			index++;
		}
		if (index < len - 1) {
			if (data[index] == 'z') {
				return '-' + input.substring(index + 1);
			}
		}
		return input.substring(index);
	}

	/**
	 * 把input解析成radix进制的数，转成long
	 * 
	 * @param input
	 * @param radix
	 * @return
	 */
	private static long parserLong(String input, int radix) {
		BigInteger bi = new BigInteger(input, radix);
		return bi.longValue();
	}

	/**
	 * 解析成缩短过的md5数组：把字符串当成radix进制的数解析，解析成byte数组，如果长度不够len，根据正负用0或0xff补齐
	 * 
	 * @param input
	 * @param radix
	 * @param len
	 * @return
	 */
	private static byte[] parserByteArray(String input, int radix, int len) {
		BigInteger bi = new BigInteger(input, radix);
		byte[] temp = bi.toByteArray();
		if (temp.length == len) {
			return temp;
		} else {
			byte[] result = new byte[len];
			System.arraycopy(temp, 0, result, len - temp.length, temp.length);
			if (input.charAt(0) == '-') {
				for (int i = 0; i < len - temp.length; i++) {
					result[i] = (byte) 0xff;
				}
			} else {
				for (int i = 0; i < len - temp.length; i++) {
					result[i] = 0;
				}
			}
			return result;
		}
	}

	/**
	 * 比较2个数组是否相等
	 * 
	 * @param data1
	 * @param data2
	 * @return
	 */
	private static boolean compareByteArray(byte[] data1, byte[] data2) {
		if (data1.length != data2.length) {
			return false;
		}
		for (int i = 0; i < data1.length; i++) {
			if (data1[i] != data2[i]) {
				return false;
			}
		}
		return true;
	}

	/**
	 * 生成source的MD5
	 * 
	 * @param source
	 * @return
	 */
	private static byte[] getMD5(byte[] source) {
		try {
			java.security.MessageDigest md = java.security.MessageDigest
					.getInstance("MD5");
			md.update(source);
			byte[] output = new byte[16];
			int len = md.digest(output, 0, output.length);
			if (len != output.length) {
				System.err.println("mdd error");
				return null;
			}
			return output;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 生成规则：<br>
	 * 前14位为uuid的高64位生成35进制数，如果为负数，把负号换成'z'，不够14位用0补齐<br>
	 * 中间13位为uuid的低64位生成35进制数，由于这64必然是负数，因此13位就足够用，把负号去掉，不够13位用0补齐<br>
	 * 最后8位是由uuid的字符串加上Key的md5码2次对折后生成的，换算成35进制，如果为负数，把负号换成'z'，不够8位用0补齐<br>
	 */
	private static String merge(UUID uuid, byte[] md5) {
		StringBuilder builder = new StringBuilder();
		long high = uuid.getMostSignificantBits();
		long low = uuid.getLeastSignificantBits();
		BigInteger bi = BigInteger.valueOf(high);
		String string = formatMore(bi.toString(35), 14);
		builder.append(string);
		bi = BigInteger.valueOf(low);
		string = fomrmatLess(bi.toString(35), 13);
		builder.append(string);
		bi = new BigInteger(md5);
		string = formatMore(bi.toString(35), 8);
		builder.append(string);
		return builder.toString();
	}

	/**
	 * 去掉负号，位数不够，用0补齐
	 * 
	 * @param input
	 * @param len
	 * @return
	 */
	private static String fomrmatLess(String input, int len) {
		int strLen = input.length();
		if (strLen > len) {
			if (input.charAt(0) == '-') {
				return input.substring(1);
			} else {
				return input;
			}
		}
		if (strLen < len) {
			StringBuilder builder = new StringBuilder();
			for (int i = 0; i < len - strLen; i++) {
				builder.append('0');
			}
			builder.append(convert(input));
			return builder.toString();
		}
		return convert(input);
	}

	/**
	 * 如果为负号，把负号换成'z'，位数不够,用0补齐
	 * 
	 * @param input
	 * @param len
	 * @return
	 */
	private static String formatMore(String input, int len) {
		int strLen = input.length();
		if (strLen > len) {
			if (input.charAt(0) == '-') {
				return 'z' + input.substring(1);
			} else {
				return input;
			}
		}
		if (strLen < len) {
			StringBuilder builder = new StringBuilder();
			for (int i = 0; i < len - strLen; i++) {
				builder.append('0');
			}
			builder.append(convert(input));
			return builder.toString();
		}
		return convert(input);
	}

	/**
	 * 把负号换成'z'
	 * 
	 * @param num
	 * @return
	 */
	private static final String convert(String num) {
		if (num.charAt(0) == '-') {
			return 'z' + num.substring(1);
		} else {
			return num;
		}
	}

	/**
	 * 把input对折，缩短数组长度
	 * 
	 * @param input
	 * @return
	 */
	private static byte[] shortByteArray(byte[] input) {
		byte[] output = new byte[input.length / 2];
		for (int i = 0; i < input.length / 2; i++) {
			output[i] = (byte) (input[i] ^ input[input.length - 1 - i]);
		}
		return output;
	}

}
