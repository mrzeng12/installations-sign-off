//
//  Modal.m
//  MultipleDetailViews
//
//  Created by Helpdesk on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "loginModal.h"
#import <sqlite3.h>
#import "isql.h"
//#import "PDFModal.h"
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

@implementation loginModal
@synthesize testPDF;

@synthesize resultLabel;
@synthesize username_input;
@synthesize password_input;
@synthesize activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self addIndexToMenu];
        // Custom initialization
        //EVERYTIME IT LOADS, IT RUNS THIS PROGRAM
           //[self verifyUser];
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
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    username_input.delegate = self;
    password_input.delegate = self;
    
    [username_input setFrame:CGRectMake(411, 217, 170, 40)];
    
    activityIndicator.hidesWhenStopped = YES;
    [username_input becomeFirstResponder];
    
    testPDF.hidden = YES;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(EnableLogin:)
     name:@"EnableLogin" object:nil];
    
    //save last time's login name
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];    
    username_input.text =  [prefs stringForKey:@"defaultUserName"];
    
    //[self getData];
    self.verifyUserBtn.alpha = 0.5;
    self.verifyUserBtn.enabled = NO;
    [activityIndicator startAnimating];
    
    //if database was filled, only download user at login, otherwise download src, menu and user
    [self checkifSrcMenuTableExist];
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear
{
    isql *database = [isql initialize];
    if (database.debugMode == NO) {
        testPDF.hidden = YES;
    }
    //[self getData];
}

- (void)viewDidUnload
{
    [self setUsername_input:nil];
    [self setPassword_input:nil];
    [self setTestPDF:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	//return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [self verifyUser];
    return NO;
}

-(void)addIndexToMenu {
    
    isql *database = [isql initialize];
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSString *insertSQL = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS 'menu_xib_form_index' ON 'local_menu' ('Xib','Form');"];
            
            const char *insert_stmt = [insertSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, insert_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    //NSLog(@"%@", insertSQL);
                } else {
                    NSLog(@"addIndexToMenu failed: %s", sqlite3_errmsg(db));
                    
                }
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed in function addIndexToMenu->insert: %s", sqlite3_errmsg(db));
            }
            insertSQL = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS 'menu_cat1_cat2_cat3_index' ON 'local_menu' ('Cat1', 'Cat2', 'Cat3'); "];
            
            insert_stmt = [insertSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, insert_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    //NSLog(@"%@", insertSQL);
                } else {
                    NSLog(@"addIndexToMenu failed: %s", sqlite3_errmsg(db));
                    
                }
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed in function addIndexToMenu->insert: %s", sqlite3_errmsg(db));
            }
            
        }
        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
    }
}

-(void)EnableLogin:(NSNotification*)notifications
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *converPhotoToAppFolderString = [prefs stringForKey:@"converPhotoToAppFolder"];
    if (![converPhotoToAppFolderString isEqualToString:@"done"]) {
        [self convertPhotosToAppFolderStepOne];
    }
    else {
        NSLog(@"enable btn");
        [activityIndicator stopAnimating];
        self.verifyUserBtn.alpha = 1;
        self.verifyUserBtn.enabled = YES;
    }
}

-(void) convertPhotosToAppFolderStepOne {
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    isql *database = [isql initialize];
    NSMutableArray *tempArrayDict = [NSMutableArray array];
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSString *selectSQL = [NSString stringWithFormat:@"select [Teq_rep], [Activity_no], [Date], [Room_Number], [Photo_file_directory_1], [Photo_file_directory_2], [Photo_file_directory_3], [Photo_file_directory_4], [Photo_file_directory_5], [Photo_file_directory_6], [Photo_file_directory_7], [Photo_file_directory_8] from local_dest"];
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    //NSLog(@"fetch a row");
                    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
                    int column_count = sqlite3_data_count(statement);
                    for (int i = 0; i< column_count; i++) {
                        
                        NSString *tempString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i)]];
                        NSString *tempFieldName = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_name(statement, i)]];
                        [tempDict setObject:tempString forKey:tempFieldName];
                        
                    }
                    [tempArrayDict addObject:tempDict];
                }
                
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
            }
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
    }
    @finally {
        [self convertPhotosToAppFolderStepTwo:tempArrayDict];
    }
}

-(void) convertPhotosToAppFolderStepTwo: (NSMutableArray *) arrayDict{
    NSMutableArray *destArray = [NSMutableArray arrayWithObjects: nil];
    for (NSMutableDictionary *srcDict in arrayDict) {
        
        for (int i = 1; i<=8; i++) {
            
            NSString *photoColumnName = [NSString stringWithFormat:@"Photo_file_directory_%d", i];
            
            if ([[srcDict objectForKey:photoColumnName] rangeOfString:@"assets-library://"].location == NSNotFound) {
                //not a photo from photo stream
            }
            else {
                NSMutableDictionary *destDict = [NSMutableDictionary dictionary];
                NSString *indexString = [NSString stringWithFormat:@"%d", i];
                [destDict setObject:[srcDict objectForKey:@"Teq_rep"] forKey:@"Teq_rep"];
                [destDict setObject:[srcDict objectForKey:@"Activity_no"] forKey:@"Activity_no"];
                [destDict setObject:[srcDict objectForKey:@"Room_Number"] forKey:@"Room_Number"];
                [destDict setObject:[srcDict objectForKey:@"Date"] forKey:@"Date"];
                [destDict setObject:[srcDict objectForKey:photoColumnName] forKey:@"url"];
                [destDict setObject:indexString forKey:@"photoIndex"];
                [destArray addObject:destDict];
            }
        }
        
    }
    [self convertPhotosToAppFolderStepThree:destArray withIndex:([destArray count] - 1)];
}
- (void) convertPhotosToAppFolderStepThree: (NSMutableArray *)arrayDict withIndex: (int)index {
    if (index < 0) {
        NSLog(@"enable btn after convert photos");
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:@"done" forKey:@"converPhotoToAppFolder"];
        [prefs synchronize];
        self.updateVersionLogs.text = @"";
        [activityIndicator stopAnimating];
        self.verifyUserBtn.alpha = 1;
        self.verifyUserBtn.enabled = YES;
        return;
    }
    NSURL *imageURL = [NSURL URLWithString:[[arrayDict objectAtIndex:index] objectForKey:@"url"]];
    ALAssetsLibrary *outputLibrary = [[ALAssetsLibrary alloc] init];
    [outputLibrary assetForURL: imageURL resultBlock:^(ALAsset *asset)
     {
         UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:[[asset defaultRepresentation] scale] orientation:0];
         
         if ([UIScreen mainScreen].scale == 2.0) {
             //retina screen
             if (copyOfOriginalImage.size.width > copyOfOriginalImage.size.height) {
                 copyOfOriginalImage = [self imageWithImage:copyOfOriginalImage scaledToSize:CGSizeMake(320, 240)];
             }
             else {
                 copyOfOriginalImage = [self imageWithImage:copyOfOriginalImage scaledToSize:CGSizeMake(240, 320)];
             }
         }
         else {
             if (copyOfOriginalImage.size.width > copyOfOriginalImage.size.height) {
                 copyOfOriginalImage = [self imageWithImage:copyOfOriginalImage scaledToSize:CGSizeMake(640, 480)];
             }
             else {
                 copyOfOriginalImage = [self imageWithImage:copyOfOriginalImage scaledToSize:CGSizeMake(480, 640)];
             }
         }
         
         NSData *imageData = UIImageJPEGRepresentation(copyOfOriginalImage, 0.75);
         isql *database = [isql initialize];
         NSString *imageString;
         if (imageData == nil) {
             //NSLog(@"no image");
             imageString = @"";
         }
         else {
             
             imageString = [NSString stringWithFormat:@"SS - %@ - Activity#%@ (RM %@)(%@) - photo%@", [[arrayDict objectAtIndex: index] objectForKey:@"Teq_rep"], [[arrayDict objectAtIndex: index] objectForKey:@"Activity_no"], [[arrayDict objectAtIndex: index] objectForKey:@"Room_Number"], [[arrayDict objectAtIndex: index] objectForKey:@"Date"], [[arrayDict objectAtIndex: index] objectForKey:@"photoIndex"]];
             imageString = [database sanitizeFile:imageString];
             
             [self saveImageWithName:imageString andUIImage:copyOfOriginalImage];
             //NSLog(@"%@", imageString);
             self.updateVersionLogs.text = [NSString stringWithFormat:@"Updating photo %@", imageString];
         }
         
         sqlite3 *db;
         sqlite3_stmt    *statement;
         
         @try {
             
             const char *dbpath = [database.dbpathString UTF8String];
             
             if (sqlite3_open(dbpath, &db) == SQLITE_OK)
             {
                 
                 NSString *insertSQL = [NSString stringWithFormat:
                                        @"update local_dest set [Photo_file_directory_%@]='%@' where [Teq_rep]='%@' and [Activity_no]='%@' and [Room_Number]='%@';", [[arrayDict objectAtIndex: index] objectForKey:@"photoIndex"], imageString, [[arrayDict objectAtIndex: index] objectForKey:@"Teq_rep"], [[arrayDict objectAtIndex: index] objectForKey:@"Activity_no"], [[arrayDict objectAtIndex: index] objectForKey:@"Room_Number"]];
                 const char *insert_stmt = [insertSQL UTF8String];
                 
                 if ( sqlite3_prepare_v2(db, insert_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                     
                     if (sqlite3_step(statement) == SQLITE_DONE)
                     {
                         NSLog(@"convertPhotosToAppFolderStepThree update successfully");
                     } else {
                         NSLog(@"convertPhotosToAppFolderStepThree update failed: %s", sqlite3_errmsg(db));
                         
                     }
                     sqlite3_finalize(statement);
                 }
                 else {
                     NSLog(@"convertPhotosToAppFolderStepThree prepare db statement failed: %s", sqlite3_errmsg(db));
                 }
                 
             }
         }
         @catch (NSException *exception) {
         }
         @finally {
             sqlite3_close(db);
         }
         
         [self convertPhotosToAppFolderStepThree:arrayDict withIndex:index-1];
         
     }
                  failureBlock:^(NSError *error)
     {
         [self convertPhotosToAppFolderStepThree:arrayDict withIndex:index-1];
         // error handling
         //NSLog(@"error");
     }];
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

- (void) verifyUser{
    
    //[username_input becomeFirstResponder];
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    isql *database = [isql initialize];
    
    [database copyDatabaseIfNeeded];
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            NSString *selectSQL = [NSString stringWithFormat:@"select Distinct Assigned_Name, lower(User_ID) from ( select t0.Teq_rep as 'Assigned_Name',t0.Username as 'User_ID' from local_dest t0 union select t1.Assigned_Name as Name,t1.[User_ID] as ID from local_src t1 union  select t2.Name as Name,t2.[User ID] as ID from local_sap_user t2 ) A where A.User_ID = '%@' COLLATE NOCASE", self.username_input.text];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                int flag = 0;
                while (sqlite3_step(statement) == SQLITE_ROW)
                {                                                            
                    flag = 1;
                    database.current_teq_rep = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]];
                }        
                if (flag == 1) {
                    //found a record in userlist
                    NSLog(@"User Logged in");
                    
                    database.current_username = self.username_input.text;
                    
                    //save last time's login name, must user [prefs synchronize] to make it work.
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    [prefs setObject:self.username_input.text forKey:@"defaultUserName"];
                    [prefs synchronize];
                    //MOVE TO FIRST PAGE BEFORE LOGGIN IN BUTTON, OTHERWISE LOGGED IN DON'T SHOW UP
                    
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"Logged in" object:nil];
                    
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    NSDictionary *dict= [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"index"]; 
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
                }
                else {                    
                    [resultLabel setHidden:NO];
                    [self.checkNewUserTag setHidden:NO];
                    [self.updateUserListBtn setHidden:NO];
                    [self.updateUserListBtn setEnabled:YES];
                    
                    //do not need to setHidden:Yes, because it is default if not entered wrong ID
                }
                
                sqlite3_finalize(statement);
            } 
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db)); 
                
            }
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db)); 
    }
    @finally {        
        sqlite3_close(db);        
    } 
    
}


- (void) checkifSrcMenuTableExist

{
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    isql *database = [isql initialize];
    
    [database copyDatabaseIfNeeded];
    
    int SrcFlag = 0;
    int MenuFlag = 0;
    int UserFlag = 0;
    //NSString *localMenuVersion;
    //__block int MenuUpdated = 0;
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSString *selectSQL = [NSString stringWithFormat:@"select count(*) from local_src"];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    if ([[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] intValue] > 0) {
                        SrcFlag = 1;
                    }
                }
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                
            }
            
            selectSQL = [NSString stringWithFormat:@"select count(*) from local_menu"];
            
            select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    //int temp = [[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] intValue];
                    
                    if ([[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] intValue] > 0) {
                        MenuFlag = 1;
                    }
                }
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                
            }
            
            selectSQL = [NSString stringWithFormat:@"select count(*) from local_sap_user"];
            
            select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    if ([[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)] intValue] > 0) {
                        UserFlag = 1;
                    }
                }
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                
            }
            
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
    }
    @finally {
        sqlite3_close(db);
        
        if (SrcFlag == 1 && MenuFlag == 1 && UserFlag == 1) {
            //[database remoteUserToLocalUser];
            NSLog(@"skip src, menu, user table update");
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"EnableLogin" object:self userInfo:nil];
            
        }
        else {
            [database remoteSrcToLocalSrc:NO];
        }
        /*{
         
            isql *database = [isql initialize];
            
            [database copyDatabaseIfNeeded];
            
            SqlClient *client =[database databaseConnect];
            //[activityIndicator startAnimating];
            
            NSString* queryString = @"select [name] from [sitesurvey].[dbo].[menu202] where Xib = 'Version'";
            
            [client executeQuery:queryString withCompletionBlock:^(SqlClientQuery *query){
                
                NSString *version = nil;
                if(query.succeeded){
                    
                    SqlResultSet *resultSet = [query.resultSets objectAtIndex:0];
                    
                    while([resultSet moveNext]) {
                        version = [NSString stringWithFormat:@"%@", [resultSet getData:0]];
                    }
                                        
                }else{
                    NSLog(@"%@", query.errorText);
                }
                
                if ([localMenuVersion isEqualToString:version]) {
                    MenuUpdated = 1;
                }
                
                if (SrcFlag == 1 && MenuFlag == 1 && MenuUpdated == 1 && UserFlag == 1) {
                    //[database remoteUserToLocalUser];
                    NSLog(@"skip src, menu, user table update");
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"EnableLogin" object:self userInfo:nil];
                }
                else {
                    [database remoteSrcToLocalSrc:NO];
                }
                
            }];
            
        }*/
                
    }
}


- (IBAction)updateUserListAction:(id)sender {
    isql *database = [isql initialize];
    self.verifyUserBtn.alpha = 0.5;
    self.verifyUserBtn.enabled = NO;
    [activityIndicator startAnimating];
    //[database remoteUserToLocalUser];
    //because it will update resfresh time, might as well change src db. it is rarely used anyway
    [database remoteSrcToLocalSrc:NO];
}

-(IBAction)dismissMyModalView
{
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSDictionary *dict= [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"index"]; 
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
}

- (void) hideKeyboard {
    //[self.view endEditing:YES];
}

@end
