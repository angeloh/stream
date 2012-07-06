//
//  STAppDelegate.h
//  Stream
//
//  Created by Macbook Pro on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSStackedView.h"
#import <RestKit/RKObjectLoader.h>
#import "FBConnect.h"


#define XAppDelegate ((STAppDelegate *)[[UIApplication sharedApplication] delegate])

@class PSStackedViewController;

@interface STAppDelegate : UIResponder <UIApplicationDelegate,
FBSessionDelegate> {
    PSStackedViewController *_stackController;
    Facebook* _facebook;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@property (strong, nonatomic) PSStackedViewController *stackController;

@property (strong, nonatomic) Facebook* facebook;

@end
