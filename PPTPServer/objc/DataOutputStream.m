//
//  DataOutputStream.m
//  Trip
//
//  Created by yedawei on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataOutputStream.h"

@implementation DataOutputStream
@synthesize byteData;

-(id) initWithData:(NSData *)data{
    self = [super init];
    if(self){
        self.byteData = data;
    }
    return self;
}

-(void)dealloc{
    self.byteData = nil;
    [super dealloc];
}

-(void) writeData:(NSData *)data {
    [byteData appendData:data];
}

-(void) writeFullData:(NSData*)data {
    if(data){
        int len = [data length];
        [self writeInt:len];
        [self writeData:data];
    } else {
        [self writeInt:0];
    }
}

-(void) writeInt:(u_int32_t)value{
#if DEBUG
    if(!byteData){
        NSLog(@"error data is nil");
    }
#endif
    
    u_char *point = (u_char*)(&value);
    unsigned char data[4];
    data[0] = point[3];
    data[1] = point[2];
    data[2] = point[1];
    data[3] = point[0];
    [byteData appendBytes:data length:4];
}

-(void) writeChar:(u_int8_t)value{
#if DEBUG
    if(!byteData){
        NSLog(@"error data is nil");
    }
#endif
    [byteData appendBytes:&value length:1];
}

-(void) writeLong:(u_int64_t)value{
#if DEBUG
    if(!byteData){
        NSLog(@"error data is nil");
    }
#endif
    char data[8];
    data[0] = (unsigned char)(value >> 56)&0xff;
    data[1] = (unsigned char)(value >> 48)&0xff;
    data[2] = (unsigned char)(value >> 40)&0xff;
    data[3] = (unsigned char)(value >> 32)&0xff;
    data[4] = (unsigned char)(value >> 24)&0xff;
    data[5] = (unsigned char)(value >> 16)&0xff;
    data[6] = (unsigned char)(value >>  8)&0xff;
    data[7] = (unsigned char)(value      )&0xff;
    [byteData appendBytes:data length:8];
}


-(void) writeString:(NSString*) str{
    if(str){
        const char * cstr = [str UTF8String];
        int len = strlen(cstr);
        [self writeInt:len];
        [byteData appendBytes:cstr length:len];
    } else {
        [self writeInt:0];
    }
}

-(void) writeDate:(NSDate*)date{
    if(date){
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [self writeString:[formatter stringFromDate:date]];
        [formatter release];
    } else {
        [self writeString:nil];
    }
}

-(void) writeDouble:(double)value{
    [self writeString:[NSString stringWithFormat:@"%f", value]];
}

-(void) writeFile:(NSString*)file {
    NSData * fileData = [NSData dataWithContentsOfFile:file];
    if(fileData) {
        int len = [fileData length];
        [self writeInt:len];
        [byteData appendData:fileData];
    } else {
        [self writeInt:0];
    }
}


@end



















