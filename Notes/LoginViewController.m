

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
    
    islogged = [[NSUserDefaults standardUserDefaults]stringForKey:@"login"];
    if(islogged)
    {
        UIStoryboard *board=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc=[board instantiateViewControllerWithIdentifier:@"NotesListView"];
        [self presentViewController:vc animated:YES completion:nil];
    }
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)doLogin:(id)sender {
    NSArray *users;
    NSString *email=self.userEmail.text;
    NSString *password=self.userPassword.text;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserDetail"];
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"(email == %@) AND (password == %@)",email,password];
    [fetchRequest setPredicate:predicateID];
    users =[[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if ([users count]>0) {
        
        
      //save userdata
        
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"loginUserEmail"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
        UIStoryboard *board=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc=[board instantiateViewControllerWithIdentifier:@"NotesListView"];
        [self presentViewController:vc animated:YES completion:nil];
        
        
        
        //NotesViewController *notesController=[[NotesViewController alloc]init];
        
        // notesController.label = self.label.text;
        
        //[self presentModalViewController:notesController animated:YES];
        //[self presentViewController:notesController animated:YES completion:nil];
        //NotesListViewController *notesController=[[NotesListViewController alloc]init];
        // [self.presentationController delete:notesController];
        // [self performSegueWithIdentifier:@"NotesListViewController" sender:nil];
        //pushViewController: animated: - To Push the view on navigation stack
        // presentModalViewController:nc animated: - To present the view modally.
        
    }else
    {
        UIAlertView *alertMessage=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Kindly Enter valid details, If you are new user kindly signup first "delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alertMessage show];
    }
    
}

@end

