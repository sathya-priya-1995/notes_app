

#import "NotesListViewController.h"

@interface NotesListViewController ()
{
    NSMutableArray *notesArray;
    NSString *loginUserEmail;
    //it holds Search result objects
     NSMutableArray *searchResultArray;
}


@end

@implementation NotesListViewController

//create managed object context
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
    
    //load notes from table based on logged user email
    loginUserEmail = [[NSUserDefaults standardUserDefaults]stringForKey:@"loginUserEmail"];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Notes"];
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"(email == %@) ",loginUserEmail];
    [fetchRequest setPredicate:predicateID];
    notesArray =[[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the Notes from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Notes"];
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"(email == %@) ",loginUserEmail];
    [fetchRequest setPredicate:predicateID];
    notesArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableview reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)indexPath {
    
    //pass selected note from Notes list view to Edit view
    if ([[segue identifier] isEqualToString:@"pushDetailView"]) {
        NoteEditViewController *controller = segue.destinationViewController;
        @try {
            if ([indexPath valueForKey:@"note"]!=nil ) {
                controller.selectedNote=indexPath;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception while push");
        }
     }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    //return row for table view controller
    static NSString *simpleTableIdentifier = @"notesViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
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
    //while logout we will clear all details from userdefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginUsermName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginUserEmail"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"login"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self updateSearchArray:searchText];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}
//it will return search result
-(void)updateSearchArray:(NSString *)searchText
{
     NSMutableArray *stringArray=[[NSMutableArray alloc]init];
    NSMutableAttributedString *attrVal;
    for(NSManagedObject *note in notesArray)
    {
        attrVal=[note valueForKey:@"note"];
        [stringArray addObject:attrVal.string];
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

//delete selected note
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
      NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    [managedObjectContext deleteObject:[notesArray objectAtIndex:indexPath.row]];
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return;
    }
     [notesArray removeObjectAtIndex:indexPath.row];
    
     [self.tableview reloadData];
}

@end
