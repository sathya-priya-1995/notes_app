

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SSKeychain.h"

@interface SignupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmationPassword;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;


@end
