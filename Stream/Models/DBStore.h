#import <CoreData/CoreData.h>

@class STUser;

@interface DBStore : NSObject {
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
}

@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSString* storeName;

+ (DBStore *)sharedDBStore;

#pragma mark -
#pragma mark CoreData
- (BOOL)saveChanges;
- (NSManagedObjectID *)objectWithURI:(NSURL *)uri;
- (NSURL *)applicationDocumentsDirectory;
- (STUser *)createUser;
- (NSURL *)storeUrl;
@end
