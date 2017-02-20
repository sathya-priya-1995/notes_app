

#import "SignupViewController.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

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
- (IBAction)saveUserDetail:(id)sender {
    NSString *userName=self.name.text;
    NSString *userEmail=self.email.text;
    NSString *userPassword=self.password.text;
    
    BOOL isValid=[self validate:userName email:userEmail pass:userPassword];
    if (isValid)
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"UserDetail" inManagedObjectContext:context];
        [newUser setValue:userName forKey:@"name"];
        [newUser setValue:userEmail forKey:@"email"];
        [newUser setValue:userPassword forKey:@"password"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else{
            self.name.text=@"";
            self.email.text=@"";
            self.password.text=@"";
            
            UIAlertView *alertMessage=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Registered Successfully"delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alertMessage show];
        }
        
    }
    
}
-(BOOL)validate:(NSString*)userName email:(NSString*)userEmail pass:(NSString*)password
{
    if(![userName isEqual:@""]&& ![userEmail isEqual:@""]&&![password isEqual:@""])
    {
        BOOL validEmail=[self validateEmail:userEmail];
        BOOL validPassword=[self validatePassword:password];
        if(!validEmail)
        {
            UIAlertView *alertMessage=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Enter valid email"delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alertMessage show];
            return false;
            
        }
        if (!validPassword) {
            UIAlertView *alertMessage=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Enter valid password"delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alertMessage show];
            return false;
        }
        
        return true;
    }else
    {
        UIAlertView *alertMessage=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Fields can not be empty"delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alertMessage show];
    }
    
    return false;
}
-(BOOL) validateEmail:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    if (([emailTest evaluateWithObject:email] == YES))
    {
        return true;
    }
    return false;
}

-(BOOL) validatePassword:(NSString*)password
{
    NSString *passwordRegex=@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{6,}";
    NSPredicate *passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passwordRegex];
    if (([passTest evaluateWithObject:password] == YES))
    {
        return true;
    }
    return false;
}

@end
