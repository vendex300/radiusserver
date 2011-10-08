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

-(NSData *) downloadImage:(NSString *)url;

@end
