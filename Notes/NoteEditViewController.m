

#import "NoteEditViewController.h"

@interface NoteEditViewController ()
{
    NSString *loginUserEmail;
    UIToolbar *toolBar;
    UIView *inputView;
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
    
     loginUserEmail = [[NSUserDefaults standardUserDefaults]stringForKey:@"loginUserEmail"];
    
    if (self.selectedNote!=nil) {
        _textView.attributedText=[self.selectedNote valueForKey:@"note"];
    }else{
        _textView.attributedText=[[NSMutableAttributedString alloc] init];
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
        
        UIFont *currentFont = [currentAttributesDict objectForKey:NSFontAttributeName];
        
        UIFontDescriptor *fontDescriptor = [currentFont fontDescriptor];
        
        NSString *fontNameAttribute = [[fontDescriptor fontAttributes] objectForKey:UIFontDescriptorNameAttribute];
        UIFontDescriptor *changedFontDescriptor;
        
        if ([fontNameAttribute rangeOfString:traitName].location == NSNotFound) {
            uint32_t existingTraitsWithNewTrait = [fontDescriptor symbolicTraits] | traitValue;
            changedFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:existingTraitsWithNewTrait];
        }
        else{
            uint32_t existingTraitsWithoutTrait = [fontDescriptor symbolicTraits] & ~traitValue;
            changedFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:existingTraitsWithoutTrait];
        }
        
        UIFont *updatedFont = [UIFont fontWithDescriptor:changedFontDescriptor size:0.0];
        
        NSDictionary *dict = @{NSFontAttributeName: updatedFont};
        
        [_textView.textStorage beginEditing];
        [_textView.textStorage setAttributes:dict range:selectedRange];
        [_textView.textStorage endEditing];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception while addOrRemoveFontTraitWithName");
    }
}


-(void)setParagraphAlignment:(NSTextAlignment)newAlignment{
    
    @try {
        NSRange selectedRange = [_textView selectedRange];
        
        NSMutableParagraphStyle *newParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        [newParagraphStyle setAlignment:newAlignment];
        
        NSDictionary *dict = @{NSParagraphStyleAttributeName: newParagraphStyle};
        [_textView.textStorage beginEditing];
        [_textView.textStorage setAttributes:dict range:selectedRange];
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
        [_textView.textStorage setAttributes:dict range:selectedRange];
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
            [_textView.textStorage setAttributes:dict range:selectedRange];
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
            [_textView.textStorage setAttributes:dict range:selectedRange];
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
        NSString *noteText=_textView.attributedText;
        
        if([noteText length]>0)
        {
            NSManagedObjectContext *context = [self managedObjectContext];
            if (self.selectedNote!=nil)
            {
                [self.selectedNote setValue:noteText forKey:@"note"];
            }else
            {
                NSManagedObject *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"Notes" inManagedObjectContext:context];
                [newUser setValue:loginUserEmail forKey:@"email"];
                [newUser setValue:noteText forKey:@"note"];
            }
            NSError *error = nil;
            // Save the object to persistent store
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
        }
    }
    @catch (NSException *exception) {
         NSLog(@"Exception while saveNote");
        
    }
     [self dismissViewControllerAnimated:YES completion:nil];
}

@end
