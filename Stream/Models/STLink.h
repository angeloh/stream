//
//  STLink.h
//  Stream
//
//  Created by Macbook Pro on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <CoreData/CoreData.h>


@interface STLink : NSManagedObject {
}

@property (nonatomic, strong) NSString* linkId;

@property (nonatomic, strong) NSString* owner;

@property (nonatomic, strong) NSString* ownerComment;

@property (nonatomic, strong) NSString* picture;

@property (nonatomic, strong) NSString* summary;

@property (nonatomic, strong) NSString* title;

@property (nonatomic, strong) NSString* url;

@property (nonatomic, strong) NSString* createdTime;

@property (nonatomic, strong) NSManagedObject* user;

@end
