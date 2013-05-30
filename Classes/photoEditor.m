//
//  photoEditor.m
//  Site Survey
//
//  Created by Helpdesk on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "photoEditor.h"
#import "photoPaintView.h"
#import "isql.h"

@interface photoEditor ()

@end

@implementation photoEditor
@synthesize paint;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(customizedDismissModalForPhotoPaintView)
     name:@"customizedDismissModalForPhotoPaintView" object:nil];   

}

- (void) viewWillAppear:(BOOL)animated
{          
    [super viewWillAppear:YES];    
        
    [paint removeFromSuperview];
    //paint = [[photoPaintView alloc] initWithFrame:CGRectMake(32, 0, 960, 720)];
    isql *database = [isql initialize];
    
    if ([database.editingPhotoType isEqualToString:@"width"]) {
        paint = [[photoPaintView alloc] initWithFrame:CGRectMake(200, 130, 640, 480)];
    }
    else {
        paint = [[photoPaintView alloc] initWithFrame:CGRectMake(300, 60, 480, 640)];
    }
    
        
    
    [self.view addSubview:paint];
    [self.view setMultipleTouchEnabled:YES];
    paint.clipsToBounds = YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     addObserver:paint selector:@selector(photoEditorNotification:)
     name:@"photoEditorNotification" object:nil];
    
    [super viewDidAppear:YES];
}

- (void) viewDidDisappear:(BOOL)animated
{
    /************* remove NSNotification after view disappears, avoid referring to an notification that belongs to a nil xib *************/
    //[[NSNotificationCenter defaultCenter] removeObserver: self];
    [[NSNotificationCenter defaultCenter] removeObserver: paint];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void) customizedDismissModalForPhotoPaintView
{
    //[self.presentingViewController dismissModalViewControllerAnimated:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)cancelBtnClicked:(id)sender {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"index"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"photoEditorNotification" object:self userInfo:dict];
}

- (IBAction)clearBtnClicked:(id)sender {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"index"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"photoEditorNotification" object:self userInfo:dict];
}

- (IBAction)DoneBtnClicked:(id)sender {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:@"index"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"photoEditorNotification" object:self userInfo:dict];
}
@end
