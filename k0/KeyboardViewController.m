#import "KeyboardViewController.h"
#import "KeyButton.h"

#define MIN_BUTTON_WIDTH 40
#define PADDING 6
#define RADIUS 4

@interface KeyboardViewController ()

@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSTimer *delTimer;

@end

@implementation KeyboardViewController

- (void)didTapButton:(id)sender{
    [self.textDocumentProxy insertText:((KeyButton*)sender).insText];
}

- (void)tappedDelete{
    [self.textDocumentProxy deleteBackward];
    self.delTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(delTimerFire) userInfo:nil repeats:YES];
}
- (void)delTimerFire{
    [self.textDocumentProxy deleteBackward];

    // Each time it fires, shrink the difference between the current period and the min period shrink by a constant factor
    NSTimeInterval lastTime = self.delTimer.timeInterval;
    NSTimeInterval nextTime = lastTime - (lastTime - 0.05)*0.3;
    [self.delTimer invalidate];
    self.delTimer = [NSTimer scheduledTimerWithTimeInterval:nextTime target:self selector:@selector(delTimerFire) userInfo:nil repeats:YES];
}
- (void)untappedDelete{
    [self.delTimer invalidate];
}

- (NSInteger) expectedWidth:(KeyButton *)button{
    CGSize expectedLabelSize = [button.titleLabel.text sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:22] } ];
    return MAX(MIN_BUTTON_WIDTH, expectedLabelSize.width+14);
}

- (KeyButton*)createButtonWithTitle:(NSString*)title text:(NSString*)text {
    if ([title isEqualToString:@""]){ // If no title is set, use the text
        title = text;
    }
    
    KeyButton* button = [KeyButton buttonWithType:UIButtonTypeRoundedRect];
    [[button layer] setCornerRadius:RADIUS];
    
    [button setTitle:title forState:UIControlStateNormal];
    button.insText = text;
    button.titleLabel.font = [UIFont systemFontOfSize:22];
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.08 alpha:1.0] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (NSInteger)minIndex:(NSInteger [])arr withSize:(NSInteger)size{
    NSInteger mini = 0;
    NSInteger minv = arr[0];
    for(int i = 1; i < size; i++){
        if (arr[i] < minv){
            minv = arr[i];
            mini = i;
        }
    }
    return mini;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    // Change the width and height. The autoconstraints will do the rest
    const CGFloat height = [UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height ? 216 : 162;
    const CGFloat width = [UIScreen mainScreen].bounds.size.width;

    self.heightConstraint.constant = height;
    self.widthConstraint.constant = width;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    const CGFloat height = [UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height ? 216 : 162;
    const CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    NSUserDefaults *keyDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.doop.KeyNaught"];
    self.keys = [keyDefaults objectForKey:@"keys"];
    
    // Create next keyboard button
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [[self.nextKeyboardButton layer] setCornerRadius:RADIUS];
    [self.nextKeyboardButton setTitle:@"ABC" forState:UIControlStateNormal]; //🌎🌐🌍🌏🗺
    self.nextKeyboardButton.titleLabel.font = [UIFont systemFontOfSize:15];
    self.nextKeyboardButton.backgroundColor = [UIColor colorWithRed:0.675 green:0.702 blue:0.741 alpha:1.0];
    [self.nextKeyboardButton setTitleColor:[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.08 alpha:1.0] forState:UIControlStateNormal];
    [self.nextKeyboardButton addTarget:self action:@selector(handleInputModeListFromView:withEvent:) forControlEvents:UIControlEventAllTouchEvents];
    [self.view addSubview:self.nextKeyboardButton];
    
    // Set constraints for the next keyboard button
    [self.inputView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nextKeyboardButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *lnc = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.inputView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:PADDING];
    NSLayoutConstraint *bnc = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.inputView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-1*PADDING];
    NSLayoutConstraint *wnc = [NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.inputView attribute:NSLayoutAttributeWidth multiplier:0.15 constant:0.0];
    NSLayoutConstraint *hnc = [NSLayoutConstraint constraintWithItem:self.inputView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.nextKeyboardButton attribute:NSLayoutAttributeHeight multiplier:4.0 constant:5*PADDING];
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.inputView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.inputView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];

    [self.inputView addConstraints:@[lnc,bnc,wnc,hnc, self.heightConstraint, self.widthConstraint]];

    
    // Create Backspace key
    UIButton *delKey = [UIButton buttonWithType:UIButtonTypeSystem];
    [[delKey layer] setCornerRadius:RADIUS];
    UIImage *deleteIcon = [[UIImage imageNamed:@"deleteIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [delKey setImage:deleteIcon forState:UIControlStateNormal];
    [delKey.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [delKey setImageEdgeInsets:UIEdgeInsetsMake(5, 9, 5, 10)];
    delKey.backgroundColor = [UIColor colorWithRed:0.675 green:0.702 blue:0.741 alpha:1.0];
    
    [delKey addTarget:self action:@selector(tappedDelete) forControlEvents:UIControlEventTouchDown];
    [delKey addTarget:self action:@selector(untappedDelete) forControlEvents:UIControlEventTouchUpInside];
    [delKey addTarget:self action:@selector(untappedDelete) forControlEvents:UIControlEventTouchDragExit];
    [self.view addSubview:delKey];
    
    // Set constraints for the Backspace button
    [delKey setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nextKeyboardButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *rdc = [NSLayoutConstraint constraintWithItem:delKey attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.inputView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-1*PADDING];
    NSLayoutConstraint *bdc = [NSLayoutConstraint constraintWithItem:delKey attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.inputView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-1*PADDING];
    NSLayoutConstraint *wdc = [NSLayoutConstraint constraintWithItem:delKey attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.inputView attribute:NSLayoutAttributeWidth multiplier:0.15 constant:0.0];
    NSLayoutConstraint *hdc = [NSLayoutConstraint constraintWithItem:delKey attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.nextKeyboardButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.inputView addConstraints:@[rdc,bdc,wdc,hdc]];
    
    
    // Create Space key
    KeyButton *spaceKey = [self createButtonWithTitle:@"space" text:@" "];
    spaceKey.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:spaceKey];
    
    // Set constraints for the Space button
    [delKey setTranslatesAutoresizingMaskIntoConstraints:NO];
    [spaceKey setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *lpc = [NSLayoutConstraint constraintWithItem:spaceKey attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.nextKeyboardButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:PADDING];
    NSLayoutConstraint *rpc = [NSLayoutConstraint constraintWithItem:spaceKey attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:delKey attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-1*PADDING];
    NSLayoutConstraint *bpc = [NSLayoutConstraint constraintWithItem:spaceKey attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.inputView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-1*PADDING];
    NSLayoutConstraint *hpc = [NSLayoutConstraint constraintWithItem:spaceKey attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.nextKeyboardButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.inputView addConstraints:@[lpc,rpc,bpc,hpc]];
    
    
    // Create horizontal scroll container for custom keys
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.showsHorizontalScrollIndicator = YES;
    [self.view addSubview:scroll];
    
    // Constrain scroll
    [scroll setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *lsc = [NSLayoutConstraint constraintWithItem:scroll attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.inputView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *tsc = [NSLayoutConstraint constraintWithItem:scroll attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.inputView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *bsc = [NSLayoutConstraint constraintWithItem:scroll attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.nextKeyboardButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *rsc = [NSLayoutConstraint constraintWithItem:scroll attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.inputView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
    [self.view addConstraints:@[lsc,tsc,bsc,rsc]];

    // This makes it so you can still touch it, just can't see it
    [scroll setBackgroundColor:[UIColor colorWithHue:0.3 saturation:1.0 brightness:1.0 alpha:0.001]];

    // Create normal buttons
    const int numRows = 3;
    NSInteger rowWidths[numRows] = {PADDING, PADDING, PADDING}; // We only use this to put the buttons in the shortest rows, not for constraints
    UIView *rows[numRows] = {[[UIView alloc] init], [[UIView alloc] init], [[UIView alloc] init]}; // These 2 are for layout/constraints
    UIView *rightView[numRows] = {nil,nil,nil};

    for(int i = 0; i < [self.keys count]; i++){
        // Get the data for the button we're adding
        NSArray *key = [self.keys objectAtIndex:i];
        
        // Find the row that is shortest (we'll put this button in that row)
        NSInteger mini = [self minIndex:rowWidths withSize:numRows];
        
        // Create button
        KeyButton *button = [self createButtonWithTitle:key[1] text:key[0]];
        NSInteger buttonWidth = [self expectedWidth:button];
        [rows[mini] addSubview:button];
        
        // Set constraints
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *lbc;
        if(rightView[mini] == nil){
            lbc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rows[mini] attribute:NSLayoutAttributeLeft multiplier:1.0 constant:PADDING];
        } else {
            lbc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rightView[mini] attribute:NSLayoutAttributeRight multiplier:1.0 constant:PADDING];
        }
        NSLayoutConstraint *tbc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rows[mini] attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        NSLayoutConstraint *bbc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:rows[mini] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        NSLayoutConstraint *wbc = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:buttonWidth];
        [rows[mini] addConstraints:@[lbc,tbc,bbc,wbc]];
        
        rowWidths[mini] += buttonWidth + PADDING; // Add the added button's width and some padding to the row we put it in
        rightView[mini] = button;
    }
    

    // Add each row to the scroll view and make constraints
    for(int i = 0; i < numRows; i++){
        UIView *row = rows[i];
        [scroll addSubview:row];

        [row setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *lrc = [NSLayoutConstraint constraintWithItem:row attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scroll attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        NSLayoutConstraint *rrc = [NSLayoutConstraint constraintWithItem:row attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:scroll attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
        
        NSLayoutConstraint *trc;
        if (i == 0) {
            trc = [NSLayoutConstraint constraintWithItem:row attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:scroll attribute:NSLayoutAttributeTop multiplier:1.0 constant:PADDING];
        } else {
            trc = [NSLayoutConstraint constraintWithItem:row attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rows[i-1] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:PADDING];

        }
        NSLayoutConstraint *hrc = [NSLayoutConstraint constraintWithItem:row attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.nextKeyboardButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        NSLayoutConstraint *wsc = [NSLayoutConstraint constraintWithItem:scroll attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:rightView[i] attribute:NSLayoutAttributeRight multiplier:1.0 constant:PADDING];

        [self.view addConstraints:@[lrc,rrc,trc,hrc, wsc]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    /*UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];*/
}

@end
