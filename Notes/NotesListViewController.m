

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
    self.navigationItem.rightBarButtonItems;
    
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
            NSLog(@"");
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
        [cell.textLabel setAttributedText:[note valueForKey:@"title"]];
    }else
    {
         NSManagedObject *note = [notesArray objectAtIndex:indexPath.row];
        [cell.textLabel setAttributedText:[note valueForKey:@"title"]];
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

//sync with drobox
- (IBAction)syncWithDropbox:(id)sender {
    [self didPressLink];
}
//if dropbox connection is not available then make connection else show alert to user.
- (void)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }else
    {
        UIAlertView *alertMessage=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"DropBox sync enabled Already"delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alertMessage show];
        NSLog(@"linked");
    }
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
     NSMutableArray *titleArray=[[NSMutableArray alloc]init];
    NSMutableAttributedString *attrVal;
     NSMutableAttributedString *arrtitle;
    for(NSManagedObject *note in notesArray)
    {
        @try {
            attrVal=[note valueForKey:@"note"];
            [stringArray addObject:attrVal.string];
            arrtitle=[note valueForKey:@"title"];
            [titleArray addObject:arrtitle.string];
        }
        @catch (NSException *exception) {
            NSLog(@"");
        }
    }
    int i=0;
  
        searchResultArray=[[NSMutableArray alloc]init];
        for(NSString *string in stringArray){
            
            NSRange stringRange=[string rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange titleRange=[[titleArray objectAtIndex:i] rangeOfString:searchText options:NSCaseInsensitiveSearch];

            if(stringRange.location !=NSNotFound || titleRange.location !=NSNotFound ){
                
                [searchResultArray addObject:[notesArray objectAtIndex:i]];
            }
            i++;
          }
    [self.tableview reloadData];
}

//delete selected note
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //delete file from Dropbox if session is available
    if([[DBSession sharedSession] isLinked])
    {
        NSManagedObject *deletedObj=[notesArray objectAtIndex:indexPath.row];
        NSAttributedString *str=[deletedObj valueForKey:@"title"];
        NSString *val=[str string];
        NSString *fname = [ val stringByAppendingString:@".txt"];
        NSString *dir=@"/";
        NSString *path = [NSString stringWithFormat: @"%@%@", dir,fname];
        [self.restClient deletePath:path];
    }
    //delete data from table
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

//method for get client to communicate with dropbox
- (DBRestClient *)restClient
{
    if (restClient == nil) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}


@end
