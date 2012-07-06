//
//  STAppDelegate.m
//  Stream
//
//  Created by Macbook Pro on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "STAppDelegate.h"
#import "ExampleMenuRootController.h"
#import "STLink.h"
#import "STUser.h"
#import "STGlobals.h"
#import <RestKit/RestKit.h>
#import "STDBStore.h"
#import "DBStore.h"
#import "FileHelpers.h"

@implementation STAppDelegate

@synthesize window = _window;
@synthesize splitViewController = _splitViewController;
@synthesize stackController = _stackController;
@synthesize facebook = _facebook;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // init facebook
    [self setupFB];
    
    // load restkit
    [self setupRestKit];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    // nav stack controller
    ExampleMenuRootController *menuController = [[ExampleMenuRootController alloc] init];
    self.stackController = [[PSStackedViewController alloc] initWithRootViewController:menuController];
    self.window.rootViewController = self.stackController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Pre 4.2 support
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url {
    return [_facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [_facebook handleOpenURL:url];
}

#pragma mark - setup methods

- (void)setupAppVersion
{
    // get the app's version
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 version, @"appVersion",
                                 nil];
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
}

- (void)setupFB
{
    NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
    
    // facebook instance
    _facebook = [[Facebook alloc] initWithAppId:FACEBOOK_APP_ID andDelegate:self];
    
    // check fb token
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
}

- (void)setupRestKit
{
#if DEBUG
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
#endif
    
    // Initialize RestKit
	RKObjectManager* objectManager = [RKObjectManager managerWithBaseURLString:@"http://www.fanboee.com"];
    
    // Enable automatic network activity indicator management
    objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    
    // Initialize object store
    //    NSString *databaseName = @"stream.sqlite";
    //    objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName];
    
    //    NSString *storeDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //    DBStore *store = [DBStore sharedDBStore];
    //    objectManager.objectStore = [RKManagedObjectStore
    //                                 objectStoreWithStoreFilename:@"stream.sqlite" 
    //                                 inDirectory:storeDirectory
    //                                 usingSeedDatabaseName:nil
    //                                 managedObjectModel:[store model] 
    //                                 delegate:nil];
    
    // Initialize object store
    NSString *databaseName = [[DBStore sharedDBStore] storeName];
//    NSString *seedDatabaseName = RKDefaultSeedDatabaseFileName;
    objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName 
                                                             usingSeedDatabaseName:nil 
                                                                managedObjectModel:[[DBStore sharedDBStore] managedObjectModel] 
                                                                          delegate:self];
    
    RKManagedObjectMapping* userMapping = [RKManagedObjectMapping mappingForClass:[STUser class] inManagedObjectStore:objectManager.objectStore];
    userMapping.primaryKeyAttribute = @"fbId";
    [userMapping mapKeyPathsToAttributes:
     @"fbId", @"fbId",
     @"name", @"name",
     nil];
    
    RKManagedObjectMapping* linkMapping = [RKManagedObjectMapping mappingForClass:[STLink class] inManagedObjectStore:objectManager.objectStore];
    linkMapping.primaryKeyAttribute = @"linkId";
    [linkMapping mapKeyPathsToAttributes:
     @"link_id", @"linkId",
     @"owner", @"owner",
     @"owner_comment", @"ownerComment",
     @"picture", @"picture",
     @"summary", @"summary",
     @"title", @"title",
     @"url", @"url",
     @"created_time", @"createdTime",
     nil];
    [linkMapping mapRelationship:@"user" withMapping:userMapping];
    
    [objectManager.mappingProvider setObjectMapping:linkMapping forResourcePathPattern:@"/loadLinks"];
    
    //    RKManagedObjectSeeder* seeder = [RKManagedObjectSeeder objectSeederWithObjectManager:objectManager];
    //    // Seed the database with instances of RKTStatus from a snapshot of the RestKit Twitter timeline
    //    [seeder seedObjectsFromFile:@"links.json" withObjectMapping:linkMapping];
    //    // Finalize the seeding operation and output a helpful informational message
    //    [seeder finalizeSeedingAndExit];
    
    [RKObjectManager setSharedManager:objectManager];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark FBSessionDelegate

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
    
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
    
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
    
}


@end
