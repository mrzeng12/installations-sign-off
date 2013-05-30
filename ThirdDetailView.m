//
//  ThirdDetailView.m
//  MultipleDetailViews
//
//  Created by Helpdesk on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThirdDetailView.h"
#import <QuartzCore/QuartzCore.h>
#import "isql.h"

@implementation ThirdDetailView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.}
    self.commentsOutlet.layer.borderWidth = 1;
    self.commentsOutlet.layer.borderColor = [[UIColor grayColor] CGColor];
    self.commentsOutlet.layer.cornerRadius = 7.0f;
    
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    self.gestureRecognizer.cancelsTouchesInView = NO;
    self.gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.gestureRecognizer];
    self.SerialSK.delegate = self;
    [self.scrollview setFrame:CGRectMake(0, 44, 703, 704)];
    [self.scrollview setContentSize:CGSizeMake(703, 705)];
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

-(void)checkComplete
{
    isql *database = [isql initialize];
    if ([self.testContent.text length] > 0 ) {
        NSMutableDictionary *myDict = [[NSMutableDictionary alloc] init];
              
        [database.menu_complete replaceObjectAtIndex:2 withObject:@"Complete"];
        [database greyoutMenu:myDict andHightlight:2];
        [database.room_complete_status setObject:@"1" forKey:@"2"];
        [database checkRoomComplete];
    }
    else {
        NSMutableDictionary *myDict = [[NSMutableDictionary alloc] init];
        [database.menu_complete replaceObjectAtIndex:2 withObject:@"Incomplete"];
        [database greyoutMenu:myDict andHightlight:2];
        [database.room_complete_status setObject:@"0" forKey:@"2"];
        [database checkRoomComplete];
    }
}

- (IBAction)testChanged:(id)sender {
    [self checkComplete];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    self.gestureRecognizer.cancelsTouchesInView = YES;
    int movementDistance;
    
    movementDistance = 350; // tweak as needed
    
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableSelection:finished:context:)];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)enableSelection:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    self.gestureRecognizer.cancelsTouchesInView = NO;
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

@end
