//
//  FoundationExtension.m
//  Shopinion
//
//  Created by Che-Bin Liu on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FoundationExtension.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (extended)


- (BOOL)contains:(NSString *)aString
{
	return [self contains:aString ignoreCase:NO];
}

- (BOOL)contains:(NSString *)aString ignoreCase:(BOOL)ignoreCase
{
	if (!aString) {
		return NO;
	}
	return [self rangeOfString:aString options:(ignoreCase ? NSCaseInsensitiveSearch : 0)].location != NSNotFound;
}

- (NSString *)md5
{
	const char *cStr = [self UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, strlen(cStr), result);
	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];	
}

@end

