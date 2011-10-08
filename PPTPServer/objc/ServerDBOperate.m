//
//  ServerDBOperate.m
//  RPCTest
//
//  Created by yedawei on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerDBOperate.h"
#import "Trip.h"
#import "Page.h"
#import "DataInputStream.h"
#import "DataOutputStream.h"
#import "DBEditOperate.h"
#import "LocalDBOperate.h"
#import "Earth2Mars.h"

@implementation ServerDBOperate
@synthesize version;
@synthesize clientID;
@synthesize ip;

// #@private ---- remove
-(NSData*) rpc:(NSData *) rpcData {
	if(!ip){
		return nil;
	}
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/trip/TripClient", self.ip]];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    NSURLResponse * response = nil;
    [request setHTTPMethod:@"POST"];
    NSString * contentType = [NSString stringWithFormat:@"multipart/form-data"];
    [request setValue:contentType forHTTPHeaderField:@"Content-type"];
    NSString * contentLength = [NSString stringWithFormat:@"%i",[rpcData length]];
    [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:rpcData];
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error){
        NSLog(@"NSURLConnection ERROR : %@",error);
        return nil;
    }
    return data;
}

// #@implement
-(void)dealloc{
    self.clientID = nil;
    self.ip = nil;
    [super dealloc];
}

// #@implement
-(NSData *) downloadImage:(NSString *)url{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLResponse * response = nil;
    [request setHTTPMethod:@"GET"];
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error){
        NSLog(@"NSURLConnection ERROR: %@",error);
        return nil;
    }
    return data;
}

@end
