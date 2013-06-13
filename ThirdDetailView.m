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
    lastInputY = 308;
    addBtnCount = 0;
    addBtnArray = [NSMutableArray array];
    
    self.commentsOutlet.layer.borderWidth = 1;
    self.commentsOutlet.layer.borderColor = [[UIColor grayColor] CGColor];
    self.commentsOutlet.layer.cornerRadius = 7.0f;
    
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    self.gestureRecognizer.cancelsTouchesInView = NO;
    self.gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.gestureRecognizer];
    self.installers.delegate = self;
    self.SerialSB.delegate = self;
    self.SerialPJ.delegate = self;
    self.SerialSK.delegate = self;
    self.commentsOutlet.delegate = self;
    [self.scrollview setFrame:CGRectMake(0, 44, 703, 704)];
    [self.scrollview setContentSize:CGSizeMake(703, 705)];
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap)];
    [self.addBtnDesc addGestureRecognizer:tapGesture];
    [self checkComplete];
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

- (void)viewDidAppear:(BOOL)animated
{
    isql *database = [isql initialize];
    NSData *data = [database.current_serial_no dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSMutableArray *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    for (NSMutableDictionary *dict in dictArray) {
                
        if ([[dict objectForKey:@"type"] isEqualToString:@"SB"]) {
            if ([self.SerialSB.text length] == 0) {
                self.SerialSB.text = [dict objectForKey:@"serial"];
            }
            else {
                [self createButton:@"(SB)" andAutoFill:[dict objectForKey:@"serial"]];
            }
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"PJ"]) {
            if ([self.SerialPJ.text length] == 0) {
                self.SerialPJ.text = [dict objectForKey:@"serial"];
            }
            else {
                [self createButton:@"(PJ)" andAutoFill:[dict objectForKey:@"serial"]];
            }
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"SK"]) {
            if ([self.SerialSK.text length] == 0) {
                self.SerialSK.text = [dict objectForKey:@"serial"];
            }
            else {
                [self createButton:@"(SK)" andAutoFill:[dict objectForKey:@"serial"]];
            }
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"Camera"]) {
            [self createButton:@"(CAM)" andAutoFill:[dict objectForKey:@"serial"]];
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"Other"]) {
            [self createButton:@"(Other)" andAutoFill:[dict objectForKey:@"serial"]];
        }
    }     
    
}

-(void)checkComplete
{
    isql *database = [isql initialize];
    NSData *data = [database.current_serial_no dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSMutableArray *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    if ([database.current_installer length] > 0 && [database.current_status length]> 0 && [dictArray count] >0) {
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

- (IBAction)installersChanged:(id)sender {
    isql *database = [isql initialize];
    database.current_installer = self.installers.text;
    [self checkComplete];
}

- (IBAction)statusChanged:(id)sender {
    isql *database = [isql initialize];
    database.current_status = self.statusOutlet.text;
    [self checkComplete];
}

- (IBAction)serialNoChanged:(id)sender {
    [self saveSerialNumber];
    [self checkComplete];
}

- (void)saveSerialNumber {
    isql *database = [isql initialize];
    NSMutableArray *temp_serial_no = [NSMutableArray array];
    if ([self.SerialSB.text length] > 0) {
        NSMutableDictionary *output = [NSMutableDictionary dictionary];
        [output setObject:@"SB" forKey:@"type"];
        [output setObject:self.SerialSB.text forKey:@"serial"];
        [temp_serial_no addObject:output];
    }
    if ([self.SerialPJ.text length] > 0) {
        NSMutableDictionary *output = [NSMutableDictionary dictionary];
        [output setObject:@"PJ" forKey:@"type"];
        [output setObject:self.SerialPJ.text forKey:@"serial"];
        [temp_serial_no addObject:output];
    }
    if ([self.SerialSK.text length] > 0) {
        NSMutableDictionary *output = [NSMutableDictionary dictionary];
        [output setObject:@"SK" forKey:@"type"];
        [output setObject:self.SerialSK.text forKey:@"serial"];
        [temp_serial_no addObject:output];
    }
    for (NSMutableDictionary *dict in addBtnArray) {
        UITextField *textField = [dict objectForKey:@"textFieldRounded"];
        if ([textField.text length] > 0) {
            NSString *type;
            if ([textField.placeholder isEqualToString:@"(SB)"]) {
                type = @"SB";
            }
            if ([textField.placeholder isEqualToString:@"(PJ)"]) {
                type = @"PJ";
            }
            if ([textField.placeholder isEqualToString:@"(SK)"]) {
                type = @"SK";
            }
            if ([textField.placeholder isEqualToString:@"(CAM)"]) {
                type = @"Camera";
            }
            if ([textField.placeholder isEqualToString:@"(Other)"]) {
                type = @"Other";
            }
            NSMutableDictionary *output = [NSMutableDictionary dictionary];
            [output setObject:type forKey:@"type"];
            [output setObject:textField.text forKey:@"serial"];
            [temp_serial_no addObject:output];
        }
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:temp_serial_no options:NSJSONWritingPrettyPrinted error:&error];
    database.current_serial_no = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.gestureRecognizer.cancelsTouchesInView = YES;
    const float movementDuration = 0.3f;
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableSelection:finished:context:)];
    [self.scrollview setFrame:CGRectMake(0, 0, 703, 356)];
    [UIView commitAnimations];
    int movementDistance = [textField.superview.superview convertPoint:textField.frame.origin toView:self.view].y - 150;
    [self.scrollview scrollRectToVisible:CGRectMake(0, movementDistance, 703, 356) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL) textViewShouldBeginEditing: (UITextView *)textView
{
    self.gestureRecognizer.cancelsTouchesInView = YES; 
    const float movementDuration = 0.3f;
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableSelection:finished:context:)];
    [self.scrollview setFrame:CGRectMake(0, 0, 703, 356)];
    [UIView commitAnimations];
    int movementDistance = [textView.superview.superview convertPoint:textView.frame.origin toView:self.view].y - 50;
    [self.scrollview scrollRectToVisible:CGRectMake(0, movementDistance, 703, 356) animated:YES];
    
    return  YES;
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    
}

-(void) textViewDidChange:(UITextView *)textView
{
    isql *database = [isql initialize];
    database.current_general_notes = self.commentsOutlet.text;
    [self checkComplete];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
    self.gestureRecognizer.cancelsTouchesInView = YES;    
    const float movementDuration = 0.3f; // tweak as needed
        
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableSelection:finished:context:)];
    [self.scrollview setFrame:CGRectMake(0, 0, 703, 704)];
    [UIView commitAnimations];
    
}

- (void)enableSelection:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    self.gestureRecognizer.cancelsTouchesInView = NO;
}

- (IBAction)addSerial:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: @"SMARTBoard", @"Projector", @"Speaker", @"Camera", @"Other", nil];
    [actionSheet setTag:1];
    [actionSheet showFromRect:self.addBtn.frame inView:self.scrollview animated:YES];   
    
}

- (IBAction)autoFill:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: @"Complete", @"Incomplete", nil];
    [actionSheet setTag:sender.tag];
    [actionSheet showFromRect:sender.frame inView:self.scrollview animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == -1) {
        return;
    }
    if (actionSheet.tag == 1) {
        NSString *text;
        switch (buttonIndex) {
            case 0:
                text = @"(SB)";
                break;
            case 1:
                text = @"(PJ)";
                break;
            case 2:
                text = @"(SK)";
                break;
            case 3:
                text = @"(CAM)";
                break;
            case 4:
                text = @"(Other)";
                break;
            default:
                break;
        }
        [self createButton:text andAutoFill:@""];
    }
    if (actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            self.statusOutlet.text = @"Complete";
        }
        if (buttonIndex == 1) {
            self.statusOutlet.text = @"Incomplete";
        }
        isql *database = [isql initialize];
        database.current_status = self.statusOutlet.text;
        [self checkComplete];
    }
}

- (void)createButton: (NSString *) text andAutoFill: (NSString *) serial {
    
    UITextField *textFieldRounded = [[UITextField alloc] initWithFrame:CGRectMake(168, lastInputY + 65, 383, 30)];
    textFieldRounded.borderStyle = UITextBorderStyleRoundedRect;
    textFieldRounded.textColor = [UIColor blackColor];
    textFieldRounded.font = [UIFont systemFontOfSize:17.0];
    textFieldRounded.placeholder = text;
    textFieldRounded.backgroundColor = [UIColor whiteColor];
    textFieldRounded.autocorrectionType = UITextAutocorrectionTypeNo;
    textFieldRounded.keyboardType = UIKeyboardTypeDefault;
    textFieldRounded.returnKeyType = UIReturnKeyDone;    
    textFieldRounded.clearButtonMode = UITextFieldViewModeWhileEditing;
    textFieldRounded.text = serial;
    [textFieldRounded addTarget:self action:@selector(serialNoChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.scrollview addSubview:textFieldRounded];
    textFieldRounded.delegate = self;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(576, lastInputY + 69, 50, 21)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:17.0];
    label.text = text;
    label.adjustsFontSizeToFitWidth = YES;
    
    [self.scrollview addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTag:addBtnCount];
    [button addTarget:self
               action:@selector(removeButtonClicked:)
     forControlEvents:UIControlEventTouchDown];    
    button.frame = CGRectMake(629, lastInputY + 67, 26, 25);
    [button setImage:[UIImage imageNamed:@"onebit_33.png"] forState:UIControlStateNormal];    
    
    [self.scrollview addSubview:button];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:textFieldRounded forKey:@"textFieldRounded"];
    [dict setObject:label forKey:@"label"];
    [dict setObject:button forKey:@"button"];
    [addBtnArray addObject:dict];
    
    [self.addBtn setFrame:CGRectMake(165, lastInputY + 115, 29, 29)];
    [self.addBtnDesc setFrame:CGRectMake(199, lastInputY + 118, 191, 21)];
    [self.commentsTag setFrame:CGRectMake(65, lastInputY + 177, 89, 21)];
    [self.commentsOutlet setFrame:CGRectMake(168, lastInputY + 177, 383, 248)];    
    [self.scrollview setContentSize:CGSizeMake(703, lastInputY + 462)];
    
    addBtnCount++;
    lastInputY += 65;
}

- (void)removeButtonClicked:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do you want to remove the item?" message:nil   delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes", nil];
    [alert setTag: sender.tag];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self removeButton: alertView.tag];
        [self saveSerialNumber];
    }
}

-(void)removeButton:(int)index {
    
    NSMutableDictionary *dict = [addBtnArray objectAtIndex:index];
    [[dict objectForKey:@"textFieldRounded"] removeFromSuperview];
    [[dict objectForKey:@"label"] removeFromSuperview];
    [[dict objectForKey:@"button"] removeFromSuperview];
    [addBtnArray removeObjectAtIndex:index];
    addBtnCount--;
    lastInputY -= 65;
    
    //reshuffle the ones under the deleted item
    for (int i = index; i< [addBtnArray count]; i++) {
        NSMutableDictionary *dict = [addBtnArray objectAtIndex:i];
        float y = [[dict objectForKey:@"textFieldRounded"] frame].origin.y;
        [[dict objectForKey:@"textFieldRounded"] setFrame: CGRectMake(168, y - 65, 383, 30)];
        y = [[dict objectForKey:@"label"] frame].origin.y;
        [[dict objectForKey:@"label"] setFrame: CGRectMake(576, y - 65, 50, 21)];
        y = [[dict objectForKey:@"button"] frame].origin.y;
        [[dict objectForKey:@"button"] setFrame: CGRectMake(629, y - 65, 26, 25)];
        
        [[dict objectForKey:@"button"] removeTarget:self
                                             action:@selector(removeButtonClicked:)
                                   forControlEvents:UIControlEventTouchDown];
        [[dict objectForKey:@"button"] setTag:i];
        [[dict objectForKey:@"button"] addTarget:self
                                          action:@selector(removeButtonClicked:)
                                forControlEvents:UIControlEventTouchDown];
    }
    
    [self.addBtn setFrame:CGRectMake(165, lastInputY + 50, 29, 29)];
    [self.addBtnDesc setFrame:CGRectMake(199, lastInputY + 53, 191, 21)];
    [self.commentsTag setFrame:CGRectMake(65, lastInputY + 112, 89, 21)];
    [self.commentsOutlet setFrame:CGRectMake(168, lastInputY + 112, 383, 248)];
    [self.scrollview setContentSize:CGSizeMake(703, lastInputY + 397)];
}


@end
