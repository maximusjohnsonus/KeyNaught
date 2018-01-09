#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SettingCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *insText;
@property (weak, nonatomic) IBOutlet UITextField *dispText;

@end
