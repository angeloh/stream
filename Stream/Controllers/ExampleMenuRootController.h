//
//  ExampleMenuRootController.h
//  PSStackedViewExample
//
//  Created by Peter Steinberger on 7/18/11.
//  Copyright 2011 Peter Steinberger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RKObjectLoader.h>
#import "SHPhoneSetViewController.h"
#import "FBRequest.h"

@interface ExampleMenuRootController : UIViewController <UITableViewDataSource, 
UITableViewDelegate,
RKObjectLoaderDelegate,
SHPhoneSetViewControllerDelegate,
FBRequestDelegate> {
    UITableView *menuTable_;
    NSArray *cellContents_;
    NSMutableArray *linkObjs_;
}

@end
