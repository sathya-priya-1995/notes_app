

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface ProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userEmail;
- (IBAction)doLogOut:(id)sender;
- (IBAction)done:(id)sender;

@end
