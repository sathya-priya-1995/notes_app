

#import "NoteEditViewController.h"

@interface NoteEditViewController ()
{
    NSString *loginUserEmail;
    //UIPickerView *picker;
   // NSArray *colorArray;
   // NSArray *fontArray;
   // NSArray *fontStyleArray;
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
       // _textView=self.selectedNote;
        _textView.attributedText=[self.selectedNote valueForKey:@"note"];
    }else{
        _textView.attributedText=[[NSMutableAttributedString alloc] init];
    }
   
    
   // [[_textView.attributedText mutableString] setString:@""];
    
     toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0,100, 50)];
    toolBar.barStyle=UIBarStyleDefault;
    UIImage *boldImage = [UIImage imageNamed:@"bold@2x.png"];
    UIImage *italicImage = [UIImage imageNamed:@"italic@2x.png"];
    UIImage *underLineImage = [UIImage imageNamed:@"underline@2x.png"];
    UIImage *justFullImage=[UIImage imageNamed:@"justifyfull@2x.png"];
    UIImage *justLeftImage=[UIImage imageNamed:@"justifyleft.png"];
    UIImage *justRightImage=[UIImage imageNamed:@"justifyright@2x.png"];


    
    
    toolBar.items=[NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithImage:boldImage landscapeImagePhone:boldImage style:UIBarButtonItemStyleBordered target:self action:@selector(makeBold:)],
                   [[UIBarButtonItem alloc] initWithImage:italicImage landscapeImagePhone:italicImage style:UIBarButtonItemStyleBordered target:self action:@selector(makeItalic:)],
                   [[UIBarButtonItem alloc]initWithImage:underLineImage landscapeImagePhone:underLineImage style:UIBarButtonItemStyleBordered target:self action:@selector(underlineText:)],
                   [[UIBarButtonItem alloc]initWithImage:justLeftImage landscapeImagePhone:justLeftImage style:UIBarButtonItemStyleBordered target:self action:@selector(alignTextLeft:)],
                   [[UIBarButtonItem alloc]initWithImage:justRightImage landscapeImagePhone:justRightImage style:UIBarButtonItemStyleBordered target:self action:@selector(alignTextRight:)],
                   [[UIBarButtonItem alloc]initWithImage:justFullImage landscapeImagePhone:justFullImage style:UIBarButtonItemStyleBordered target:self action:@selector(centerText:)],
                   
                   [[UIBarButtonItem alloc]initWithTitle:@"Black" style:UIBarButtonItemStyleBordered target:self action:@selector(makeTextColorBlack:)],
                   [[UIBarButtonItem alloc]initWithTitle:@"Red" style:UIBarButtonItemStyleBordered target:self action:@selector(makeTextColorRed:)],
                   [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(dissmissKeyboard:)],nil];
    //                   [[UIBarButtonItem alloc]initWithTitle:@"font" style:UIBarButtonItemStyleBordered target:self action:@selector(doneClicked)],
     [toolBar sizeToFit];
    
//    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolBar.frame.size.height, 350, 300)];
//    colorArray=[[NSArray alloc]initWithObjects:@"red",@"blue",@"green",@"black",nil];
//    fontArray=[[NSArray alloc]initWithObjects:@"2",@"3",@"5",@"6",nil];
//    fontStyleArray=[[NSArray alloc]initWithObjects:@"Arial",@"Times of Roman",nil];
//  
//    
//    inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, toolBar.frame.size.height + picker.frame.size.height)];
//    inputView.backgroundColor = [UIColor clearColor];
//    [inputView addSubview:picker];
//    [inputView addSubview:toolBar];
   
    self.textView.inputAccessoryView=toolBar;
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addOrRemoveFontTraitWithName:(NSString *)traitName andValue:(uint32_t)traitValue{
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


-(void)setParagraphAlignment:(NSTextAlignment)newAlignment{
    NSRange selectedRange = [_textView selectedRange];
    
    NSMutableParagraphStyle *newParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [newParagraphStyle setAlignment:newAlignment];
    
    NSDictionary *dict = @{NSParagraphStyleAttributeName: newParagraphStyle};
    [_textView.textStorage beginEditing];
    [_textView.textStorage setAttributes:dict range:selectedRange];
    [_textView.textStorage endEditing];
    
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


- (IBAction)makeTextColorBlack:(id)sender {
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

-(IBAction)dissmissKeyboard:(id)sender
{
    [_textView resignFirstResponder];
}


- (IBAction)saveNote:(id)sender {
    
    NSString *noteText=_textView.attributedText;
    
    if([noteText length]>0)
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        if (self.selectedNote!=nil)
        {
            //NSManagedObjectID *moID = [self.selectedNote objectID];
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
     [self dismissViewControllerAnimated:YES completion:nil];
}

/*-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return colorArray.count;
            break;
        case 1:
            return fontArray.count;
            break;
        case 2:
            return fontStyleArray.count;
            break;
            
        default:
            break;
    }
    return 0;
}
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component

{
    switch (component) {
        case 0:
            return [colorArray objectAtIndex:row];
            break;
        case 1:
            return [fontArray objectAtIndex:row];
            break;
        case 2:
            return [fontStyleArray objectAtIndex:row];
            break;
        default:
            break;
    }
    return nil;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *s;
    switch (component) {
        case 0:
            s=[NSString stringWithFormat:@"%@",[colorArray objectAtIndex:row]];
            NSLog(@ "%@",s);
            picker.hidden=YES;
            break;
        case 1:
            s=[NSString stringWithFormat:@"%@",[fontArray objectAtIndex:row]];
            NSLog(@ "%@",s);
            picker.hidden=YES;
            break;
        case 2:
            s=[NSString stringWithFormat:@"%@",[fontStyleArray objectAtIndex:row]];
            NSLog(@ "%@",s);
            picker.hidden=YES;
            break;
        default:
            break;
    }
}

- (void)doneClicked {
    
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = NO;
    [self.view addSubview:picker];
    self.textView.inputAccessoryView=toolBar;
   // [_textView resignFirstResponder];
}*/

@end
