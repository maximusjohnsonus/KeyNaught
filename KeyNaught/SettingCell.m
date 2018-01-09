#import <Foundation/Foundation.h>
#import "SettingCell.h"

@interface SettingCell ()

@end

@implementation SettingCell

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end


