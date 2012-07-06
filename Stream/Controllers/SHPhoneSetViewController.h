//
//  SHPhoneSetViewController.h
//  Shopinion
//
#import <UIKit/UIKit.h>
#import "NimbusCore.h"
#import "NimbusModels.h"

@protocol SHPhoneSetViewControllerDelegate;

@interface SHPhoneSetViewController : UITableViewController <UITextFieldDelegate> {
    
    id<SHPhoneSetViewControllerDelegate> __unsafe_unretained _phoneSetDelegate;
    
    @private
    NITableViewModel* _model;
    NSString *_phone;
    CGFloat _animatedDistance;
    UIView *_activityIndicatorView;
    UIActivityIndicatorView *_activityIndicator;
    UILabel *_activityLabel;
    NSTimer *_loadTimer;
}

/**
 * The delegate that will receive messages from the SHPhoneSetViewControllerDelegate
 * protocol.
 */
@property (nonatomic, unsafe_unretained) id<SHPhoneSetViewControllerDelegate> phoneSetDelegate;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SHPhoneSetViewControllerDelegate
@protocol SHPhoneSetViewControllerDelegate <NSObject>
@optional

- (void)savePhone:(NSString *)phone;

@end