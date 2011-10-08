//
//  IStream.h
//  connectionProject
//
//  Created by yedawei on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Page.h"
#import "ViewSpot.h"
#import "User.h"
#import "Comment.h"
#import "DataType.h"

@interface DataInputStream : NSObject {
    NSData * data;
    int curIndex;
}

@property (nonatomic, retain) NSData * data;

-(id) initWithData:(NSData *)data;

-(u_int32_t)readInt;
-(NSString *) readString;
-(u_int8_t) readChar;
-(double) readDouble;
-(NSDate *) readDate;
-(u_int64_t) readLong;
-(void)reset;
@end
