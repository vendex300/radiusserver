//
//  DataOutputStream.h
//  Trip
//
//  Created by yedawei on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trip.h"
#import "Page.h"
#import "ViewSpot.h"
#import "User.h"
#import "Comment.h"
#import "DataType.h"

@interface DataOutputStream : NSObject {
    NSMutableData * byteData;
}

@property (nonatomic, retain) NSData * byteData;

-(id) initWithData:(NSData *)data;

-(void) writeInt:(u_int32_t)value;
-(void) writeChar:(u_int8_t)value;
-(void) writeLong:(u_int64_t)value;
-(void) writeString:(NSString*) str;
-(void) writeDate:(NSDate*)date;
-(void) writeDouble:(double)value;
-(void) writeFile:(NSString*)file;

@end
