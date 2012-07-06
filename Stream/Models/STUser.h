//
//  STUser.h
//  Stream
//
//  Created by Macbook Pro on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
@class STLink;

@interface STUser : NSManagedObject {
    
}
@property (nonatomic, strong) NSString* fbId;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* sessionId;

@property (nonatomic, strong) NSManagedObject* links;

- (NSMutableSet*)linksSet;

@end

@interface STUser (CoreDataGeneratedAccessors)

- (void)addLinks:(NSSet*)value_;
- (void)removeLinks:(NSSet*)value_;
- (void)addLinksObject:(STLink*)value_;
- (void)removeLinksObject:(STLink*)value_;

@end