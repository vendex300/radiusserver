//
//  AES.c
//  CoreApp
//
//  Created by yedawei on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AES.h"
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

NSData *SNEncode(NSData *input ,NSString *key) {
    
	size_t bufferSize = [input length] + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	enc(input, key, buffer, &bufferSize );
	NSData * output = [NSData dataWithBytes:buffer length:bufferSize];
	free(buffer);
	return output;
}

NSData *SNDecode(NSData *input,NSString *key) {
    size_t bufferSize = [input length] + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	dec(input,key,buffer, &bufferSize);
	NSData * output = [NSData dataWithBytes:buffer length:bufferSize];
	free(buffer);
	return output;	
}

