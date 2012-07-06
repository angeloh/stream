#import "DBStore.h"

#import "STGlobals.h"
#import "SynthesizeSingleton.h"
#import "FileHelpers.h"

// models
#import "STUser.h"

#import "NSString+NimbusCore.h"

@implementation DBStore

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize storeName = _storeName;

SYNTHESIZE_SINGLETON_FOR_CLASS(DBStore);

- (void)truncateStore:(NSPersistentStoreCoordinator *)psc
            storePath:(NSString *)storePath
{
    //Erase the persistent store from coordinator and also file manager.
    NSPersistentStore *store = [psc.persistentStores lastObject];
    NSError *error = nil;
    [psc removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storePath error:&error];
    if ([[error description] length] > 0) {
        // Something is terribly wrong here.
        [NSException raise:@"Truncate failed" format:@"Reason: %@", [error description]];
    }
}

- (NSString *)storeName
{
    return @"Stream.sqlite";
}

- (NSURL *)storeUrl
{
//    NSString *storePath = pathInDocumentDirectory(self.storeName);
//    STLog(@"%@", storePath);
//    NSURL* storeUrl = [NSURL fileURLWithPath:storePath];
//    return storeUrl;
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:self.storeName];
    STLog(@"storeURL %@", storeURL);
    return storeURL;
}

- (NSURL *)modelUrl
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Stream" withExtension:@"momd"];
    STLog(@"modelURL %@", modelURL);
    return modelURL;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel == nil) {
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[self modelUrl]];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    //preload data
    //    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
    //        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CoreDataTutorial2" ofType:@"sqlite"]];
    //        
    //        NSError* err = nil;
    //        
    //        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
    //            NSLog(@"Oops, could copy preloaded data");
    //        }
    //    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeUrl options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        STLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

- (id)init
{
    if ((self = [super init])) {
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        // creaet new persistent store
        NSError *error = nil;
        
        if (![self persistentStoreCoordinator]) 
        {
            // We couldn't add the persistent store, so let's wipe it out and try again.
            [self truncateStore:psc storePath:[self.storeUrl path]];
            
            if (![self persistentStoreCoordinator])
            {
                // Something is terribly wrong here.
                [NSException raise:@"Open failed" format:@"Reason: %@", [error userInfo]];
            }
        }
        
        [self managedObjectContext];
	}
	return self;
}

- (NSManagedObjectID *)objectWithURI:(NSURL *)uri
{
    NSManagedObjectID *objectID =
    [[_managedObjectContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
    
    if (!objectID)
    {
        return nil;
    }
    return objectID;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark methods

- (BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [_managedObjectContext save:&err];
    if (!successful)
    {
        STLog(@"Error saving: %@", [err localizedDescription]);
    }
    else{
        STLog(@"Saved store.data");
    }
    return successful;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - create methods for persistence unit
- (STUser *)createUser
{
    STUser *im = [NSEntityDescription insertNewObjectForEntityForName:@"STUser" inManagedObjectContext:_managedObjectContext];
    return im;
}

@end
