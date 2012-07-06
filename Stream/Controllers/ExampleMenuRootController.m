//
//  ExampleMenuRootController.m
//  PSStackedViewExample
//
//  Created by Peter Steinberger on 7/18/11.
//  Copyright 2011 Peter Steinberger. All rights reserved.
//

#import "PSStackedView.h"
#import "STAppDelegate.h"
#import "STGlobals.h"
#import "MenuTableViewCell.h"
#import "ExampleMenuRootController.h"
#import "UIImage+OverlayColor.h"
#import "SampleContentViewController.h"
#include <QuartzCore/QuartzCore.h>
#import "SHPhoneSetViewController.h"
#import <RestKit/RestKit.h>
#import <RestKit/RKManagedObjectStore.h>
#import "STUser.h"
#import "STLink.h"
#import "FoundationExtension.h"
#import "SBJSON.h"
#import "SBJsonParser.h"
#import "LIExposeController.h"
#import "BrowserViewController.h"

#define kMenuWidth 200
#define kCellText @"CellText"
#define kCellImage @"CellImage" 

@interface ExampleMenuRootController()
@property (nonatomic, strong) UITableView *menuTable;
@property (nonatomic, strong) NSArray *cellContents;
@property (nonatomic, strong) NSArray *linkObjs;
@end

@implementation ExampleMenuRootController

static int _viewControllerId = 0;

@synthesize menuTable = menuTable_;
@synthesize cellContents = cellContents_;
@synthesize linkObjs = linkObjs_;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject



///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIView

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"load example view, frame: %@", NSStringFromCGRect(self.view.frame));
        
#if 0
    self.view.layer.borderColor = [UIColor greenColor].CGColor;
    self.view.layer.borderWidth = 2.f;
#endif
    
    // add example background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
            
    // prepare menu content
    NSMutableArray *contents = [[NSMutableArray alloc] init];
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"08-chat"], kCellImage, NSLocalizedString(@"Johnson L",@""), kCellText, nil]];
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"08-chat"], kCellImage, NSLocalizedString(@"Harley H",@""), kCellText, nil]];
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"08-chat"], kCellImage, NSLocalizedString(@"Tony T",@""), kCellText, nil]];
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"08-chat"], kCellImage, NSLocalizedString(@"Albert K",@""), kCellText, nil]];
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"08-chat"], kCellImage, NSLocalizedString(@"York R",@""), kCellText, nil]];
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"08-chat"], kCellImage, NSLocalizedString(@"Robin L",@""), kCellText, nil]];
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"08-chat"], kCellImage, NSLocalizedString(@"Tina C",@""), kCellText, nil]];    
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"08-chat"], kCellImage, NSLocalizedString(@"Angela L",@""), kCellText, nil]];    
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"08-chat"], kCellImage, NSLocalizedString(@"Walter L",@""), kCellText, nil]];    
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"08-chat"], kCellImage, NSLocalizedString(@"LL B",@""), kCellText, nil]];    

    
    self.cellContents = contents;
    
    // add table menu
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMenuWidth, self.view.height) style:UITableViewStylePlain];
    self.menuTable = tableView;
    
    self.menuTable.backgroundColor = [UIColor clearColor];
    self.menuTable.delegate = self;
    self.menuTable.dataSource = self;
    [self.view addSubview:self.menuTable];
    [self.menuTable reloadData];
    
//    [self loadLinks];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBOpening"]) {
        [XAppDelegate.stackController popViewControllerAnimated:YES];
        SHPhoneSetViewController* controller = [[SHPhoneSetViewController alloc] init];
        controller.phoneSetDelegate = self;
        [XAppDelegate.stackController pushViewController:controller fromViewController:nil animated:YES];
        return;
    }
    // check phone number or facebook cred existed
    if (![XAppDelegate.facebook isSessionValid]) {
        SHPhoneSetViewController* controller = [[SHPhoneSetViewController alloc] init];
        controller.phoneSetDelegate = self;

        [defaults setObject:@"YES" forKey:@"FBOpening"];
        [defaults synchronize];

        [XAppDelegate.stackController pushViewController:controller fromViewController:nil animated:YES];
    } else {
        NSString* token = [XAppDelegate.facebook accessToken];
        NSString* time =  [NSString stringWithFormat:@"%.0f", [[XAppDelegate.facebook expirationDate] timeIntervalSince1970]];
        NSString* sessionId = [defaults objectForKey:@"sessionId"];
        NSString* rPath = [NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",@"/loadLinks", @"fbToken", token, @"fbExpiresIn", time, @"sessionIdParam", sessionId];
        
        // XSTEP load from RESTKIT
        // Load the object model via RestKit
        RKObjectManager* objectManager = [RKObjectManager sharedManager];
        [objectManager loadObjectsAtResourcePath:rPath delegate:self];
        
    }

}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cellContents_ count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ExampleMenuCell";
    
    MenuTableViewCell *cell = (MenuTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	cell.textLabel.text = [[cellContents_ objectAtIndex:indexPath.row] objectForKey:kCellText];
	cell.imageView.image = [[cellContents_ objectAtIndex:indexPath.row] objectForKey:kCellImage];
	    
    //if (indexPath.row == 5)
    //    cell.enabled = NO;
    
    return cell;
}

#pragma mark - Helper Methods
- (UIViewController *)newViewControllerForExposeController:(LIExposeController *)exposeController {
    STLink* linkObj = [linkObjs_ objectAtIndex:_viewControllerId];
    BrowserViewController* bvc = [[BrowserViewController alloc] initWithUrls:[NSURL URLWithString:linkObj.url]];
    bvc.title = [NSString stringWithFormat:NSLocalizedString(linkObj.title, linkObj.title), _viewControllerId];
    _viewControllerId++;
    return [[UINavigationController alloc] initWithRootViewController:bvc];
}


- (void)loadLinks{
    linkObjs_ = [[NSMutableArray alloc] initWithCapacity:1];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"links" ofType:@"json"]; 
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:filePath];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *data = (NSDictionary *) [parser objectWithString:fileContent error:nil];  
    
    //getting the data from inside of "menu"  
    NSArray *links = (NSArray *) [data objectForKey:@"links"];
//    RKManagedObjectStore* store = [[RKObjectManager sharedManager] objectStore];
    
    for (NSDictionary* link in links)
    {
        NSString *linkId = [[link objectForKey:@"link_id"] stringValue];
        NSString *owner = [[link objectForKey:@"owner"]stringValue];
        NSString *comment = (NSString *)[link objectForKey:@"owner_comment"];
        NSString *picture = (NSString *)[link objectForKey:@"picture"];
        if([picture isEqual:[NSNull null]]) {
            picture = @"";
        }
        NSString *summary = (NSString *)[link objectForKey:@"summary"];
        if([summary isEqual:[NSNull null]]) {
            summary = @"";
        }
        NSString *title = (NSString *)[link objectForKey:@"title"];
        if([title isEqual:[NSNull null]]) {
            title = @"";
        }
        NSString *url = (NSString *)[link objectForKey:@"url"];
        NSString *createdTime = [[link objectForKey:@"created_time"] stringValue];
        
//        STLink* link = [STLink createEntity];
        STLink* link = [[STLink alloc] init];
        [link setLinkId:linkId];
        [link setOwner:owner];
        [link setOwnerComment:comment];
        [link setPicture:picture];
        [link setSummary:summary];
        [link setTitle:title];
        [link setUrl:url];
        [link setCreatedTime:createdTime];
//        [store save:nil];
        [linkObjs_ addObject:link];
    }  

    
//	NSFetchRequest* request = [STLink fetchRequest];
//	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
//	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
//	linkObjs_ = [STLink objectsWithFetchRequest:request];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
    PSStackedViewController *stackController = XAppDelegate.stackController;
    UIViewController*viewController = nil;
    
    // Pop everything off the stack to start a with a fresh app feature
    // DISABLED FOR DEBUGGING
    [stackController popToRootViewControllerAnimated:YES];
    
    LIExposeController *exposeController = [[LIExposeController alloc] init];
//    exposeController.exposeDelegate = self;
//    exposeController.exposeDataSource = self;
    exposeController.editing = YES;
    
    _viewControllerId = 0;
    
    exposeController.viewControllers = [NSMutableArray arrayWithObjects:
                                        [self newViewControllerForExposeController:exposeController],
                                        [self newViewControllerForExposeController:exposeController],
                                        [self newViewControllerForExposeController:exposeController],
                                        [self newViewControllerForExposeController:exposeController],
                                        [self newViewControllerForExposeController:exposeController],
                                        [self newViewControllerForExposeController:exposeController],
                                        [self newViewControllerForExposeController:exposeController],
                                        [self newViewControllerForExposeController:exposeController],
                                        [self newViewControllerForExposeController:exposeController],
                                        [self newViewControllerForExposeController:exposeController],
                                        [self newViewControllerForExposeController:exposeController],
                                        [self newViewControllerForExposeController:exposeController],
                                        nil];
    
    viewController = exposeController;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBOpening"]) {
        [XAppDelegate.stackController popViewControllerAnimated:YES];
        SHPhoneSetViewController* controller = [[SHPhoneSetViewController alloc] init];
        controller.phoneSetDelegate = self;
        [XAppDelegate.stackController pushViewController:controller fromViewController:nil animated:YES];
        return;
    }

    if (viewController && ![defaults objectForKey:@"FBOpening"]) {
        [XAppDelegate.stackController pushViewController:viewController fromViewController:nil animated:YES];
    }
}

#pragma - RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    STLog(@"after lodding link objects from server, %@", objects);
    //    SimpleAccount* account = [objects objectAtIndex:0];
    
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    STLog(@"failed lodding link objects from server, %@", error);
}

#pragma mark - FBRequestDelegate methods

- (void)request:(FBRequest *)request didLoad:(id)result {
    NSDictionary *userInfo = (NSDictionary *)result;
    NSString* userName = [userInfo objectForKey:@"name"];
    NSString* fbId = [userInfo objectForKey:@"id"];
    
    NSString* sessionId = [[NSString stringWithFormat:@"%d", arc4random()] md5];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sessionId forKey:@"sessionId"];
    [defaults synchronize];
    
    // XSTEP create user data object and save session
    // save to core data
    RKManagedObjectStore* store = [[RKObjectManager sharedManager] objectStore];
    STUser* user = [STUser createEntity];
    [user setFbId:fbId];
    [user setName:userName];
    [user setSessionId:sessionId];
    [store save:nil];
    
    NSString* token = [XAppDelegate.facebook accessToken];
    NSString* time =  [NSString stringWithFormat:@"%.0f", [[XAppDelegate.facebook expirationDate] timeIntervalSince1970]];

    NSString* rPath = [NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",@"/loadLinks", @"fbToken", token, @"fbExpiresIn", time, @"sessionIdParam", sessionId];
    
    // XSTEP ask for data
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:rPath delegate:self];

}

#pragma mark - LIExposeControllerDataSource Methods

- (UIView *)backgroundViewForExposeController:(LIExposeController *)exposeController {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 
                                                          0, 
                                                          exposeController.view.frame.size.width, 
                                                          exposeController.view.frame.size.height)];
    v.backgroundColor = [UIColor darkGrayColor];
    return v;
}

- (void)shouldAddViewControllerForExposeController:(LIExposeController *)exposeController {
    [exposeController addNewViewController:[self newViewControllerForExposeController:exposeController] 
                                  animated:YES];
}

- (UIView *)addViewForExposeController:(LIExposeController *)exposeController {
    return nil;
}

- (UIView *)exposeController:(LIExposeController *)exposeController overlayViewForViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        viewController = [(UINavigationController *)viewController topViewController];
    }
    if ([viewController isKindOfClass:[BrowserViewController class]]) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 
                                                                    0, 
                                                                    viewController.view.bounds.size.width, 
                                                                    viewController.view.bounds.size.height)];
        label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        label.text = viewController.title;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:48];
        label.adjustsFontSizeToFitWidth = YES;
        label.shadowColor = [UIColor blackColor];
        label.shadowOffset = CGSizeMake(1, 1);
        return label;
    } else {
        return nil;
    }
}

- (UILabel *)exposeController:(LIExposeController *)exposeController labelForViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        viewController = [(UINavigationController *)viewController topViewController];
    }
    if ([viewController isKindOfClass:[BrowserViewController class]]) {
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.text = viewController.title;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:14];
        label.shadowColor = [UIColor blackColor];
        label.shadowOffset = CGSizeMake(1, 1);
        [label sizeToFit];
        CGRect frame = label.frame;
        frame.origin.y = 4;
        label.frame = frame;
        return label;
    } else {
        return nil;
    }
}

@end
