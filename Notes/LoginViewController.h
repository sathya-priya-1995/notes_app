

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SSKeychain.h"

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UIButton *logouBtn;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@end
