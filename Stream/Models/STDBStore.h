//
//  STDBStore.h
//  Stream
//
//  Created by Macbook Pro on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface STDBStore : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSString* storeName;
+ (STDBStore *)sharedSTDBStore;
- (NSURL *)applicationDocumentsDirectory;
@end
