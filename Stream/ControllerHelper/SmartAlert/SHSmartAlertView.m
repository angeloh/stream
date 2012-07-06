#import "SHSmartAlertView.h"

@implementation SHSmartAlertView


+ (void)showTwoBtnsAlertwithTarget:(id)target 
                  andAction:(SEL)action
                  withTitle:(NSString *)title
                withMessage:(NSString *)message {
    
	SHSmartAlertView *rAlertView = [[SHSmartAlertView alloc] initTwoBtnsAlertWithView:nil
                                                            withTitle:title 
                                                          withMessage:message
                                                           withTarget:target 
                                                           withAction:action];
	[rAlertView show];
}

+ (void)showOneBtnAlertwithTarget:(id)target 
                  andAction:(SEL)action
                  withTitle:(NSString *)title
                withMessage:(NSString *)message {
    
	SHSmartAlertView *rAlertView = [[SHSmartAlertView alloc] initOneBtnAlertWithView:nil
                                                            withTitle:title 
                                                          withMessage:message
                                                           withTarget:target 
                                                           withAction:action];
	[rAlertView show];
}


- (id)initTwoBtnsAlertWithView:(UIView<SHSmartAlertViewDelegate>*)view 
                     withTitle:(NSString*)title
                   withMessage:(NSString *)message
                    withTarget:(id)target 
                    withAction:(SEL)action {
    if ((self = [super initWithTitle:title 
                             message:message 
                            delegate:self 
                   cancelButtonTitle:@"Cancel" 
                   otherButtonTitles:@"Ok",nil])) {
        if (view)
        {
            [self addSubview:view];
            view_ = view;
            if([view conformsToProtocol:@protocol(SHSmartAlertViewDelegate)])
                linkToData_ = view;

        }
		delegate_ = target;
		selector_ = action;
	}
	return self;
}

- (id)initOneBtnAlertWithView:(UIView<SHSmartAlertViewDelegate>*)view 
                     withTitle:(NSString*)title 
                   withMessage:(NSString *)message
                    withTarget:(id)target 
                    withAction:(SEL)action {
    if ((self = [super initWithTitle:title 
                             message:message 
                            delegate:self 
                   cancelButtonTitle:@"OK" 
                   otherButtonTitles:nil])) {
        if (view)
        {
            [self addSubview:view];
            view_ = view;
        }
		delegate_ = target;
		selector_ = action;
	}
	return self;
}

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message 
           delegate:(id /*<UIAlertViewDelegate>*/)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle 
  otherButtonTitles:(NSString *)otherButtonTitles, ...{
	if ((self = [super initWithTitle:title 
                             message:message 
                            delegate:delegate 
                   cancelButtonTitle:cancelButtonTitle
                   otherButtonTitles:otherButtonTitles, nil])) {
	}
	return self;
}

-(void)setDelegate{
	[self doesNotRecognizeSelector: _cmd];
}

-(CGFloat)getBottomOfView:(UIView*)view{
	return view.frame.size.height + view.frame.origin.y;
}

- (void)moveView:(UIView *)view1 underAnotherView:(UIView*)view2  {
	CGRect view1Frame = view1.frame;
	view1Frame.origin.y = [self getBottomOfView:view2] + 5;
	view1.frame = view1Frame;
}

- (void)moveView:(UIView *)view1 topLeftOfView:(UIView*)view2  {
	CGRect view1Frame = view1.frame;
	view1Frame.origin.y = view2.frame.origin.y + 2;
    view1Frame.origin.x = view2.frame.origin.x + 2;
	view1.frame = view1Frame;
}

- (void)resizeAlertView:(UIAlertView *) alertView  {
	CGFloat height = view_.frame.size.height + 30;	
	alertView.frame = CGRectMake(15.0f, (460-height)/2 ,300.0f, height);
}

- (void)moveView:(UIView*)view1 toCenterOfView:(UIView*)view2{
	view1.center = CGPointMake(view2.frame.size.width/2 , view2.frame.size.height/2);
}

- (void)willPresentAlertView:(UIAlertView *)alertView{
	if (nil == view_)
		return;	
//	[self resizeAlertView:alertView];
	[self moveView:view_ topLeftOfView:alertView];
//	[self moveView:view_ underAnotherView:[self.subviews objectAtIndex:0]];		//title
//	[self moveView:[self.subviews objectAtIndex:1] underAnotherView:view_];			//okButton
//	[self moveView:[self.subviews objectAtIndex:2] underAnotherView:view_];		//cancelButton
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 1) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[delegate_ performSelector:selector_ withObject:linkToData_.Data];
#pragma clang diagnostic pop
    }
}


@end
