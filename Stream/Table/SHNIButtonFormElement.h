//
//  SHNIButtonFormElement.h
//  Shopinion
//

#import "NIFormCellCatalog.h"


@interface SHNIButtonFormElement : NIButtonFormElement

// Designated initializer
+ (id)buttonElementWithID:(NSInteger)elementID labelText:(NSString *)labelText tappedTarget:(id)target tappedSelector:(SEL)selector;

@end
