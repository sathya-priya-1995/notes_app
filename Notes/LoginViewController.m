

#import "LoginViewController.h"

@interface LoginViewController ()
{
    BOOL islogged;
}
@property (strong) NSMutableArray *users;

@end

@implementation LoginViewController

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self clear];
    
    //check existing login available in userdefaults ,if it available navigate to NotesList view screen.
    islogged = [[NSUserDefaults standardUserDefaults]stringForKey:@"login"];
    if(islogged)
    {
        UIStoryboard *board=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc=[board instantiateViewControllerWithIdentifier:@"NotesListView"];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doLogin:(id)sender {
    NSArray *users;
    NSString *email=self.userEmail.text;
    NSString *password=self.userPassword.text;
    
    //check whether user available or not in UserDetail table.
    // NSData *encryptedPass=[password dataUsingEncoding:NSUTF8StringEncoding];
   NSString *userPassword=[SSKeychain passwordForService:@"notes_App" account:email];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserDetail"];
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"(email == %@)",email];
    [fetchRequest setPredicate:predicateID];
    users =[[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if ([users count]>0 && [password isEqualToString:userPassword]) {
        
        //[self clear];
        
        NSManagedObject *user=[users objectAtIndex:0];
        //save logged user information in Userdefaults
        [[NSUserDefaults standardUserDefaults] setObject:[user valueForKey:@"name"]forKey:@"loginUserName"];
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"loginUserEmail"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //navigate to next story board
        UIStoryboard *board=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc=[board instantiateViewControllerWithIdentifier:@"NotesListView"];
        [self presentViewController:vc animated:YES completion:nil];
        
    }else
    {
        //alert for invalid username and password
        UIAlertView *alertMessage=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Kindly Enter valid details, If you are new user kindly signup first "delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alertMessage show];
    }
    
}

-(void) clear
{
    self.userEmail.text=@"";
    self.userPassword.text=@"";
}

@end

