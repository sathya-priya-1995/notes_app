

#import "SignupViewController.h"
//#import "CommonCrypto/CommonCryptor.h"

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
    _email.placeholder=@"Email";
    _name.placeholder=@"Name";
    _password.placeholder=@"Password";
    _confirmationPassword.placeholder=@"Conformation Password";
    
    
    _registerBtn.layer.cornerRadius = 10;
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveUserDetail:(id)sender {
    NSString *userName=self.name.text;
    NSString *userEmail=self.email.text;
    NSString *userPassword=self.password.text;
    NSString *confirmationPassword=self.confirmationPassword.text;
    
    BOOL isValid=[self validate:userName email:userEmail pass:userPassword conformPass:confirmationPassword];
    if (isValid)
    {
        //save user datail.
        [SSKeychain setPassword:userPassword forService:@"notes_App" account:userEmail];
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"UserDetail" inManagedObjectContext:context];
        [newUser setValue:userName forKey:@"name"];
        [newUser setValue:userEmail forKey:@"email"];
        [newUser setValue:@"dummy" forKey:@"password"];
        
                //empty fields
        self.name.text=@"";
        self.email.text=@"";
        self.password.text=@"";
        self.confirmationPassword.text=@"";
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else{
            //[controller dismissViewControllerAnimated:YES completion:nil];
            UIAlertView *alertMessage=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Registered Successfully"delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alertMessage show];
            [self.navigationController popViewControllerAnimated:YES];
            }
    }
}

//validate username and password
-(BOOL)validate:(NSString*)userName email:(NSString*)userEmail pass:(NSString*)password conformPass:(NSString*)confirmationPassword
{
    //empty check
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
        if(![password isEqualToString:confirmationPassword])
        {
            UIAlertView *alertMessage=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Pssword and confirmation password should be same" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alertMessage show];
            return false;
        }else if (!validPassword) {
            UIAlertView *alertMessage=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Enter valid password[It should have minimum 6 character and one uppercase,lowercase,special character,number]" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
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
//validate email
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
//validate password
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
