
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
- (IBAction)doLogOut:(id)sender
{
    //while logout we will clear all details from userdefaults
    //remove dropbox session while logout
     if ([[DBSession sharedSession] isLinked])
     {
    [[DBSession sharedSession] unlinkAll];
     }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginUsermName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginUserEmail"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"login"];
    [[NSUserDefaults standardUserDefaults] synchronize];
   // [self dismissViewControllerAnimated:YES completion:nil];
    UIStoryboard *board=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc=[board instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
    [self presentViewController:vc animated:YES completion:nil];

    
}

@end
