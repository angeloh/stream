//
//  STUser.m
//  Stream
//
//  Created by Macbook Pro on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "STUser.h"

@implementation STUser

@dynamic fbId;
@dynamic name;
@dynamic sessionId;
@dynamic links;


- (NSMutableSet*)linksSet {
	[self willAccessValueForKey:@"links"];
    
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"links"];
    
	[self didAccessValueForKey:@"links"];
	return result;
}
@end
