package com.pptp.server;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.pptp.share.StreamPrinter;
import com.pptp.share.StreamReader;

public class ClientServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	protected static final String ENC_KEY = "0721132001892044";// oldkey

	public ClientServlet() {
		super();
		initEnv();
	}

	private static ActionExecutor executor;
	private static HashMap<String, Method> methodMap;

	private static boolean compareTypes(Class<?>[] left, Class<?>[] right) {
		if (left.length == right.length) {
			for (int i = 0; i < left.length; i++) {
				if (!left[i].equals(right[i])) {
					return false;
				}
			}
			return true;
		}
		return false;
	}

	private static void initEnv() {
		if (methodMap == null) {
			methodMap = new HashMap<String, Method>();
			Method method[] = ActionExecutor.class.getMethods();
			Class<?>[] paramTypes = new Class<?>[] { StreamReader.class,
					StreamPrinter.class };
			for (Method m : method) {
				Class<?>[] types = m.getParameterTypes();
				if (compareTypes(types, paramTypes)) {
					methodMap.put(m.getName(), m);
					System.out.println("put method : " + m.getName());
				}
			}
		}
		if (executor == null) {
			executor = new ActionExecutorImpl();
		}
	}

	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		StreamPrinter printer = new StreamPrinter(response.getOutputStream());
		System.out.println("get");
		printer.printString("Hello world");
	}

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		process(request, response);
	}

	private void process(HttpServletRequest request,
			HttpServletResponse response) {
		try {
			StreamReader reader = new StreamReader(request.getInputStream());
			int version = reader.readInt();
			System.out.println("version : " + version);
			if (version != 100) {
				return;
			}
			byte[] data = reader.readData();
			data = AES.decrypt(data, ENC_KEY);
			reader = new StreamReader(new ByteArrayInputStream(data));
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			StreamPrinter printer = new StreamPrinter(baos);
			String actionName = reader.readString();
			if (actionName != null) {
				executor(actionName, reader, printer);
				byte[] output = baos.toByteArray();
				output = AES.encrypt(output, ENC_KEY);
				printer = new StreamPrinter(response.getOutputStream());
				printer.printData(output);
				printer.flush();
				return;
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private void executor(String actionName, StreamReader reader,
			StreamPrinter printer) {
		try {
			Method method = methodMap.get(actionName);
			method.invoke(executor, new Object[] { reader, printer });
		} catch (SecurityException e) {
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			e.printStackTrace();
		}
	}

}
