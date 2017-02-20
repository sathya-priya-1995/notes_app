

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface NoteEditViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)saveNote:(id)sender;

@property NSManagedObject *selectedNote;
@end
