//
//  VanStock.m
//  Installation
//
//  Created by Chao Zeng on 7/15/13.
//
//

#import "VanStock.h"
#import "isql.h"
#import "sqlite3.h"

@interface VanStock ()

@end

@implementation VanStock
@synthesize installerActionSheet;
@synthesize installersList;
@synthesize installerOutlet;
@synthesize materialOutlet;

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
    
    materialOutlet = [NSMutableArray array];
    [materialOutlet addObject:self.material1];
    [materialOutlet addObject:self.material2];
    [materialOutlet addObject:self.material3];
    [materialOutlet addObject:self.material4];
    [materialOutlet addObject:self.material5];
    [materialOutlet addObject:self.material6];
    [materialOutlet addObject:self.material7];
    [materialOutlet addObject:self.material8];
    
    for (UITextField *textfield in installerOutlet) {
        textfield.delegate = self;
    }
    for (UITextField *textfield in materialOutlet) {
        textfield.delegate = self;
    }
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    self.gestureRecognizer.cancelsTouchesInView = NO;
    self.gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.gestureRecognizer];
    
    NSData *data = [database.current_van_stock dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSMutableArray *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    for (int i = 0; i< [dictArray count]; i++) {
        NSMutableDictionary *dict = [dictArray objectAtIndex:i];
        
        UITextField *installerTextField = [installerOutlet objectAtIndex:i];
        
        installerTextField.text = [dict objectForKey:@"installer"];
        UITextField *materialTextField = [materialOutlet objectAtIndex:i];
        materialTextField.text = [dict objectForKey:@"material"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneBtnClicked:(id)sender {
    isql *database = [isql initialize];
    NSMutableArray *temp_vanstock = [NSMutableArray array];
    for (int i = 0; i < 8; i++) {
        UITextField *installer = [installerOutlet objectAtIndex:i];
        UITextField *material = [materialOutlet objectAtIndex:i];
        NSString *installerString = [installer.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *materialString = [material.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([installerString length] == 0 && [materialString length] == 0) {
            continue;
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:installerString forKey:@"installer"];
        [dict setObject:materialString forKey:@"material"];
        [temp_vanstock addObject:dict];    
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:temp_vanstock options:NSJSONWritingPrettyPrinted error:&error];
    database.current_van_stock = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"reloadVanStock" object:self];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelBtnClicked:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < [installersList count]) {
        UITextField *textfield = [installerOutlet objectAtIndex:(actionSheet.tag-1)];
        textfield.text = [installersList objectAtIndex:buttonIndex];
    }
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
    if (textField == self.installer6 || textField == self.installer7 || textField == self.installer8 || textField == self.material6 || textField == self.material7 || textField == self.material8) {
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
