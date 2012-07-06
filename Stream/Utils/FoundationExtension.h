//
//  FoundationExtension.h
//  Shopinion
//
//  Created by Che-Bin Liu on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (extended)

- (BOOL)contains:(NSString *)aString;
- (BOOL)contains:(NSString *)aString ignoreCase:(BOOL)ignoreCase;
- (NSString *)md5;

@end
