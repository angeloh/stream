//
//  SHNIButtonFormElementCell.m
//  Shopinion
//
#import "SHNIButtonFormElementCell.h"
#import "SHNIButtonFormElement.h"
#import "STGlobals.h"

@implementation SHNIButtonFormElementCell

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)buttonWasTapped:(id)sender {
    [super buttonWasTapped:sender];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(id)object {
    if ([super shouldUpdateCellWithObject:object]) {
        SHNIButtonFormElement *element = object;
        UIImageView *bgView = nil;
        UIImageView *selectedView = nil;
        
        if (element.elementID == TAG_BUTTON_FACEBOOK) {
            bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fb-sign-in-button.png"]] ;
            bgView.contentMode = UIViewContentModeTopLeft;
            selectedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fb-sign-in-after-button.png"]];
            selectedView.contentMode = UIViewContentModeTopLeft;
        }
        
        self.backgroundView = bgView;
        self.selectedBackgroundView = selectedView;

        [self setNeedsLayout];
        return YES;
    }
    return NO;
}

- (void)setHighlighted: (BOOL)highlighted animated: (BOOL)animated
{
    // don't highlight
}

- (void)setSelected: (BOOL)selected animated: (BOOL)animated 
{
    // don't select
    [super setSelected:selected animated:animated];
}

@end
