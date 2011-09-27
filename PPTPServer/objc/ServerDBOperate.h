//
//  ServerDBOperate.h
//  RPCTest
//
//  Created by yedawei on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBOperate.h"

@interface ServerDBOperate : NSObject <DBOperate>{

}

@property int version;
@property (nonatomic, copy) NSString * clientID;
@property (nonatomic, copy) NSString * ip;

-(bool) uploadPhoto:(NSString *) file;
-(bool) uploadTrip:(Trip *)trip;
-(NSArray *) downloadTrip:(Trip *) trip;
-(NSArray *) getCommentByPage:(Page *) page begin:(int)begin count:(int)count;

-(NSData *) downloadImage:(NSString *)url;


//return 1_clientID   or 0_failInfo
-(User *) registerUser:(NSString *)email password:(NSString *)password deviceID:(NSString *)deviceID;

-(User *)login:(NSString *)email password:(NSString *)password deviceID:(NSString *)deviceID;

-(u_int64_t) addComment:(u_int64_t)pageID destUserID:(u_int64_t)destUserID comment:(NSString *)comment;

-(bool) updateComment:(u_int64_t)commentID comment:(NSString *)newComment;

-(NSArray *) searchViewSpotWithLng1:(double)lng1 lat1:(double)lat1 lng2:(double)lng2 lat2:(double)lat2 zoomLevel:(u_int32_t)zoomLevel photoCatagory:(u_int8_t)photoCatagory;

-(NSArray *) getPageByZone:(u_int64_t)zoneIndex;


@end
