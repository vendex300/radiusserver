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

-(id)init{
    self = [super init];
    if(self){
        self.clientID = [DBEditOperate getClientID];
        self.ip = @"192.168.1.10";
    }
    return self;
}

-(NSArray *) getEmptyArray {
    return nil;
}

// #@private
-(NSData *) createUploadPhotoRPC:(NSString *)fileName {
    NSMutableData * rpcData = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:rpcData];    //alloc
    [stream writeString:@"uploadPhoto"];
    [stream writeString:self.clientID];
    [stream writeString:fileName];
    
//    NSArray * dataArray = [NSArray arrayWithObjects:fileName, nil];
//    NSArray * typeArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:T_STRING], nil];
//    RPCPackage * package = [[RPCPackage alloc] initWithName:@"uploadPhoto" clientID:clientID typeArray:typeArray dataArray:dataArray];
//    [stream writeRPCPackge:package];
//    [package release];

    [stream release];                   //release
    return  rpcData ;
}

// #@private
-(NSData *) createUploadData:(NSString *)file{
    NSMutableData * output = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:output];     //alloc
    [stream writeInt:version];
    NSString * fileName = [file lastPathComponent];
    [stream writeFullData:[self createUploadPhotoRPC:fileName]];
    [stream writeFile:file];
    [stream release];
    return output ;     //release
}

// #@private
-(void)readData:(NSData *) data {
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];     //alloc
    int success = [stream readChar];
    if(success){
        NSLog(@"rpc success : %d", [stream readInt]); 
    } else {
        NSLog(@"rpc failed : %@", [stream readString]);
    }
    [stream release];     //release
}

// #@private
-(NSData *) createUploadTripRPCData:(Trip *)trip pages:(NSArray *)pageArray {
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];   //alloc
    [stream writeString:@"uploadTrip"];
    [stream writeString:self.clientID];
    [stream writeTrip:trip];
    for(Page * page in pageArray){
        [stream writePage:page];
    }
    [stream release];       //release
    return data;
}

// #@private
-(NSData *) createDownloadTrip:(Trip *)trip {
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];      //alloc
    [stream writeString:@"downloadTrip"];
    [stream writeString:self.clientID];
    [stream writeLong:trip.tripID];
    [stream release];                   //release
    return data;
}


// #@private
-(NSData *) createGetPageByTrip:(Trip *)trip {
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];      //alloc
    [stream writeString:@"getPageByTrip"];
    [stream writeString:self.clientID];
    [stream writeLong:trip.tripID];
    [stream release];                   //release
    return data;
}


// #@private
-(NSData *) createRPCData:(NSData *)rpcData {
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];   //alloc
    [stream writeInt:version];
    [stream writeFullData:rpcData];
    [stream release];               //releae
    return data;
}

// #@private ---- remove
-(NSData*) rpc:(NSData *) rpcData {
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


// #@private
-(NSData *) createGetTripByKeywordRPCData:(NSString *)keyword begin:(int)begin count:(int)count{
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];           //alloc
    [stream writeString:@"getTripByKeyword"];
    [stream writeString:self.clientID];
    [stream writeString:keyword];
    [stream writeInt:begin];
    [stream writeInt:count];
    [stream release];               //release
    return data;
}

// #@private
-(NSArray *) readTrip:(NSData *)data {
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];     //alloc
    int success = [stream readChar];
    NSMutableArray * array = [[[NSMutableArray alloc] init] autorelease];
    if(success){
        int count = [stream readInt];
        for(int i = 0; i < count; i++){
            Trip * trip = [stream readTrip];
            [array addObject:trip];
        }
    } else {
        NSLog(@"get trip by key word failed : %@ ", [stream readString]);
    }
    
    [stream release];           //release
    return array;
}

// #@private
-(NSData *) createGetAllTripRPC:(int)begin count:(int)count {
    return [self createGetTripByKeywordRPCData:nil begin:begin count:count];
}

// #@implement
-(NSArray *) getAllTrip:(int)begin count:(int)count{
    NSData * data = [self rpc:[self createRPCData:[self createGetAllTripRPC:begin count:count]]];
    if(data){
        return [self readTrip:data];
    }
    return nil;
}

// #@implement
-(NSArray *) getPageByTrip:(Trip *)trip{
    NSData * data = [self rpc:[self createRPCData:[self createGetPageByTrip:trip]]];
    if(!data){
        return nil;
    }
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];         //alloc

    int success = [stream readChar];
    NSMutableArray * result = [[[NSMutableArray alloc] init] autorelease];
    if(success){
        int pageCount = [stream readInt];
        trip.pageCount = pageCount;
        for(int i = 0; i < pageCount;i++){
            Page * page = [stream readViewPage];
            page.trip = trip;
            [result addObject:page];
        }
        Earth2Mars * e2m = [[Earth2Mars alloc] init];
        [e2m translatePageArray:result];
        [e2m release];
    } else {
        NSLog(@"read failed : %@ ", [stream readString]);
    }
    
    [stream release];                   //release
    return result;
}

// #@implement
-(NSArray *) getTripByKeyword:(NSString *)keyword begin:(int)begin count:(int)count{
    NSData * data = [self rpc:[self createRPCData:[self createGetTripByKeywordRPCData:keyword begin:begin count:count]]];
    if(nil == data){
        return nil;
    }
    return [self readTrip:data];
}


// #private
-(NSData *) createSearPageRPCData:(u_int8_t)type keyword:(NSString *)keyword longitude:(double)longitude latitude:(double)latitude{
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];       //alloc
    [stream writeString:@"searchPage"];
    [stream writeString:self.clientID];
    [stream writeChar:type];
    [stream writeString:keyword];
    [stream writeDouble:longitude];
    [stream writeDouble:latitude];
    [stream release];                   //release
    return  data;
}

//// #@implement
//-(NSArray *) searchPage:(u_int8_t)type keyword:(NSString *)keyword longitude:(double)longitude latitude:(double)latitude{
//    NSData * data = [self rpc:[self createRPCData:[self createSearPageRPCData:type keyword:keyword longitude:longitude latitude:latitude]]];
//    if(nil == data){
//        return [self getEmptyArray];
//    }
//    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];        //alloc
//
//    NSMutableArray * result = [[[NSMutableArray alloc] init] autorelease];
//    int success = [stream readChar];
//    if(success){
//        int pageCount = [stream readInt];
//        for(int i = 0; i < pageCount; i++){
//            Page * page = [stream readPage];
//            [result addObject:page];
//        }
//    } else {
//        NSLog(@"search page failed : %@ ", [stream readString]);
//    }
//    [stream release];                                                   //release
//    return result;
//}

// #@implement
-(NSArray *) checkUpdateTrip:(NSArray *)tripArray{
    return FALSE;
}


// #@implement
-(bool) uploadPhoto:(NSString *) file{
    NSData * data = [self rpc:[self createUploadData:file]];
    if(nil == data){
        return FALSE;
    }
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];     //alloc
    int success = [stream readChar];
    if(success){
//        NSLog(@"upload photo success : %d", [stream readInt]); 
    } else {
//        NSLog(@"upload photo failed : %@", [stream readString]);
    }
    [stream release];                                                   //release
    return success;
}


// #@implement
-(bool) uploadTrip:(Trip *)trip{
    NSArray * pageArray = [DBEditOperate getPageByTrip:trip];
    NSLog(@"uploadTrip page count %d ", [pageArray count]);
    NSData * rpcData = [self createUploadTripRPCData:trip pages:pageArray];
    NSData * data = [self rpc:[self createRPCData:rpcData]];
    if(nil == data){
        return FALSE;
    }
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];     //alloc
    int success = [stream readChar];
    u_int64_t result = 0;
    if(success){
//        NSLog(@"upload trip success");
        result = [stream readLong];
    } else {
    }
    [stream release];                       //release
    return success > 0;
}

// #private
-(NSData *) createDownloadRPC:(Trip *)trip {
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];
    [stream writeString:@"downloadTrip"];
    [stream writeString:self.clientID];
    [stream writeLong:trip.tripID];
    [stream release];
    return data;
}

-(NSArray *) downloadTripPage:(Trip *)trip{
    NSData * data = [self rpc:[self createRPCData:[self createDownloadRPC:trip]]];
    if(data == nil){
        return nil;
    }
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];
    NSMutableArray * result = nil;// [[[NSMutableArray alloc] init] autorelease];
    int success = [stream readChar];
    if(success){
        result = [[[NSMutableArray alloc] init] autorelease];
        int pageCount = [stream readInt];
        trip.pageCount = pageCount;
        for(int i = 0; i < pageCount;i++){
            Page * page = [stream readViewPage];
            page.trip = trip;
            [result addObject:page];
        }
        
        Earth2Mars * e2m = [[Earth2Mars alloc] init];
        [e2m translatePageArray:result];
        [e2m release];
    } else {
        NSLog([stream readString],nil);
    }
    [stream release];
    return result;
}


// #@implement
-(NSArray *) downloadTrip:(Trip *) trip
{
    NSArray * result = [self downloadTripPage:trip];
    if(nil != result){
        LocalDBOperate * local = [[LocalDBOperate alloc] init ] ;   // alloc 
        [local addTrip:trip pages:result];
        [local release];                        //release
    }
    return result;
}

// #private
-(NSData *) createGetCommentRPCData:(Page *)page begin:(int)begin count:(int)count{
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];
    [stream writeString:@"getCommentByPage"];
    [stream writeString:self.clientID];
    [stream writeLong:page.pageID];
    [stream writeInt:begin];
    [stream writeInt:count];
    [stream release];
    return data;
}

// #@implement
-(NSArray *) getCommentByPage:(Page *) page begin:(int)begin count:(int)count{
    NSData * data = [self rpc:[self createRPCData:[self createGetCommentRPCData:page begin:begin count:count]]];
    if(data == nil) {
        return nil;
    }
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];
    NSArray * commentArray = [stream readArrayByType:T_COMMENT];
    [stream release];
    return commentArray;
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

// #private
-(NSData *) createLoginData:(NSString *)email password:(NSString *)password deviceID:(NSString *)deviceID{
    NSMutableData * data = [[[NSMutableData alloc] init ] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];
    [stream writeString:@"login"];
    [stream writeString:email];
    [stream writeString:password];
    [stream writeString:deviceID];
    [stream release];
    return data;
}

// #private
-(NSData *) createRegisterData:(NSString *)email password:(NSString *)password deviceID:(NSString *)deviceID{
    NSMutableData * data = [[[NSMutableData alloc] init ] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];
    [stream writeString:@"register"];
    [stream writeString:email];
    [stream writeString:password];
    [stream writeString:deviceID];
    [stream release];
    return data;
}

// #@implement
-(User *) registerUser:(NSString *)email password:(NSString *)password deviceID:(NSString *)deviceID{
    NSData * data = [self rpc:[self createRPCData:[self createRegisterData:email password:password deviceID:deviceID]]];
    if(nil == data){
        return nil;
    }
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];
    int success = [stream readChar];
    if(success){
        NSLog(@"begin read clientID");
        NSString * client_ID = [stream readString];
        NSLog(@"end read clientID");

        self.clientID = client_ID;
        User * user = [stream readUser];
        [stream release];
        [DBEditOperate saveClientID:self.clientID withUser:user];
        return user;
    }
    NSLog(@"erro : %@",[stream readString]);
    [stream release];
    return nil;
}

// #@implement
-(User *)login:(NSString *)email password:(NSString *)password deviceID:(NSString *)deviceID{
    NSData * data = [self rpc:[self createRPCData:[self createLoginData:email password:password deviceID:deviceID]]];
    if(nil == data){
        return nil;
    }
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];
    int success = [stream readChar];
    if(success){
        NSString * client_ID = [stream readString];
        self.clientID = client_ID;
        NSLog(@"clientID : %@",self.clientID);
        User * user = [stream readUser];
        [DBEditOperate saveClientID:self.clientID withUser:user];
        [stream release];
        return user;
    } else {
        NSLog(@"login error : %@",[stream readString]);
    }
    [stream release];
    return nil;
}

// #private
-(NSData *) createAddCommentData:(u_int64_t)pageID destUserID:(u_int64_t)destUserID comment:(NSString *)comment{
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];
    [stream writeString:@"addComment"];
    [stream writeString:self.clientID];
    [stream writeLong:pageID];
    [stream writeLong:destUserID];
    [stream writeString:comment];
    [stream release];
    return data;
}

// #@implement
-(u_int64_t) addComment:(u_int64_t)pageID destUserID:(u_int64_t)destUserID comment:(NSString *)comment{
    NSData * data = [self rpc:[self createRPCData:[self createAddCommentData:pageID destUserID:destUserID comment:comment]]];
    if(data == nil) {
        return 0;
    }
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];
    int success = [stream readChar];
    u_int64_t result = 0;
    if(success){
        result = [stream readLong];
    } else {
        NSLog(@"erro : %@",[stream readString]);
    }
    [stream release];
    return result;
}

// #private
-(NSData *) createUpdateComment:(u_int64_t)commentID comment:(NSString *)newComment{
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];
    [stream writeString:@"updateComment"];
    [stream writeString:self.clientID];
    [stream writeLong:commentID];
    [stream writeString:newComment];
    [stream release];
    return data;
}

// #@implement
-(bool) updateComment:(u_int64_t)commentID comment:(NSString *)newComment{
    NSData * data = [self rpc:[self createRPCData:[self createUpdateComment:commentID comment:newComment]]];
    if(data == nil){
        return FALSE;
    }
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];
    int success = [stream readChar];
    [stream release];
    return success > 0;
}


-(NSData *) createSearchViewSpotRPCData:(double)lng1 lat1:(double)lat1 lng2:(double)lng2 lat2:(double)lat2 zoomLevel:(int)zoomLevel photoCatagory:(u_int8_t)photoCatagory {
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];
    [stream writeString:@"searchViewSpot"];
    [stream writeString:self.clientID];
    [stream writeDouble:lng1];
    [stream writeDouble:lat1];
    [stream writeDouble:lng2];
    [stream writeDouble:lat2];
    [stream writeInt:zoomLevel];
    [stream writeChar:photoCatagory];
    [stream release];
    return data;
}


// #@implement
-(NSArray *) searchViewSpotWithLng1:(double)lng1 lat1:(double)lat1 lng2:(double)lng2 lat2:(double)lat2 zoomLevel:(u_int32_t)zoomLevel photoCatagory:(u_int8_t)photoCatagory {
    NSData * data = [self rpc:[self createRPCData:[self createSearchViewSpotRPCData:lng1 lat1:lat1 lng2:lng2 lat2:lat2 zoomLevel:zoomLevel photoCatagory:photoCatagory]]];
    if(data== nil){
        return nil;
    }
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];
    NSArray * array = [stream readArrayByType:T_VIEWSPOT];
    Earth2Mars * e2m = [[Earth2Mars alloc] init];
    [e2m translateViewSpotArray:array];
    [e2m release];
    [stream release];
    return array;
}

-(NSData *) createGetPageByZone:(u_int64_t)zoneIndex{
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];
    [stream writeString:@"getPageByZone"];
    [stream writeString:self.clientID];
    [stream writeLong:zoneIndex];
    [stream release];
    return data;
}

// #@implement
-(NSArray *) getPageByZone:(u_int64_t)zoneIndex{
    NSData * data = [self rpc:[self createRPCData:[self createGetPageByZone:zoneIndex]]];
    if(data == nil){
        NSLog(@"rpc failed");
        return nil;
    }
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];
    NSArray * array = [stream readArrayByType:T_VIEW_PAGE];
    Earth2Mars * e2m = [[Earth2Mars alloc] init];
    [e2m translatePageArray:array];
    [e2m release];
    [stream release];
    return array;
}

-(NSData *) createLikePhotoRPCData:(u_int64_t)pageID{
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    DataOutputStream * stream = [[DataOutputStream alloc] initWithData:data];
    [stream writeString:@"likePhoto"];
    [stream writeString:self.clientID];
    [stream writeLong:pageID];
    [stream release];
    return data;
}

// #@implement
-(bool) likePhoto:(u_int64_t)pageID {
    NSData * data = [self rpc:[self createRPCData:[self createLikePhotoRPCData:pageID]]];
    if(data == nil) {
        return FALSE;
    }
    DataInputStream * stream = [[DataInputStream alloc] initWithData:data];
    NSNumber * bNum = [stream readByType:T_BOOL];
    [stream release];
    return [bNum boolValue];
}

@end
