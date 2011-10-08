//
//  ServerDBOperate.m
//  RPCTest
//
//  Created by yedawei on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Server.h"
#import "DataInputStream.h"
#import "DataOutputStream.h"
//#import "AES.h"

#include <CommonCrypto/CommonCryptor.h>
#include <sys/sysctl.h>


//加密解密
static const char digist[] = {
	'0' , '1' , '2' , '3' , '4' , '5' ,
	'6' , '7' , '8' , '9' , 'a' , 'b' ,
	'c' , 'd' , 'e' , 'f' , 'g' , 'h' ,
	'i' , 'j' , 'k' , 'l' , 'm' , 'n' ,
	'o' , 'p' , 'q' , 'r' , 's' , 't' ,
	'u' , 'v' , 'w' , 'x' , 'y' , 'z'
};

static int hex2int(char hex) {
	if (hex >= digist[0] && hex <= digist[9]) {
		return hex - digist[0];
	} else {
		return hex - digist[10] + 10;
	}
}

static void hex2Data(const char * hex, char * data) {
	int len = strlen(hex);
	int i = 0;
	for (i = 0; i < len; i += 2) {
		char high = (hex2int(hex[i]) * 16) & 0xf0;
		char low = (hex2int(hex[i + 1]) & 0x0f);
		data[i / 2] = high + low;
	}
}

static void enc(NSData * input,NSString * key,void * buffer, size_t * bufferSize) {
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [input length];
    size_t numBytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCBlockSizeAES128,
                                          "1234567890123456" /* initialization vector (optional) */,
                                          [input bytes], dataLength, /* input */
                                          buffer, *bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess)
    {
		* bufferSize = numBytesEncrypted ;
    }
    return ;
}

static void dec(NSData * input, NSString* key,void * buffer,size_t *bufferSize) {
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [input length];
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCBlockSizeAES128,
                                          "1234567890123456" /* initialization vector (optional) */,
                                          [input bytes], dataLength, /* input */
                                          buffer,* bufferSize, /* output */
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess)
    {
		* bufferSize = numBytesDecrypted ;
    }
    return ;
}

static NSData *CEncode(NSData *input ,NSString *key) {
    
	size_t bufferSize = [input length] + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	enc(input, key, buffer, &bufferSize );
	NSData * output = [NSData dataWithBytes:buffer length:bufferSize];
	free(buffer);
	return output;
}

static NSData *CDecode(NSData *input,NSString *key) {
    size_t bufferSize = [input length] + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	dec(input,key,buffer, &bufferSize);
	NSData * output = [NSData dataWithBytes:buffer length:bufferSize];
	free(buffer);
	return output;	
}



#define ENC_KEY @"0721132001892044"


@implementation Server
@synthesize version;
@synthesize clientID;
@synthesize ip;
@synthesize port;

// #@private
-(NSData *) createRPCData:(NSData *)rpcData {
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];   //alloc
    [stream writeInt:version];
    
    NSData * encData = CEncode(rpcData, ENC_KEY);
    
    [stream writeFullData:encData];
    [stream release];               //releae
    return data;
}

// #@private ---- remove
-(NSData*) rpc:(NSData *) rpcData {
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/PPTPServer/Client", self.ip,self.port]];
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
    
    DataInputStream * input = [[DataInputStream alloc] initWithData:data];
    NSData * result = [input readData];//[input readData:data];
    [input release];
    return CDecode(result, ENC_KEY);
}

-(NSData *) getClientIDWithEmail:(NSString *)email device:(NSString*)device {
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * outut = [[DataOutputStream alloc] initWithData:data];
    [outut writeString:@"getClientID"];
    [outut writeString:email];
    [outut writeString:device];
    [outut release];
    return  data;
}

-(NSData *) getOrderIDWithType:(int)orderType {
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * outut = [[DataOutputStream alloc] initWithData:data];
    [outut writeString:@"createOrder"];
    [outut writeString:self.clientID];
    [outut writeInt:orderType];
    [outut release];
    return  data;
}

-(NSData *) ConfirmOrderWithOrderID:(NSString *)orderID receptData:(NSString *)receptData {
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * outut = [[DataOutputStream alloc] initWithData:data];
    [outut writeString:@"confirmOrder"];
    [outut writeString:self.clientID];
    [outut writeString:orderID];
    [outut writeString:receptData];
    [outut release];
    return  data;
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

-(void)dealloc {
    self.clientID = nil;
    self.ip = nil;
    self.port = nil;
    [super dealloc];
}

@end
