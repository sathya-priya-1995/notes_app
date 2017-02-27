

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "NoteEditViewController.h"
@interface NotesListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
     DBRestClient *restClient;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
- (IBAction)doLogOut:(id)sender;
- (IBAction)syncWithDropbox:(id)sender;

@end
