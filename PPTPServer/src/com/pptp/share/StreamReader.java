package com.pptp.share;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;

public class StreamReader {

	private static final int BUFFER_SIZE = 1024;
	// 每个包最大尺寸： 64KB
	private static final int MAX_BUFFER = 1024 * 64;
	private static byte[] ZERO_DATA = new byte[0];

	final DataInputStream stream;

	public StreamReader(InputStream input) {
		this.stream = new DataInputStream(input);
	}

	public int readInt() throws IOException {
		return stream.readInt();
	}

	public int readLong() throws IOException {
		byte[] b = new byte[8];
		stream.read(b);
		int mask = 0xff;
		int temp = 0;
		int n = 0;
		for (int i = 0; i < 8; i++) {
			n <<= 8;
			temp = b[i] & mask;
			n |= temp;
		}
		return n;
	}

	public byte readByte() throws IOException {
		return stream.readByte();
	}

	public byte[] readData() throws IOException {
		int len = readInt();
		byte[] data = readData(stream, len);
		return data;
	}

	private static byte[] readData(InputStream input, int len)
			throws IOException {
		if (len == 0) {
			return ZERO_DATA;
		}
		if (len <= BUFFER_SIZE) {
			byte[] tmp = new byte[len];
			input.read(tmp);
			return tmp;
		}
		if (MAX_BUFFER < len) {
			throw new IOException("data out of max size : " + len);
		}
		return readLargeData(input, len);
	}

	private static byte[] readLargeData(InputStream input, int len)
			throws IOException {
		ByteArrayOutputStream out = new ByteArrayOutputStream(len);
		int times = len / BUFFER_SIZE;
		byte[] tmp = new byte[BUFFER_SIZE];
		int count = 0;
		int totalCount = 0;

		for (int i = 0; i < times; i++) {
			count = input.read(tmp);
			out.write(tmp, 0, count);
			totalCount += count;
		}
		count = input.read(tmp, 0, len - totalCount);
		out.write(tmp, 0, count);
		totalCount += count;
		if (totalCount != len) {
			// @ TODO
			System.err.println("read buff failed");
		}
		return out.toByteArray();
	}

	public String readString() throws IOException {
		int len = stream.readInt();
		byte[] data = new byte[len];
		int read = stream.read(data);
		if (read < len) {
			System.out.println("read error : " + len + ", " + read);
			return null;
		}
		return new String(data, "UTF-8");
	}

	public void close() {
		try {
			stream.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
