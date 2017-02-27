

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <DropboxSDK/DropboxSDK.h>

@interface NoteEditViewController : UIViewController<DBRestClientDelegate>

{
    NSMutableArray *marrUploadData;
    DBRestClient *restClient;
}
@property (weak, nonatomic) IBOutlet UITextView *titleView;

@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)saveNote:(id)sender;

@property NSManagedObject *selectedNote;
@property (nonatomic, strong) NSString *loadData;
@end
