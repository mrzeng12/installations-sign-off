//
//  FifteenthDetailView.m
//  MultipleDetailViews
//
//  Created by Helpdesk on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FifteenthDetailView.h"
#import "UIImage+fixOrientation.h"
#import "isql.h"
#import "photoEditor.h"
#import <QuartzCore/QuartzCore.h>
#import "NonRotatingUIImagePickerController ViewController.h"

@implementation FifteenthDetailView

@synthesize imageView1;
@synthesize imageView2;
@synthesize imageView3;
@synthesize imageView4;
@synthesize imageView5;
@synthesize imageView6;
@synthesize imageView7;
@synthesize imageView8;
@synthesize imageButton1;
@synthesize imageButton2;
@synthesize imageButton3;
@synthesize imageButton4;
@synthesize imageButton5;
@synthesize imageButton6;
@synthesize imageButton7;
@synthesize imageButton8;

@synthesize imageData1;
@synthesize imageData2;
@synthesize imageData3;
@synthesize imageData4;
@synthesize imageData5;
@synthesize imageData6;
@synthesize imageData7;
@synthesize imageData8;

@synthesize image1;
@synthesize image2;
@synthesize image3;
@synthesize image4;
@synthesize image5;
@synthesize image6;
@synthesize image7;
@synthesize image8;
@synthesize defaultImage;

@synthesize toolbar;
@synthesize deleteButton1;
@synthesize deleteButton2;
@synthesize deleteButton3;
@synthesize deleteButton4;
@synthesize deleteButton5;
@synthesize deleteButton6;
@synthesize deleteButton7;
@synthesize deleteButton8;
@synthesize editButton1;
@synthesize editButton2;
@synthesize editButton3;
@synthesize editButton4;
@synthesize editButton5;
@synthesize editButton6;
@synthesize editButton7;
@synthesize editButton8;
@synthesize popoverController;

@synthesize nsURL1;
@synthesize nsURL2;
@synthesize nsURL3;
@synthesize nsURL4;
@synthesize nsURL5;
@synthesize nsURL6;
@synthesize nsURL7;
@synthesize nsURL8;
@synthesize scrollview;

@synthesize touchedImageNumber;
@synthesize photoEditorModal;
@synthesize status;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    cameraButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:@"Camera"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(useCamera:)];
    cameraRollButton = [[UIBarButtonItem alloc] 
                                         initWithTitle:@"Photo Album"
                                         style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(useCameraRoll:)];
    NSArray *items = [NSArray arrayWithObjects: cameraButton,
                      cameraRollButton, nil];
    [toolbar setItems:items animated:NO];
    
    [self.imageView1.layer setBorderWidth:1.0f];
    [self.imageView1.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.imageView2.layer setBorderWidth:1.0f];
    [self.imageView2.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.imageView3.layer setBorderWidth:1.0f];
    [self.imageView3.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.imageView4.layer setBorderWidth:1.0f];
    [self.imageView4.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.imageView5.layer setBorderWidth:1.0f];
    [self.imageView5.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.imageView6.layer setBorderWidth:1.0f];
    [self.imageView6.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.imageView7.layer setBorderWidth:1.0f];
    [self.imageView7.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.imageView8.layer setBorderWidth:1.0f];
    [self.imageView8.layer setBorderColor:[UIColor grayColor].CGColor];
    
    defaultImage = [UIImage imageNamed:@"camera-icon.png"];
    
    self.image1 = defaultImage;
    self.image2 = defaultImage;
    self.image3 = defaultImage;
    self.image4 = defaultImage;
    self.image5 = defaultImage;
    self.image6 = defaultImage;
    self.image7 = defaultImage;
    self.image8 = defaultImage;
    
    //self.imageView1.exclusiveTouch = YES;
    photoEditorModal = [[photoEditor alloc] initWithNibName:@"photoEditor" bundle:[NSBundle mainBundle]];
            
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(finshedEditingPhotos)
     name:@"finshedEditingPhotos" object:nil];    
    
    self.status = 0;
    [self checkComplete];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [scrollview setContentSize:CGSizeMake(703, 1080)];
    [scrollview setFrame:CGRectMake(0, 0, 703, 586)];
    //[scrollview scrollRectToVisible:CGRectMake(0, 0, 703, 586) animated:YES];    
    [scrollview flashScrollIndicators];
    
    /*
    isql *database = [isql initialize];
    
    if ([database.current_photo_file_directory_1 length] > 10) {
        self.touchedImageNumber = 1;
        [self loadImageWithNSURL:[NSURL URLWithString:database.current_photo_file_directory_1]];
    }
    
     */
    
    //NSLog(@"%@", database.current_photo_file_directory_1);
     
}

- (void)viewDidUnload
{
    [self setEditButton8:nil];
    [self setEditButton7:nil];
    [self setEditButton6:nil];
    [self setEditButton5:nil];
    [self setEditButton4:nil];
    [self setEditButton3:nil];
    [self setEditButton2:nil];
    [self setEditButton1:nil];
    [self setImageButton8:nil];
    [self setImageButton7:nil];
    [self setImageButton6:nil];
    [self setImageButton5:nil];
    [self setImageButton4:nil];
    [self setImageButton3:nil];
    [self setImageButton2:nil];
    [self setImageButton1:nil];
    [self setDeleteButton8:nil];
    [self setDeleteButton7:nil];
    [self setDeleteButton6:nil];
    [self setDeleteButton5:nil];
    [self setImageView8:nil];
    [self setImageView7:nil];
    [self setImageView6:nil];
    [self setImageView5:nil];
    [self setScrollview:nil];
    
    [self setDeleteButton4:nil];
    [self setDeleteButton3:nil];
    [self setDeleteButton2:nil];
    [self setDeleteButton1:nil];
    self.imageView1 = nil;
    self.imageView2 = nil;
    self.imageView3 = nil;
    self.imageView4 = nil;
    self.popoverController = nil;
    self.toolbar = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (IBAction) useCamera: (id)sender
{
    [self.popoverController dismissPopoverAnimated:FALSE];
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        if (imagePicker == nil) {
            imagePicker = [[NonRotatingUIImagePickerController_ViewController alloc] init];
            NSLog(@"generate imagePicker");
        }
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = NO;
        //[self presentModalViewController:imagePicker animated:YES];
        [self presentViewController:imagePicker animated:NO completion:nil];
        newMedia = YES;
    }
    touchedImageNumber = 0;
}

- (IBAction) useCameraRoll: (id)sender
{
    if ([self.popoverController isPopoverVisible]) {
        [self.popoverController dismissPopoverAnimated:YES];
        //[popoverController release];
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            if (imagePicker == nil) {
                imagePicker = [[NonRotatingUIImagePickerController_ViewController alloc] init];
                NSLog(@"generate imagePicker");
            }
            imagePicker.delegate = self;
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                      (NSString *) kUTTypeImage,
                                      nil];
            imagePicker.allowsEditing = NO;
            
            self.popoverController = [[UIPopoverController alloc]
                                      initWithContentViewController:imagePicker];
            
            popoverController.delegate = self;
            
            [self.popoverController 
             presentPopoverFromBarButtonItem:sender
             permittedArrowDirections:UIPopoverArrowDirectionUp
             animated:YES];
            
            newMedia = NO;
        }
    }
    touchedImageNumber = 0;
}


-(void)loadImageWithImage: (UIImage *)image atIndex: (int) index{
    
    //isql *database = [isql initialize];
    UIImage *copyOfOriginalImage = image;
    
    copyOfOriginalImage = [copyOfOriginalImage fixOrientation];
    switch (index) {
                    
        case 1:
        {
            self.image1 = copyOfOriginalImage;
            self.deleteButton1.hidden = FALSE;
            self.editButton1.hidden = FALSE;
            self.imageView1.contentMode = UIViewContentModeScaleAspectFit;
            imageView1.image = self.image1;
            break;
        }
        case 2:
        {
            self.image2 = copyOfOriginalImage;
            self.deleteButton2.hidden = FALSE;
            self.editButton2.hidden = FALSE;
            self.imageView2.contentMode = UIViewContentModeScaleAspectFit;
            imageView2.image = self.image2;
            break;
        }
        case 3:
        {
            self.image3 = copyOfOriginalImage;
            self.deleteButton3.hidden = FALSE;
            self.editButton3.hidden = FALSE;
            self.imageView3.contentMode = UIViewContentModeScaleAspectFit;
            imageView3.image = self.image3;
            break;
        }
        case 4:
        {
            self.image4 = copyOfOriginalImage;
            self.deleteButton4.hidden = FALSE;
            self.editButton4.hidden = FALSE;
            self.imageView4.contentMode = UIViewContentModeScaleAspectFit;
            imageView4.image = self.image4;
            break;
        }
        case 5:
        {
            self.image5 = copyOfOriginalImage;
            self.deleteButton5.hidden = FALSE;
            self.editButton5.hidden = FALSE;
            self.imageView5.contentMode = UIViewContentModeScaleAspectFit;
            imageView5.image = self.image5;
            break;
        }
        case 6:
        {
            self.image6 = copyOfOriginalImage;
            self.deleteButton6.hidden = FALSE;
            self.editButton6.hidden = FALSE;
            self.imageView6.contentMode = UIViewContentModeScaleAspectFit;
            imageView6.image = self.image6;
            break;
        }
        case 7:
        {
            self.image7 = copyOfOriginalImage;
            self.deleteButton7.hidden = FALSE;
            self.editButton7.hidden = FALSE;
            self.imageView7.contentMode = UIViewContentModeScaleAspectFit;
            imageView7.image = self.image7;
            break;
        }
        case 8:
        {
            self.image8 = copyOfOriginalImage;
            self.deleteButton8.hidden = FALSE;
            self.editButton8.hidden = FALSE;
            self.imageView8.contentMode = UIViewContentModeScaleAspectFit;
            imageView8.image = self.image8;
            break;
        }
        default:
            break;
    }
    
    //if use camera or album, check complete;
    //this prevent checkComplete in this function when loadViewsFromVariables
    
    if (self.status != 0) {
        [self checkComplete];
        //[database saveVariableToLocalDest];
    }
    
}

- (IBAction)editButtonClicked:(id)sender {
    
    isql *database = [isql initialize];
    
    self.status = 3;
    switch ([sender tag]) {
        case 1:
            database.editingNSUrl = database.current_photo_file_directory_1;
            break;
        case 2:
            database.editingNSUrl = database.current_photo_file_directory_2;
            break;
        case 3:
            database.editingNSUrl = database.current_photo_file_directory_3;
            break;
        case 4:
            database.editingNSUrl = database.current_photo_file_directory_4;
            break;
        case 5:
            database.editingNSUrl = database.current_photo_file_directory_5;
            break;
        case 6:
            database.editingNSUrl = database.current_photo_file_directory_6;
            break;
        case 7:
            database.editingNSUrl = database.current_photo_file_directory_7;
            break;
        case 8:
            database.editingNSUrl = database.current_photo_file_directory_8;
            break;
            
        default:
            break;
    }
    
    photoEditorModal.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    
    UIImage *myImage = [self loadImage: database.editingNSUrl ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    //[self loadImageWithImage:myImage atIndex:8];
    
    if (myImage.size.height > myImage.size.width) {
        database.editingPhotoType = @"height";
    }
    else {
        database.editingPhotoType = @"width";
    }
    myImage = nil;
    [super.splitViewController presentViewController:photoEditorModal animated:YES completion:nil];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.popoverController dismissPopoverAnimated:true];
    //[popoverController release];
        
    __block NSURL *currentUrl;
    
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    //[self dismissModalViewControllerAnimated:YES];
    //mistakenly call the function below twic if it's a new media. fix a bug.
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    if (![mediaType isEqualToString:(NSString *)kUTTypeImage]) return;
    
    if (newMedia) 
    {
        UIImage *newImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        //NSLog(@"%d", newImage.imageOrientation);
        self.status = 1;
        
        [self saveImagesBasedOnExistingImageStatusWithUIImage:newImage];
        
        //ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        // Request to save the image to camera roll
        //[self dismissModalViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        /**************** reassign main menu item ***************/
        NSDictionary *dict= [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:3] forKey:@"index"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
        
        
    }
    else{
        currentUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
        self.status = 2;
        //[self loadImageWithNSURL:currentUrl];
        ALAssetsLibrary *outputLibrary = [[ALAssetsLibrary alloc] init];
        [outputLibrary assetForURL:currentUrl resultBlock:^(ALAsset *asset)
         {
             
             float imageOrientation = 0.0;
             
             UIImage *newImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:[[asset defaultRepresentation] scale] orientation:imageOrientation];
             
             [self saveImagesBasedOnExistingImageStatusWithUIImage:newImage];
             
             newImage = nil;
             
         }
         
                      failureBlock:^(NSError *error)
         {
             // error handling
             NSLog(@"error");
         }];
        
    }
}

- (void)saveImagesBasedOnExistingImageStatusWithUIImage: (UIImage *)newImage {
    
    isql *database = [isql initialize];
    
    if ([UIScreen mainScreen].scale == 2.0) {
        //retina screen
        if (newImage.size.width > newImage.size.height) {
            newImage = [self imageWithImage:newImage scaledToSize:CGSizeMake(320, 240)];
        }
        else {
            newImage = [self imageWithImage:newImage scaledToSize:CGSizeMake(240, 320)];
        }
    }
    else {
        if (newImage.size.width > newImage.size.height) {
            newImage = [self imageWithImage:newImage scaledToSize:CGSizeMake(640, 480)];
        }
        else {
            newImage = [self imageWithImage:newImage scaledToSize:CGSizeMake(480, 640)];
        }
    }
    
    if(self.touchedImageNumber == 0){
        if (self.image1 == defaultImage) {
            if([self saveImageWithName:[self createImageString:1] andUIImage:newImage]){
                database.current_photo_file_directory_1 = [self createImageString:1];
                [self loadImageWithImage:newImage atIndex:1];
            }
        }
        else if (self.image2 == defaultImage) {
            if([self saveImageWithName:[self createImageString:2] andUIImage:newImage]){
                database.current_photo_file_directory_2 = [self createImageString:2];
                [self loadImageWithImage:newImage atIndex:2];
            }
        }
        else if (self.image3 == defaultImage) {
            if([self saveImageWithName:[self createImageString:3] andUIImage:newImage]){
                database.current_photo_file_directory_3 = [self createImageString:3];
                [self loadImageWithImage:newImage atIndex:3];
            }
        }
        else if (self.image4 == defaultImage) {
            if([self saveImageWithName:[self createImageString:4] andUIImage:newImage]){
                database.current_photo_file_directory_4 = [self createImageString:4];
                [self loadImageWithImage:newImage atIndex:4];
            }
        }
        else if (self.image5 == defaultImage) {
            if([self saveImageWithName:[self createImageString:5] andUIImage:newImage]){
                database.current_photo_file_directory_5 = [self createImageString:5];
                [self loadImageWithImage:newImage atIndex:5];
            }
        }
        else if (self.image6 == defaultImage) {
            if([self saveImageWithName:[self createImageString:6] andUIImage:newImage]){
                database.current_photo_file_directory_6 = [self createImageString:6];
                [self loadImageWithImage:newImage atIndex:6];
            }
        }
        else if (self.image7 == defaultImage) {
            if([self saveImageWithName:[self createImageString:7] andUIImage:newImage]){
                database.current_photo_file_directory_7 = [self createImageString:7];
                [self loadImageWithImage:newImage atIndex:7];
            }
        }
        else if (self.image8 == defaultImage) {
            if([self saveImageWithName:[self createImageString:8] andUIImage:newImage]){
                database.current_photo_file_directory_8 = [self createImageString:8];
                [self loadImageWithImage:newImage atIndex:8];
            }
        }
        
    }
    else if (self.touchedImageNumber ==1){
        if([self saveImageWithName:[self createImageString:1] andUIImage:newImage]){
            database.current_photo_file_directory_1 = [self createImageString:1];
            [self loadImageWithImage:newImage atIndex:1];
        }
    }
    else if (self.touchedImageNumber ==2){
        if([self saveImageWithName:[self createImageString:2] andUIImage:newImage]){
            database.current_photo_file_directory_2 = [self createImageString:2];
            [self loadImageWithImage:newImage atIndex:2];
        }
    }
    else if (self.touchedImageNumber ==3){
        if([self saveImageWithName:[self createImageString:3] andUIImage:newImage]){
            database.current_photo_file_directory_3 = [self createImageString:3];
            [self loadImageWithImage:newImage atIndex:3];
        }
    }
    else if (self.touchedImageNumber ==4){
        if([self saveImageWithName:[self createImageString:4] andUIImage:newImage]){
            database.current_photo_file_directory_4 = [self createImageString:4];
            [self loadImageWithImage:newImage atIndex:4];
        }
    }
    else if (self.touchedImageNumber ==5){
        if([self saveImageWithName:[self createImageString:5] andUIImage:newImage]){
            database.current_photo_file_directory_5 = [self createImageString:5];
            [self loadImageWithImage:newImage atIndex:5];
        }
    }
    else if (self.touchedImageNumber ==6){
        if([self saveImageWithName:[self createImageString:6] andUIImage:newImage]){
            database.current_photo_file_directory_6 = [self createImageString:6];
            [self loadImageWithImage:newImage atIndex:6];
        }
    }
    else if (self.touchedImageNumber ==7){
        if([self saveImageWithName:[self createImageString:7] andUIImage:newImage]){
            database.current_photo_file_directory_7 = [self createImageString:7];
            [self loadImageWithImage:newImage atIndex:7];
        }
    }
    else if (self.touchedImageNumber ==8){
        if([self saveImageWithName:[self createImageString:8] andUIImage:newImage]){
            database.current_photo_file_directory_8 = [self createImageString:8];
            [self loadImageWithImage:newImage atIndex:8];
        }
    }
}

- (NSString *)createImageString: (int) withIndex {
    
    isql *database = [isql initialize];
    
    NSString *imageString = [NSString stringWithFormat:@"SS - %@ - Activity#%@ (RM %@)(%@) - photo%d", database.current_teq_rep, database.current_activity_no, database.current_classroom_number, database.current_date, withIndex];
    imageString = [database sanitizeFile:imageString];
    
    return imageString;
}

- (BOOL)saveImageWithName: (NSString *) name andUIImage: (UIImage *) image {
   
    NSData *imgData = UIImageJPEGRepresentation(image, 0.75);
    
    NSString* targetPath = [NSString stringWithFormat:@"%@/%@.%@", [self writablePath], name, @"jpg" ];
    
    return [imgData writeToFile:targetPath atomically:YES];
}

-(NSString*) writablePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

-(UIImage *)imageWithImage:(UIImage *)imageToCompress scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [imageToCompress drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"\
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    /**************** reassign main menu item ***************/
    NSDictionary *dict= [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:3] forKey:@"index"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (IBAction)deleteImage:(id)sender {
    isql *database = [isql initialize];
    
    NSString *fileName;
    if ([sender tag]==1) {
        self.image1 = defaultImage;
        self.nsURL1 = nil;
        self.deleteButton1.hidden = TRUE;
        self.editButton1.hidden = TRUE;
        self.imageView1.contentMode = UIViewContentModeCenter;
        fileName = database.current_photo_file_directory_1;
        database.current_photo_file_directory_1 = nil;
    }
    else if ([sender tag]==2) {
        self.image2 = defaultImage;
        self.nsURL2 = nil;
        self.deleteButton2.hidden = TRUE;
        self.editButton2.hidden = TRUE;
        self.imageView2.contentMode = UIViewContentModeCenter;
        fileName = database.current_photo_file_directory_2;
        database.current_photo_file_directory_2 = nil;
    }
    else if ([sender tag]==3) {
        self.image3 = defaultImage;
        self.nsURL3 = nil;
        self.deleteButton3.hidden = TRUE;
        self.editButton3.hidden = TRUE;
        self.imageView3.contentMode = UIViewContentModeCenter;
        fileName = database.current_photo_file_directory_3;
        database.current_photo_file_directory_3 = nil;
    }
    else if ([sender tag]==4) {
        self.image4 = defaultImage;
        self.nsURL4 = nil;
        self.deleteButton4.hidden = TRUE;
        self.editButton4.hidden = TRUE;
        self.imageView4.contentMode = UIViewContentModeCenter;
        fileName = database.current_photo_file_directory_4;
        database.current_photo_file_directory_4 = nil;
    }
    else if ([sender tag]==5) {
        self.image5 = defaultImage;
        self.nsURL5 = nil;
        self.deleteButton5.hidden = TRUE;
        self.editButton5.hidden = TRUE;
        self.imageView5.contentMode = UIViewContentModeCenter;
        fileName = database.current_photo_file_directory_5;
        database.current_photo_file_directory_5 = nil;
    }
    else if ([sender tag]==6) {
        self.image6 = defaultImage;
        self.nsURL6 = nil;
        self.deleteButton6.hidden = TRUE;
        self.editButton6.hidden = TRUE;
        self.imageView6.contentMode = UIViewContentModeCenter;
        fileName = database.current_photo_file_directory_6;
        database.current_photo_file_directory_6 = nil;
    }
    else if ([sender tag]==7) {
        self.image7 = defaultImage;
        self.nsURL7 = nil;
        self.deleteButton7.hidden = TRUE;
        self.editButton7.hidden = TRUE;
        self.imageView7.contentMode = UIViewContentModeCenter;
        fileName = database.current_photo_file_directory_7;
        database.current_photo_file_directory_7 = nil;
    }
    else {
        self.image8 = defaultImage;
        self.nsURL8 = nil;
        self.deleteButton8.hidden = TRUE;
        self.editButton8.hidden = TRUE;
        self.imageView8.contentMode = UIViewContentModeCenter;
        fileName = database.current_photo_file_directory_8;
        database.current_photo_file_directory_8 = nil;
    }
    imageView1.image = self.image1;
    imageView2.image = self.image2;
    imageView3.image = self.image3;
    imageView4.image = self.image4;
    imageView5.image = self.image5;
    imageView6.image = self.image6;
    imageView7.image = self.image7;
    imageView8.image = self.image8;
    
    fileName = [NSString stringWithFormat:@"%@.jpg", fileName];
    NSString* dPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString* filePath = [dPath stringByAppendingPathComponent:fileName];
    
    if ( [[NSFileManager defaultManager] isReadableFileAtPath:filePath] ){
        if([[NSFileManager defaultManager] removeItemAtPath:filePath error:nil]){
            NSLog(@"remove success %@", fileName);
        }
        else {
            NSLog(@"remove failed %@", fileName);
        }
    }
    
    [self checkComplete];
    //[database saveVariableToLocalDest];
    
}


- (IBAction)imageButtonTouched:(id)sender 
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self
                                            cancelButtonTitle:@"Cancel" otherButtonTitles: @"Camera", @"Photo Album", nil];
    [message show];
    touchedImageNumber = [sender tag];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            [self.popoverController dismissPopoverAnimated:NO];
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeCamera])
            {
                if (imagePicker == nil) {
                    imagePicker = [[NonRotatingUIImagePickerController_ViewController alloc] init];
                    NSLog(@"generate imagePicker");
                }
                imagePicker.delegate = self;
                imagePicker.sourceType =
                UIImagePickerControllerSourceTypeCamera;
                imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                          (NSString *) kUTTypeImage,
                                          nil];
                imagePicker.allowsEditing = NO;
                //[self presentModalViewController:imagePicker animated:YES];
                [self presentViewController:imagePicker animated:NO completion:nil];
                newMedia = YES;
            }

            break;
        
        case 2:
            if ([self.popoverController isPopoverVisible]) {
                [self.popoverController dismissPopoverAnimated:NO];
                //[popoverController release];
            } else {
                if ([UIImagePickerController isSourceTypeAvailable:
                     UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                {
                    if (imagePicker == nil) {
                        imagePicker = [[NonRotatingUIImagePickerController_ViewController alloc] init];
                        NSLog(@"generate imagePicker");
                    }
                    imagePicker.delegate = self;
                    imagePicker.sourceType =
                    UIImagePickerControllerSourceTypePhotoLibrary;
                    imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                              (NSString *) kUTTypeImage,
                                              nil];
                    imagePicker.allowsEditing = NO;
                    
                    self.popoverController = [[UIPopoverController alloc]
                                              initWithContentViewController:imagePicker];
                    
                    popoverController.delegate = self;
                    
                    [self.popoverController 
                     presentPopoverFromBarButtonItem:cameraRollButton
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                     animated:YES];
                    
                    newMedia = NO;
                }
            }
            
            break;
            
        default:
            break;
    }
}

- (void) finshedEditingPhotos
{
    isql *database = [isql initialize];
    touchedImageNumber = 0;
    //[self loadImageWithNSURL:database.editingNSUrl];
    [self saveImagesBasedOnExistingImageStatusWithUIImage:database.editedPhoto];
    database.editedPhoto = nil;
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    return result;
}

-(void)checkComplete
{
    isql *database = [isql initialize];
    if ([database.current_photo_file_directory_1 length] > 0 ||
        [database.current_photo_file_directory_2 length] > 0 ||
        [database.current_photo_file_directory_3 length] > 0 ||
        [database.current_photo_file_directory_4 length] > 0 ||
        [database.current_photo_file_directory_5 length] > 0 ||
        [database.current_photo_file_directory_6 length] > 0 ||
        [database.current_photo_file_directory_7 length] > 0 ||
        [database.current_photo_file_directory_8 length] > 0) {
        NSMutableDictionary *myDict = [[NSMutableDictionary alloc] init];
        
        [database.menu_complete replaceObjectAtIndex:3 withObject:@"Complete"];
        [database greyoutMenu:myDict andHightlight:3];
        [database.room_complete_status setObject:@"1" forKey:@"3"];
        [database checkRoomComplete];
    }
    else {
        NSMutableDictionary *myDict = [[NSMutableDictionary alloc] init];
        [database.menu_complete replaceObjectAtIndex:3 withObject:@"Incomplete"];
        [database greyoutMenu:myDict andHightlight:3];
        [database.room_complete_status setObject:@"0" forKey:@"3"];
        [database checkRoomComplete];
    }
}

@end
