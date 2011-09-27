package com.pptp.share;

import java.io.ByteArrayInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class StreamPrinter {
	private static final int BUFFER_SIZE = 1024 * 4;
	// 每个包最大尺寸： 64KB

	DataOutputStream stream;

	public StreamPrinter(OutputStream output) {
		this.stream = new DataOutputStream(output);
	}

	public void printInt(int value) throws IOException {
		stream.writeInt(value);
	}

	public void printString(String value) throws IOException {
		byte[] data = value.getBytes("UTF-8");
		stream.writeInt(data.length);
		if (data.length > 0) {
			stream.write(data);
		}
	}

	public void printData(byte[] data) throws IOException {
		printInt(data.length);
		printData(stream, data);
	}

	private static void printData(OutputStream out, byte[] data)
			throws IOException {
		int len = data.length;
		if (len > 0) {
			if (len < BUFFER_SIZE) {
				out.write(data);
			} else {
				printLargeData(out, data);
			}
		}
	}

	private static void printLargeData(OutputStream out, byte[] data)
			throws IOException {
		ByteArrayInputStream input = new ByteArrayInputStream(data);
		byte[] tmp = new byte[BUFFER_SIZE];
		int count = 0;
		while ((count = input.read(tmp)) > 0) {
			out.write(tmp, 0, count);
		}
	}

	public void printLong(long value) throws IOException {
		stream.writeLong(value);
	}

	public void flush() {
		try {
			stream.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void close() {
		try {
			stream.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
