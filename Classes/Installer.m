//
//  Installer.m
//  Installation
//
//  Created by Chao Zeng on 7/15/13.
//
//

#import "Installer.h"
#import "isql.h"
#import "sqlite3.h"
#import "ThirdDetailView.h"

@interface Installer ()

@end

@implementation Installer
@synthesize installerActionSheet;
@synthesize installersList;
@synthesize installerOutlet;

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
    isql *database = [isql initialize];
    [self loadInstallerList];
    installerOutlet = [NSMutableArray array];
    [installerOutlet addObject:self.installer1];
    [installerOutlet addObject:self.installer2];
    [installerOutlet addObject:self.installer3];
    [installerOutlet addObject:self.installer4];
    [installerOutlet addObject:self.installer5];
    [installerOutlet addObject:self.installer6];
    [installerOutlet addObject:self.installer7];
    [installerOutlet addObject:self.installer8];
    for (UITextField *textField in installerOutlet) {
        textField.delegate = self;
    }
    for (int i = 0; i< [database.current_installer count]; i++) {
        UITextField *installerTextField = [installerOutlet objectAtIndex:i];
        installerTextField.text = [database.current_installer objectAtIndex:i];
    }
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    self.gestureRecognizer.cancelsTouchesInView = NO;
    self.gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.gestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneBtnClicked:(id)sender {
    isql *database = [isql initialize];
    NSMutableArray *temp_installer = [NSMutableArray array];
    for (UITextField *installers in installerOutlet) {
        NSString *installersString = [installers.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([installersString length] > 0) {
            [temp_installer addObject:installersString];
        }
    }
    database.current_installer = temp_installer;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"reloadInstallers" object:self];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelBtnClicked:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < [installersList count]) {
        UITextField *textfield = [installerOutlet objectAtIndex:(actionSheet.tag-1)];
        textfield.text = [installersList objectAtIndex:buttonIndex];
    }
}
- (IBAction)addContact:(id)sender {
   
    [self.view endEditing:YES];
    
    UIButton *btn = sender;
    installerActionSheet = [[UIActionSheet alloc] initWithTitle:nil  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    for (NSString *btnName in installersList) {
        [installerActionSheet addButtonWithTitle:btnName];
    }
    [installerActionSheet addButtonWithTitle:@""];
    if (btn.tag == 1) {
        [installerActionSheet addButtonWithTitle:@""];
        [installerActionSheet addButtonWithTitle:@""];
        [installerActionSheet addButtonWithTitle:@""];
    }
    installerActionSheet.tag = btn.tag;
    [installerActionSheet showFromRect:btn.frame inView:self.view animated:YES];
     
}
- (void) loadInstallerList {
    isql *database = [isql initialize];
    installersList = [NSMutableArray arrayWithObjects: nil];
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSString *selectSQL = [NSString stringWithFormat:@"select Name from local_installers order by Name"];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    [installersList addObject:[[NSString alloc]
                                               initWithUTF8String:
                                               (const char *) sqlite3_column_text(statement, 0)]];
                    /*NSLog(@"%@",[[NSString alloc]
                     initWithUTF8String:
                     (const char *) sqlite3_column_text(statement, 0)]);*/
                }
                NSLog(@"loadCustomText success");
                
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement for loadCustomText failed: %s", sqlite3_errmsg(db));
                
            }
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    //do not allow touch events when animation is going
    self.gestureRecognizer.cancelsTouchesInView = YES;
    int movementDistance;
    if (textField == self.installer6 || textField == self.installer7 || textField == self.installer8) {
        movementDistance = 200; // tweak as needed
    }
    else {
        movementDistance = 0; // tweak as needed
    }
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

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}
@end
