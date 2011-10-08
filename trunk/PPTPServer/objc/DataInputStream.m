//
//  IStream.m
//  connectionProject
//
//  Created by yedawei on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataInputStream.h"

#define debug(__x__) NSLog(__x__)

@implementation DataInputStream
@synthesize data;

-(id) init {
    self = [super init];
    if(self){
        curIndex = 0;
    }
    return self;
}

-(id) initWithData:(NSData *)input {
    self = [super init];
    if(self){
        curIndex = 0;
        self.data = input;
    }
    return self;
}

-(u_int32_t)readInt{
#if DEBUG
    if(!data){
        debug(@"error data is nil");
    }
#endif
    
    const u_char * bytes = [data bytes];
    int result = 0;
    u_char * tmp = (u_char*)(&result);
    tmp[0] = bytes[curIndex+3];
    tmp[1] = bytes[curIndex+2];
    tmp[2] = bytes[curIndex+1];
    tmp[3] = bytes[curIndex+0];
    curIndex+=4;
    return  result;
}
-(NSString *) readString{
    
    int len = [self readInt];
    if(len){
        NSString * str = [NSString stringWithUTF8String:[[data subdataWithRange:NSMakeRange(curIndex, len)] bytes]];
        curIndex += len;
        return str;
    }
    return  [NSString stringWithString:@""];
}

-(u_int8_t) readChar{
#if DEBUG
    if(!data){
        debug(@"error data is nil");
    }
#endif
    const u_char * bytes = [data bytes];
    u_char result = bytes[curIndex];
    curIndex++;
    return  result;
}

-(NSData *) readData {
    int len = [self readInt];
    if(len){
        NSData * result = [data subdataWithRange:NSMakeRange(curIndex, len)];
        curIndex += len;
        return result;
    }
    return nil;
}

-(NSDate *) readDate{
    NSString * date = [self readString];
    if(date){
        
        NSRange range = [date rangeOfString:@"."];
        if(range.location != NSNotFound){
            date = [date substringToIndex:range.location];
        }
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * d= [formatter dateFromString:date];
        [formatter release];
        return d;
    }
    return nil;
}

-(u_int64_t) readLong{
#if DEBUG
    if(!data){
        debug(@"error data is nil");
    }
#endif
    const u_char * bytes = [data bytes];
    u_int64_t result = 0;
    u_char * tmp = (u_char*)(&result);
    tmp[0] = bytes[curIndex+7];
    tmp[1] = bytes[curIndex+6];
    tmp[2] = bytes[curIndex+5];
    tmp[3] = bytes[curIndex+4];
    tmp[4] = bytes[curIndex+3];
    tmp[5] = bytes[curIndex+2];
    tmp[6] = bytes[curIndex+1];
    tmp[7] = bytes[curIndex+0];
    curIndex+=8;
    return  result;
}

-(double) readDouble {
    return [[self readString] doubleValue];
}


-(void)reset{
    curIndex = 0;
}

-(void)dealloc {
    self.data = nil;
    [super dealloc];
}


@end
