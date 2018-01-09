#import "ViewController.h"
#import "SettingCell.h"

@interface ViewController ()

@property (nonatomic, strong) NSUserDefaults *keyDefaults;
@property (nonatomic, strong) NSMutableArray *keyData;
@property (nonatomic, strong) NSMutableArray *tiles;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) UITableViewCell *addKeyRow;
@property (nonatomic) BOOL editFlag;

@end

@implementation ViewController


- (IBAction)contentChanged:(UITextField *)sender{
    NSLog(@"tag: %ld", sender.superview.superview.tag);
    NSInteger index = sender.superview.superview.tag;
    NSString *insText = ((UITextField *)sender.superview.subviews[0]).text;
    NSString *dispText = ((UITextField *)sender.superview.subviews[1]).text;
    
    [self.keyData setObject:@[insText, dispText] atIndexedSubscript:index];
    [self.keyDefaults setObject:self.keyData forKey:@"keys"];
    [self.keyDefaults synchronize];
}

- (UITableViewCell *) makeSettingCellWithIndex:(NSInteger)index{
    NSArray *data = [self.keyData objectAtIndex:index];
    
    SettingCell *cell = [[self table] dequeueReusableCellWithIdentifier:@"SettingsTile"]; //Has to be name of .xib file
    
    cell.tag = index;
    cell.insText.text = data[0];
    cell.dispText.text = data[1];
    
    return cell;
}

- (void) updateTags{
    for(int i = 0; i < [self.tiles count]; i++){
        ((UITableViewCell *)[self.tiles objectAtIndex:i]).tag = i;
    }
}

- (IBAction)edit {
    if([self.table isEditing]){
        // Remove the "Add key" row
        
        // cellForRowAtIndexPath knows what to do
        self.editFlag = NO;
        [self.table reloadData];
    } else {
        // Add the "Add key" row

        // Say we're adding a new row at index 0. We've already made this cell and cellForRowAtIndexPath knows what to do
        //[self.table beginUpdates];
        self.editFlag = YES;
        [self.table insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationTop];
        //[self.table endUpdates];
        // This looks nice
        //[self.table reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationTop];
    }
    
    [self.table setEditing:!(self.table.isEditing) animated:YES];
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0){
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // For removing rows
        [self.keyData removeObjectAtIndex:indexPath.row];
        [self.keyDefaults setObject:self.keyData forKey:@"keys"];
        [self.keyDefaults synchronize];
        
        [self.tiles removeObjectAtIndex:indexPath.row];
        [self updateTags];
        
        [tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // For inserting rows
        //[self.table beginUpdates];
        
        // Add a new entry to the key array
        [self.keyData insertObject:@[@"",@""] atIndex:0];
        [self.keyDefaults setObject:self.keyData forKey:@"keys"];
        [self.keyDefaults synchronize];
        
        // Add a new cell to our array (and update indices)
        [self.tiles insertObject:[self makeSettingCellWithIndex:0] atIndex:0];
        [self updateTags];
        
        // Add a new row to the table
        [self.table insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
        //[self.table reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        //[self.table endUpdates];
        //[self.table reloadData];
        //[self.table reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
        //[self.table reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:1 inSection:1] ] withRowAnimation:UITableViewRowAnimationTop];

    }
}

// Methods for moving rows
- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section != 0;
}
- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSArray *temp = [self.keyData objectAtIndex:sourceIndexPath.row];
    [self.keyData removeObjectAtIndex:sourceIndexPath.row];
    [self.keyData insertObject:temp atIndex:destinationIndexPath.row];
    [self.keyDefaults setObject:self.keyData forKey:@"keys"];
    [self.keyDefaults synchronize];
    
    UITableViewCell *tempCell = [self.tiles objectAtIndex:sourceIndexPath.row];
    [self.tiles removeObjectAtIndex:sourceIndexPath.row];
    [self.tiles insertObject:tempCell atIndex:destinationIndexPath.row];
    
    [self updateTags];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keyDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.doop.KeyNaught"];
    self.keyData = [[self.keyDefaults objectForKey:@"keys"] mutableCopy];
    
    // Initialize with data if we haven't yet
    if(self.keyData == NULL){
        self.keyData = [NSMutableArray arrayWithObjects:@[@"Meme",@"Foot"], @[@"",@""], nil];
        [self.keyDefaults setObject:self.keyData forKey:@"keys"];
        [self.keyDefaults synchronize];
    }
    
    // Make all the table rows
    self.tiles = [[NSMutableArray alloc] initWithCapacity:[self.keyData count]];
    for(int i = 0; i < [self.keyData count]; i++){
        UITableViewCell *cell = [self makeSettingCellWithIndex:i];
        [self.tiles setObject:cell atIndexedSubscript:i];
    }
    
    // Make the "Add key" row
    self.addKeyRow = [[self table] dequeueReusableCellWithIdentifier:@"AddKeyRow"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if (indexPath.section == 0) {
        return self.addKeyRow;
    } else {
        return [self.tiles objectAtIndex:index];
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){ // Holds the "Add key" cell
        return (self.editFlag ? 1 : 0);
    } else {
        return [self.keyData count];
    }
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    return parentSize;
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {}

- (void)setNeedsFocusUpdate {}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    return false;
}

- (void)updateFocusIfNeeded {}

@end


