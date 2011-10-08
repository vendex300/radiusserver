//
//  ServerDBOperate.h
//  RPCTest
//
//  Created by yedawei on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Server : NSObject{

}

@property int version;
@property (nonatomic, retain) NSString * clientID;
@property (nonatomic, retain) NSString * ip;
@property (nonatomic, retain) NSString * port;

-(NSData *) downloadImage:(NSString *)url;
-(NSData*) rpc:(NSData *) rpcData;
-(NSData *) createRPCData:(NSData *)rpcData;

-(NSData *) getClientIDWithEmail:(NSString *)email device:(NSString*)device;
-(NSData *) getOrderIDWithType:(int)orderType ;
-(NSData *) ConfirmOrderWithOrderID:(NSString *)orderID receptData:(NSString *)receptData;


@end
