//
//  SHPhoneSetViewController.m
//  Shopinion
//
#import "SHPhoneSetViewController.h"

#import "STAppDelegate.h"
#import "SHNIButtonFormElement.h"
#import "SHNIButtonFormElementCell.h"
#import "SHSmartAlertView.h"
#import "SHSetupUITableView.h"
#import "STGlobals.h"

#import "NSString+NimbusCore.h"
#import "NimbusCore.h"
#import "ExampleMenuRootController.h"
#import <RestKit/RestKit.h>
#import "STUser.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const NSTimeInterval kFBLoadLongDelay   = 1.5;

@implementation SHPhoneSetViewController

@synthesize phoneSetDelegate = _phoneSetDelegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
/*
 * This method shows the activity indicator and
 * deactivates the table to avoid user input.
 */
- (void) showActivityIndicator:(NSString *)message
{
    if (![_activityIndicator isAnimating]) {
        _activityIndicatorView.hidden = NO;
        self.tableView.userInteractionEnabled = NO;
        if ([message isEqualToString:@""]) {
            _activityLabel.text = @"Loading";
        } else {
            _activityLabel.text = message;
        }
        [_activityIndicator startAnimating];
    }
}

/*
 * This method hides the activity indicator
 * and enables user interaction once more.
 */
- (void) hideActivityIndicator
{
    if ([_activityIndicator isAnimating]) {
        [_activityIndicator stopAnimating];   
        self.tableView.userInteractionEnabled = YES;
        _activityIndicatorView.hidden = YES;
        _activityLabel.text = @"";
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)save {
    
    if ([_phone length] == 0) {
        [SHSmartAlertView showOneBtnAlertwithTarget:self 
                                        andAction:nil
                                        withTitle:@"No Phone # Found"
                                      withMessage:[NSString stringWithFormat:@"Type Your Phone Or Sign In With Facebook To Start"]];
        return;
    }
    
    if ([_phoneSetDelegate respondsToSelector:@selector(savePhone:)]) {
        [_phoneSetDelegate savePhone:_phone];
//        [self dismissModalViewControllerAnimated:YES];
        [XAppDelegate.stackController  popViewControllerAnimated:YES];
    }
}

/**
 * Connect sign in using facebook.
 *
 */
- (void)connectFacebook {
    STLog(@"### connect with facebook");
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"read_stream",
                            nil];
    [XAppDelegate.facebook authorize:permissions];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"YES" forKey:@"FBAccessing"];
    [defaults synchronize];
    
    [XAppDelegate.stackController popViewControllerAnimated:YES];
//    [self dismissModalViewControllerAnimated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupTableHeaderView {
    CGFloat toolbarHeight = NIToolbarHeightForOrientation(NIInterfaceOrientation());
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    CGRect headerFrame = CGRectMake(0, 0, frame.size.width, frame.size.height - toolbarHeight);
    
    UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];
	
    CGRect toolbarFrame = CGRectMake(0, 0, frame.size.width, toolbarHeight);
    
    UIToolbar *topToolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
    topToolbar.barStyle = UIBarStyleBlackOpaque;
    topToolbar.translucent = NO;
    topToolbar.hidden = NO;
    [topToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem	*flexL = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [barItems addObject:flexL];
    UIBarButtonItem *image = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"app_log.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
    [barItems addObject:image];
    UIBarButtonItem	*flexR = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [barItems addObject:flexR];
//    UIBarButtonItem *doneBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)] autorelease];
//    [barItems addObject:doneBtn];
    
    [topToolbar setItems:barItems animated:YES];
    
    [headerView addSubview:topToolbar];
    
	frame = headerView.frame;
	frame.size.height = topToolbar.bottom + 10;
	headerView.frame = frame;
	
	self.tableView.tableHeaderView = headerView;
}

- (void)setupActivityIndicatorView {
    // Activity Indicator
    _activityIndicatorView = [[UIView alloc] initWithFrame:CGRectMake((self.tableView.center.x-80.0), (self.tableView.center.y-60.0), 160, 120)];
    _activityIndicatorView.layer.cornerRadius = 8;
    _activityIndicatorView.alpha = 0.8;
    _activityIndicatorView.backgroundColor = [UIColor blackColor];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(50, 30, 60, 60)];
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [_activityIndicatorView addSubview:_activityIndicator];
    _activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 160, 20)];
    _activityLabel.textAlignment = UITextAlignmentCenter;
    _activityLabel.textColor = [UIColor whiteColor];
    _activityLabel.backgroundColor = [UIColor clearColor];
    _activityLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:14.0];
    _activityLabel.text = @"";
    [_activityIndicatorView addSubview:_activityLabel];
    [self.tableView addSubview:_activityIndicatorView];
    _activityIndicatorView.hidden = YES;

}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)checkFacebookToken {
    [_loadTimer invalidate];
    _loadTimer = nil;
    [self hideActivityIndicator];
    
    if ([XAppDelegate.facebook isSessionValid]) {
        // XSTEP create user data and ask for name and id
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"FBOpening"];
        [defaults removeObjectForKey:@"FBAccessing"];
        [defaults synchronize];

        ExampleMenuRootController *menu = (ExampleMenuRootController*) [XAppDelegate.stackController rootViewController];
        // get fb id and pass to menu controller
        [XAppDelegate.facebook requestWithGraphPath:@"me?fields=id,name" andDelegate:menu];
        
        [XAppDelegate.stackController popViewControllerAnimated:YES];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startDelayFacebookTokenCheck:(NSTimeInterval)delay {
    [_loadTimer invalidate];
    _loadTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                  target:self
                                                selector:@selector(checkFacebookToken)
                                                userInfo:nil
                                                 repeats:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView

- (id)init {
    if ((self = [self initWithStyle:UITableViewStyleGrouped])) {
        self.title = NSLocalizedString(@"Catchmere", @"Controller Title: Form Cells");
        
        NSArray* tableContents = [NSArray arrayWithObjects:
                                  @"Catchmere - Re-define you bookmarks engine",
                                  @"Please sign in with Facebook below to continue.",
                                  @"",
                                  @"Facebook",
                                  [SHNIButtonFormElement buttonElementWithID:TAG_BUTTON_FACEBOOK 
                                                                   labelText:nil
                                                                tappedTarget:self
                                                              tappedSelector:@selector(connectFacebook)],
                                  nil];
        
        // We let the Nimbus cell factory create the cells.
        _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                         delegate:(id)[NICellFactory class]];
    }
    return self;
}

- (id) initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    self = [self init];
    
    if (self != nil) {
        self.phoneSetDelegate = [query objectForKey:@"delegate"];
    }
    
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
    [super loadView];
    // use tableview which accepts touch event
    self.tableView = [[SHSetupUITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    [self setupActivityIndicatorView];
    [self setupTableHeaderView];
    self.view.backgroundColor = [UIColor whiteColor];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Only assign the table view's data source after the view has loaded.
    // You must be careful when you call self.tableView in general because it will call loadView
    // if the view has not been loaded yet. You do not need to clear the data source when the
    // view is unloaded (more importantly: you shouldn't, due to the reason just outlined
    // regarding loadView).
    self.tableView.dataSource = _model;
    self.tableView.scrollEnabled = NO;
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {

    if (_activityIndicatorView) {
        [_activityIndicatorView removeFromSuperview];
    }

    [_loadTimer invalidate];
    _loadTimer = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessing"]) {
        // facebook is accessing, so check it later
        [self startDelayFacebookTokenCheck:kFBLoadLongDelay];
        [self showActivityIndicator:@"Connect With Facebook"];
    } else if ([XAppDelegate.facebook isSessionValid]) {
        // facebook token is valid, cancel setup view
        //        [self dismissModalViewControllerAnimated:YES];
        [XAppDelegate.stackController popViewControllerAnimated:YES];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
//    if ([XAppDelegate.facebook isSessionValid]) {
//        NSString* token = [XAppDelegate.facebook accessToken];
//        NSDate* expired = [XAppDelegate.facebook expirationDate];
//        
//        ExampleMenuRootController *menu = (ExampleMenuRootController*) [XAppDelegate.stackController rootViewController];
//        // Load the object model via RestKit
//        RKObjectManager* objectManager = [RKObjectManager sharedManager];
//        [objectManager loadObjectsAtResourcePath:@"/loadlinks" delegate:menu];
//    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIResponder

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////

- (void) animateTextFieldUp:(UITextField *)textField
{
    
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        _animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        _animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)animateTextFieldDown:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextFieldUp: textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextFieldDown:textField];
    [textField resignFirstResponder];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Customize the presentation of certain types of cells.
    if ([cell isKindOfClass:[NITextInputFormElementCell class]]) {
        NITextInputFormElementCell* textInputCell = (NITextInputFormElementCell *)cell;
        if (1 == cell.tag) {
            // Make the disabled input field look slightly different.
            textInputCell.textField.textColor = [UIColor lightGrayColor];
        } else {
            textInputCell.textField.textColor = [UIColor blackColor];
        }
    } 
    else if ([cell isKindOfClass:[SHNIButtonFormElementCell class]]) {
        SHNIButtonFormElementCell* fbBtnCell = (SHNIButtonFormElementCell *)cell;

        if (TAG_BUTTON_FACEBOOK == cell.tag) {
            UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fb-sign-in-button.png"]];
            bgView.contentMode = UIViewContentModeTopLeft;
            UIImageView *selectedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fb-sign-in-after-button.png"]];
            selectedView.contentMode = UIViewContentModeTopLeft;
            
            fbBtnCell.backgroundView = bgView;
            fbBtnCell.selectedBackgroundView = selectedView;
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* selectedCell = [self.tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([selectedCell isKindOfClass:[SHNIButtonFormElementCell class]]) {
        SHNIButtonFormElementCell* buttonCell = (SHNIButtonFormElementCell*)selectedCell;

        if (TAG_BUTTON_FACEBOOK == buttonCell.tag) {
            [buttonCell buttonWasTapped:selectedCell];
        }
    }
    // Clear the selection state when we're done.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
