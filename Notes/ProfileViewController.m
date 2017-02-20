
#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //get username and email for logged user and display in profile page
    self.userName.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"loginUserName"];
    self.userEmail.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"loginUserEmail"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (IBAction)done:(id)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}
@end
