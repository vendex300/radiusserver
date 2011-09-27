package com.pptp.server;

import com.pptp.share.StreamPrinter;
import com.pptp.share.StreamReader;

/**
 * 
 * @author yedawei
 */
public interface ActionExecutor {

	public void getClientID(StreamReader reader, StreamPrinter printer);

	public void createOrder(StreamReader reader, StreamPrinter printer);

	public void confirmOrder(StreamReader reader, StreamPrinter printer);

	public void getInvitationCode(StreamReader reader, StreamPrinter printer);

	public void useInvitationCode(StreamReader reader, StreamPrinter printer);

	public void getPurchaseList(StreamReader reader, StreamPrinter printer);
	
}
