//
//  Sample.m
//  Client
//
//  Created by yedawei on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Sample.h"
#import "Server.h"
#import "DataInputStream.h"
#import "DataOutputStream.h"

@implementation Sample




-(void) execute {
    Server * server = [[Server alloc] init];
    server.ip = @"192.168.1.202";
    server.port = @"8080";
    server.version = 100;
    NSData * data = [server rpc:[server createRPCData:[server getClientIDWithEmail:@"yedawei003@snaplore.com" device:@"device-007-001"]]];
    DataInputStream * input = [[DataInputStream alloc] initWithData:data];
    int success = [input readInt];
    NSLog(@"success : %i",success);
    NSString * clientID = [input readString];
    NSLog(@"clientID : %@",clientID);
    server.clientID = clientID;
    [input release];
    input = nil;
    
    data = [server rpc:[server createRPCData:[server getOrderIDWithType:1]]];
    input = [[DataInputStream alloc] initWithData:data];
    success = [input readInt];
    NSLog(@"success : %i",success);
    NSString * orderID = [input readString];
    NSLog(@"orderID : %@",orderID);
    [input release];
    
    data = [server rpc:[server createRPCData:[server ConfirmOrderWithOrderID:orderID receptData:@"recept-data-0000,1111"]]];
    input = [[DataInputStream alloc] initWithData:data];
    success = [input readInt];
    NSLog(@"success : %i",success);
    NSString * userName = [input readString];
    NSString * pwd = [input readString];
    NSLog(@"user : %@, pwd : %@",userName,pwd);
    
    [server release];
}
@end
