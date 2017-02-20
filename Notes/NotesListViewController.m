

#import "NotesListViewController.h"

@interface NotesListViewController ()
{
    NSArray *notesArray;
    NSString *loginUserEmail;
     NSMutableArray *searchResultArray;
}


@end

@implementation NotesListViewController

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
    
    loginUserEmail = [[NSUserDefaults standardUserDefaults]stringForKey:@"loginUserEmail"];
    
    
    
    // Do any additional setup after loading the view.
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Notes"];
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"(email == %@) ",loginUserEmail];
    [fetchRequest setPredicate:predicateID];
    notesArray =[[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    //NSManagedObject *device = [notesArray objectAtIndex:0];
    //NSString *str=[device valueForKey:@"note"];
   // NSLog(@"%@",str);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Notes"];
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"(email == %@) ",loginUserEmail];
    [fetchRequest setPredicate:predicateID];
    notesArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableview reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)indexPath {
    
    if ([[segue identifier] isEqualToString:@"pushDetailView"]) {
        NoteEditViewController *controller = segue.destinationViewController;
        // NSManagedObject *selectedNote = [notesArray objectAtIndex:indexPath.row];
        
        @try {
            if ([indexPath valueForKey:@"note"]!=nil ) {
                controller.selectedNote=indexPath;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"");
        }
        
        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [searchResultArray count];
    }else{
         return [notesArray count];
    }
   
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"notesViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    // Configure the cell...

    if (tableView == self.searchDisplayController.searchResultsTableView) {
       NSManagedObject *note = [searchResultArray objectAtIndex:indexPath.row];
        [cell.textLabel setAttributedText:[note valueForKey:@"note"]];
    }else
    {
         NSManagedObject *note = [notesArray objectAtIndex:indexPath.row];
        [cell.textLabel setAttributedText:[note valueForKey:@"note"]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     if (tableView == self.searchDisplayController.searchResultsTableView)
     {
         NSManagedObject *selectedNote = [searchResultArray objectAtIndex:indexPath.row];
         [self performSegueWithIdentifier:@"pushDetailView" sender:selectedNote];
     }else
     {
         NSManagedObject *selectedNote = [notesArray objectAtIndex:indexPath.row];
         [self performSegueWithIdentifier:@"pushDetailView" sender:selectedNote];
     }
    
}
- (IBAction)doLogOut:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginUserEmail"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"login"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self updateSearchArray:searchText];
    //NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"note contains[c] %@", searchText];
    //searchResultArray = [notesArray filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}
-(void)updateSearchArray:(NSString *)searchText
{
     NSMutableArray *stringArray=[[NSMutableArray alloc]init];
    NSString *text;
    NSMutableAttributedString *cString;
    for(NSManagedObject *note in notesArray)
    {
        cString=[note valueForKey:@"note"];
        [stringArray addObject:cString.string];
    }
    int i=0;
  
        searchResultArray=[[NSMutableArray alloc]init];
        for(NSString *string in stringArray){
            
            NSRange stringRange=[string rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(stringRange.location !=NSNotFound){
                
                [searchResultArray addObject:[notesArray objectAtIndex:i]];
            }
            i++;
          }
    [self.tableview reloadData];
}

@end
