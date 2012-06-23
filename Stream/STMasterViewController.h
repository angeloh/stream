//
//  STMasterViewController.h
//  Stream
//
//  Created by Macbook Pro on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STDetailViewController;

@interface STMasterViewController : UITableViewController

@property (strong, nonatomic) STDetailViewController *detailViewController;

@end
