//
//  IStream.m
//  connectionProject
//
//  Created by yedawei on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataInputStream.h"
#import "Debug.h"
#import "ReuseUtil.h"

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
    return  nil;
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


-(Page *) readViewPage{
    Page * page = [[[Page alloc] init] autorelease];
    debug(@"read start");
    u_int64_t tripID = [self readLong];
    page.trip = [ReuseUtil getTrip:tripID];
    debug(@"read trip end");
    page.pageID = [self readLong] ;
    debug(@"read pageID");
    page.number = [self readInt];
    debug(@"read number");
    page.type = [self readChar];
    debug(@"read type");
    page.photoCatagory = [self readChar];
    debug(@"read photoCatagory");
    page.displayTime = [self readDate];
    debug(@"read displayTime");
    page.photoLongitude = [[self readString] doubleValue];
    debug(@"read photoLongitude");
    page.photoLatitude = [[self readString] doubleValue];
    debug(@"read photoLatitude");
    page.title = [self readString];
    debug(@"read title");
    page.description = [self readString];
    debug(@"read description");
    page.photoFile =[self readString];
    debug(@"read photoFile");
    page.photoURL = [self readString];
    debug(@"read photoURL");
    page.photoWidth = [self readInt];
    debug(@"read photoWidth");
    page.photoHeight = [self readInt];
    debug(@"read photoHeight");
    page.recommendType = [self readChar];
    debug(@"read recommendType");
    page.commentCount = [self readInt];
    debug(@"read commentCount");
    page.totalLike = [self readInt];
    debug(@"read totalLike");
    page.isLike = [self readChar] > 0;
    debug(@"read isLike\n\n\n\n\n\n");
    page.accuracy = [self readInt];
    return page;
}

-(void)reset{
    curIndex = 0;
}

-(Trip *) readTrip {
    u_int64_t tripID = [self readLong];
    Trip * trip = [ReuseUtil getTrip:tripID];
    trip.title = [self readString];
    trip.pageCount = [self readInt];
    User * user = [[[User alloc] init] autorelease];
    user.userID = [self readLong];
    user.name = [self readString];
    user.url = [self readString];
    trip.user = user;
    return trip;
}

-(id) _readByType:(enum DataType)type {
    switch (type) {
        case T_INT:
        case T_CHAR:
        case T_LONG:
        case T_DOUBLE:
            break;
        case T_STRING:
            return [self readString];
        case T_DATE:
        case T_FILE:
            break;
        case T_TRIP:   
            return [self readTrip];
        case T_DOWN_PAGE:
        case T_VIEW_PAGE:
            return [self readViewPage];
        case T_DATA:
            break;
        case T_FULL_DATA:
            break;
        case T_BOOL:
            return [NSNumber numberWithBool:[self readChar] > 0];
        case T_VIEWSPOT:
            return [self readViewSpot];
        case T_USER:
            return [self readUser];
        case T_COMMENT:
            return [self readComment];
    }
    return nil;

}


-(id) readByType:(enum DataType) type
{
    int success = [self readChar];
    if(success){
        return [self _readByType:type];
    } else {
        NSLog(@"error info : %@",[self readString]);
    }
    return nil;
}

-(NSArray *) readArrayByType:(enum DataType) type {
    int success = [self readChar];
    if(success){
        int count = [self readInt];
        NSMutableArray * array = [[[NSMutableArray alloc] init] autorelease];
        for (int i = 0; i < count; i++) {
            [array addObject:[self _readByType:type]];
        }
        return array;
    } else {
        NSLog(@"error info : %@",[self readString]);
    }
    return [NSArray arrayWithObjects: nil];
}

-(ViewSpot*) readViewSpot {
    ViewSpot * vs = [[[ViewSpot alloc] init] autorelease];
    vs.popularity = [self readLong];
    vs.favorate = [self readDouble];
    vs.famousPhotoURL = [self readString];
    vs.longitude = [self readDouble];
    vs.latitude = [self readDouble];
    vs.zoneIndex = [self readLong];
    return vs;
}


-(User *) readUser {
    u_int64_t userID = [self readLong];
    User * user = [ReuseUtil getUser:userID];
    user.name = [self readString];
    user.url = [self readString];
    return user;
}

-(Comment *)readComment {
    Comment * comment = [[[Comment alloc] init] autorelease];
    comment.commentID = [self readLong];
    comment.comment = [self readString];
    comment.date = [self readDate];
    User * user = [self readUser];
    comment.user = user;
    User * destUser = [self readUser];
    comment.destUser = destUser;
    
    return comment;
}


-(void)dealloc {
    self.data = nil;
    [super dealloc];
}


@end
