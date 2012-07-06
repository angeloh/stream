#import "SHSmartAlertViewDelegate.h"
#import "SHCustomAlert.h"

@interface SHSmartAlertView : SHCustomAlert <UIAlertViewDelegate> {
	UIView *view_;
	UIViewController *controller_;
	SEL selector_;
	id<SHSmartAlertViewDelegate> linkToData_;
	id delegate_;
}

+ (void)showTwoBtnsAlertwithTarget:(id)target 
                         andAction:(SEL)action
                         withTitle:(NSString *)title
                       withMessage:(NSString *)message;

+ (void)showOneBtnAlertwithTarget:(id)target 
                        andAction:(SEL)action
                        withTitle:(NSString *)title
                      withMessage:(NSString *)message;

- (id)initTwoBtnsAlertWithView:(UIView<SHSmartAlertViewDelegate>*)view 
                     withTitle:(NSString*)title
                   withMessage:(NSString *)message
                    withTarget:(id)target 
                    withAction:(SEL)action;
- (id)initOneBtnAlertWithView:(UIView<SHSmartAlertViewDelegate>*)view 
                     withTitle:(NSString*)title 
                   withMessage:(NSString *)message
                    withTarget:(id)target 
                    withAction:(SEL)action;
@end


