//
//  SHNIButtonFormElement.m
//  Shopinion
//
#import "SHNIButtonFormElement.h"
#import "SHNIButtonFormElementCell.h"


@implementation SHNIButtonFormElement

///////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)buttonElementWithID:(NSInteger)elementID labelText:(NSString *)labelText tappedTarget:(id)target tappedSelector:(SEL)selector {
    SHNIButtonFormElement* element = [super buttonElementWithID:elementID labelText:labelText tappedTarget:target tappedSelector:selector];
    return element;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)cellClass {
    return [SHNIButtonFormElementCell class];
}
@end
