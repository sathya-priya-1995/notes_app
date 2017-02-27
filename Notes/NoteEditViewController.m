

#import "NoteEditViewController.h"
//#import "MBProgressHUD.h"

@interface NoteEditViewController ()
{
    NSString *loginUserEmail;
    UIToolbar *toolBar;
    UIView *inputView;
    NSMutableDictionary *revPath;
    NSString *seletedNoteTitle;
    NSString *seletedNoteRevision;
   
}
@end

@implementation NoteEditViewController

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
    
    if (!_loadData) {
        _loadData = @"/";
    }
    
    revPath=[[NSMutableDictionary alloc]init];
    loginUserEmail = [[NSUserDefaults standardUserDefaults]stringForKey:@"loginUserEmail"];
    
    if (self.selectedNote!=nil) {
        _textView.attributedText=[self.selectedNote valueForKey:@"note"];
        _titleView.attributedText=[self.selectedNote valueForKey:@"title"];
        seletedNoteTitle=_titleView.text;
         [self fetchAllDropboxData];
    }else{
//        _textView.attributedText=[[NSMutableAttributedString alloc] init];
//        _titleView.attributedText=[[NSMutableAttributedString alloc] init];
        _textView.attributedText=[[NSMutableAttributedString alloc] initWithString:@"Content"];
        _titleView.attributedText=[[NSMutableAttributedString alloc] initWithString:@"Title"];
    }
    
     toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0,100, 50)];
    toolBar.barStyle=UIBarStyleDefault;
    UIImage *boldImage = [UIImage imageNamed:@"bold@2x.png"];
    UIImage *italicImage = [UIImage imageNamed:@"italic@2x.png"];
    UIImage *underLineImage = [UIImage imageNamed:@"underline@2x.png"];
    UIImage *justFullImage=[UIImage imageNamed:@"justifyfull@2x.png"];
    UIImage *justLeftImage=[UIImage imageNamed:@"justifyleft.png"];
    UIImage *justRightImage=[UIImage imageNamed:@"justifyright@2x.png"];

    //Toolbar holds all buttons related to style of text
    toolBar.items=[NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithImage:boldImage landscapeImagePhone:boldImage style:UIBarButtonItemStyleBordered target:self action:@selector(makeBold:)],
                   [[UIBarButtonItem alloc] initWithImage:italicImage landscapeImagePhone:italicImage style:UIBarButtonItemStyleBordered target:self action:@selector(makeItalic:)],
                   [[UIBarButtonItem alloc]initWithImage:underLineImage landscapeImagePhone:underLineImage style:UIBarButtonItemStyleBordered target:self action:@selector(underlineText:)],
                   [[UIBarButtonItem alloc]initWithImage:justLeftImage landscapeImagePhone:justLeftImage style:UIBarButtonItemStyleBordered target:self action:@selector(alignTextLeft:)],
                   [[UIBarButtonItem alloc]initWithImage:justRightImage landscapeImagePhone:justRightImage style:UIBarButtonItemStyleBordered target:self action:@selector(alignTextRight:)],
                   [[UIBarButtonItem alloc]initWithImage:justFullImage landscapeImagePhone:justFullImage style:UIBarButtonItemStyleBordered target:self action:@selector(centerText:)],
                   
                   [[UIBarButtonItem alloc]initWithTitle:@"Black" style:UIBarButtonItemStyleBordered target:self action:@selector(makeTextColorBlack:)],
                   [[UIBarButtonItem alloc]initWithTitle:@"Red" style:UIBarButtonItemStyleBordered target:self action:@selector(makeTextColorRed:)],
                   [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(dissmissKeyboard:)],nil];
     [toolBar sizeToFit];
    
    //set toolbar to inputAccessoryView
    self.textView.inputAccessoryView=toolBar;
    self.titleView.inputAccessoryView=toolBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//this method is used to make a text as bold,italic.
-(void)addOrRemoveFontTraitWithName:(NSString *)traitName andValue:(uint32_t)traitValue{
    
    @try {
        NSRange selectedRange = [_textView selectedRange];
        
        NSDictionary *currentAttributesDict = [_textView.textStorage attributesAtIndex:selectedRange.location
                                                                        effectiveRange:nil];
        
       // NSLog(@"%@",_textView.textStorage);
        UIFont *currentFont = [currentAttributesDict objectForKey:NSFontAttributeName];
        //int underLine=[currentAttributesDict objectForKey:NSUnderlineStyleAttributeName];
        
        UIFontDescriptor *fontDescriptor = [currentFont fontDescriptor];
        //UIFont *updatedFont =nil;
        NSString *fontNameAttribute = [[fontDescriptor fontAttributes] objectForKey:UIFontDescriptorNameAttribute];
        UIFontDescriptor *changedFontDescriptor;
        
        if ([fontNameAttribute rangeOfString:traitName].location == NSNotFound) {
            uint32_t existingTraitsWithNewTrait = [fontDescriptor symbolicTraits] | traitValue;
            changedFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:existingTraitsWithNewTrait];
            UIFont *updatedFont = [UIFont fontWithDescriptor:changedFontDescriptor size:0.0];
            NSDictionary *dict = @{NSFontAttributeName: updatedFont};
            [_textView.textStorage beginEditing];
            [_textView.textStorage addAttributes:dict range:selectedRange];
            [_textView.textStorage endEditing];
        }
        else{
            uint32_t existingTraitsWithoutTrait = [fontDescriptor symbolicTraits] & ~traitValue;
            changedFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:existingTraitsWithoutTrait];
            UIFont *updatedFont = [UIFont fontWithDescriptor:changedFontDescriptor size:0.0];
            NSDictionary *dict = @{NSFontAttributeName: updatedFont};
            [_textView.textStorage beginEditing];
            [_textView.textStorage addAttributes:dict range:selectedRange];
            [_textView.textStorage endEditing];
        }
        //[self select:@selector(makeTextColorBlack:)]
        //[@selector(makeTextColorBlack:)];
        
        //UIFont *updatedFont = [UIFont fontWithDescriptor:changedFontDescriptor size:0.0];
       // NSDictionary *dict = @{NSFontAttributeName: updatedFont};
        
       // [_textView.textStorage beginEditing];
        //[_textView.textStorage setAttributes:dict range:selectedRange];
        //[_textView.textStorage endEditing];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception while addOrRemoveFontTraitWithName");
    }
}


-(void)setParagraphAlignment:(NSTextAlignment)newAlignment{
    
    @try {
        NSRange selectedRange = [_textView selectedRange];
        
        if (selectedRange.length==0) {
            int endRange=_textView.attributedText.length;
            selectedRange=NSMakeRange (0, endRange);
        }
        
        NSMutableParagraphStyle *newParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        [newParagraphStyle setAlignment:newAlignment];
        
        NSDictionary *dict = @{NSParagraphStyleAttributeName: newParagraphStyle};
        [_textView.textStorage beginEditing];
        [_textView.textStorage addAttributes:dict range:selectedRange];
        [_textView.textStorage endEditing];

    }
    @catch (NSException *exception) {
        NSLog(@"Exception while setParagraphAlignment");
    }
}


#pragma mark - IBAction method implementation

- (IBAction)makeBold:(id)sender {
    [self addOrRemoveFontTraitWithName:@"Bold" andValue:UIFontDescriptorTraitBold];
}


- (IBAction)makeItalic:(id)sender {
    [self addOrRemoveFontTraitWithName:@"Italic" andValue:UIFontDescriptorTraitItalic];
}


- (IBAction)underlineText:(id)sender {
    
    @try {
        NSRange selectedRange = [_textView selectedRange];
        
        NSDictionary *currentAttributesDict = [_textView.textStorage attributesAtIndex:selectedRange.location
                                                                        effectiveRange:nil];
        
        NSDictionary *dict;
        
        if ([currentAttributesDict objectForKey:NSUnderlineStyleAttributeName] == nil ||
            [[currentAttributesDict objectForKey:NSUnderlineStyleAttributeName] intValue] == 0) {
            dict = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInt:1]};
        }
        else{
            dict = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInt:0]};
        }
        
        [_textView.textStorage beginEditing];
        [_textView.textStorage addAttributes:dict range:selectedRange];
        [_textView.textStorage endEditing];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception while underlineText");
    }
}


- (IBAction)alignTextLeft:(id)sender {
    [self setParagraphAlignment:NSTextAlignmentLeft];
}


- (IBAction)centerText:(id)sender {
    [self setParagraphAlignment:NSTextAlignmentCenter];
}


- (IBAction)alignTextRight:(id)sender {
    [self setParagraphAlignment:NSTextAlignmentRight];
}


- (IBAction)makeTextColorRed:(id)sender {
    @try
    {
        NSRange selectedRange = [_textView selectedRange];
        
        NSDictionary *currentAttributesDict = [_textView.textStorage attributesAtIndex:selectedRange.location
                                                                        effectiveRange:nil];
        
        if ([currentAttributesDict objectForKey:NSForegroundColorAttributeName] == nil ||
            [currentAttributesDict objectForKey:NSForegroundColorAttributeName] != [UIColor redColor]) {
            
            NSDictionary *dict = @{NSForegroundColorAttributeName: [UIColor redColor]};
            [_textView.textStorage beginEditing];
            [_textView.textStorage addAttributes:dict range:selectedRange];
            [_textView.textStorage endEditing];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception while makeTextColorRed");
    }
}


- (IBAction)makeTextColorBlack:(id)sender {
    
    @try {
        NSRange selectedRange = [_textView selectedRange];
        
        NSDictionary *currentAttributesDict = [_textView.textStorage attributesAtIndex:selectedRange.location
                                                                        effectiveRange:nil];
        
        if ([currentAttributesDict objectForKey:NSForegroundColorAttributeName] == nil ||
            [currentAttributesDict objectForKey:NSForegroundColorAttributeName] != [UIColor blackColor]) {
            
            NSDictionary *dict = @{NSForegroundColorAttributeName: [UIColor blackColor]};
            [_textView.textStorage beginEditing];
            [_textView.textStorage addAttributes:dict range:selectedRange];
            [_textView.textStorage endEditing];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception while makeTextColorBlack");
    }
}

-(IBAction)dissmissKeyboard:(id)sender
{
    [_textView resignFirstResponder];
}


//save note to table
- (IBAction)saveNote:(id)sender {
    
    @try {
        NSString *noteTitle=_titleView.attributedText;
        NSString *noteText=_textView.attributedText;
        NSString *noteTitleText=_titleView.text;
        NSString *notetext=_textView.text;
        
        //&& ![noteText isEqualToString:@"Content"] && ![noteTitle isEqualToString:@"Title"]
        if([noteText length]>0 && ( ![notetext isEqualToString:@"Content"] || ![noteTitleText isEqualToString:@"Title"]))
        {
            NSManagedObjectContext *context = [self managedObjectContext];
            if (self.selectedNote!=nil)
            {
                [self.selectedNote setValue:noteTitle forKey:@"title"];
                 [self.selectedNote setValue:noteText forKey:@"note"];
            }else
            {
                NSManagedObject *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Notes" inManagedObjectContext:context];
                [newNote setValue:loginUserEmail forKey:@"email"];
                [newNote setValue:noteText forKey:@"note"];
                [newNote setValue:noteTitle forKey:@"title"];
            }
            NSError *error = nil;
            // Save the object to persistent store
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
           [self saveInDropBox];
        }else
        {
            UIAlertView *alertMessage=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Empty Note can't be saved"delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alertMessage show];
            [self dismissViewControllerAnimated:YES completion:nil];
            

        }
    }
    @catch (NSException *exception) {
         NSLog(@"Exception while saveNote");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

-(void) saveInDropBox
{
    [self didPressLink];
}
//if session available the file will stored(pushed) to dropbox else noteslistview screen will show
- (void)didPressLink {
    if ([[DBSession sharedSession] isLinked]) {
        [self uploadFileToDropBox];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (DBRestClient *)restClient
{
    if (restClient == nil) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

-(void)fetchAllDropboxData
{
    if ([[DBSession sharedSession] isLinked]) {
        [self.restClient loadMetadata:_loadData];
    }
}

//store file in dropbox
-(void)uploadFileToDropBox
{
    NSString *text = _textView.text;
    //Title of note set as filename
    NSString *fname = [_titleView.text stringByAppendingString:@".txt"];

    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:fname];
    [text writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //file is stored in root directory
    NSString *destDir = @"/";
    [self.restClient uploadFile:fname toPath:destDir withParentRev:seletedNoteRevision fromPath:localPath];
     
    
}
#pragma mark - DBRestClientDelegate Methods for Load Data
//get the revision for already stored file
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata *)metadata
{
    if([metadata.path isEqual:@"/"])
    {
        for (int i = 0; i < [metadata.contents count]; i++) {
            DBMetadata *data = [metadata.contents objectAtIndex:i];

                if (data.isDirectory) {
                   // NSLog(@"%@ %@",data.rev,data.filename);
                    [marrUploadData addObject:data];
                }else{
                    if ([data.filename isEqualToString:[seletedNoteTitle stringByAppendingString:@".txt"]])
                    {
                        seletedNoteRevision=data.rev;
                    }
                    //[revPath setValue:data.rev forKey:data.filename];
                }
        }
    }else{
        for (int i = 0; i < [metadata.contents count]; i++) {
            DBMetadata *data = [metadata.contents objectAtIndex:i];
            
            if (data.isDirectory) {
                //NSLog(@"%@ %@",data.rev,data.filename);
                [marrUploadData addObject:data];
            }
            
            
        }
    }
}

-(void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath
{
  
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                   message:@"File synced with dropbox successfully."
                                                  delegate:nil
                                         cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
    [alert show];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                   message:[error localizedDescription]
                                                  delegate:nil
                                         cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
    [alert show];
     [self dismissViewControllerAnimated:YES completion:nil];
}

@end
