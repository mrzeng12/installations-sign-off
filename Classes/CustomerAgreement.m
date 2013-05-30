//
//  CustomerAgreement.m
//  Site Survey
//
//  Created by Helpdesk on 8/1/12.
//
//

#import "CustomerAgreement.h"
//#import "PDFModal.h"
#import "FirstDetailView4.h"
#import "isql.h"
#import <sqlite3.h>
#import "LGViewHUD.h"
#import "CompletePDFRenderer.h"
#import "quickLookModal.h"
#import <QuickLook/QuickLook.h>

@interface CustomerAgreement ()

@end

@implementation CustomerAgreement
@synthesize firstSwitch;
@synthesize secondSwitch;
@synthesize roomListTextView;
@synthesize cell1;
@synthesize cell2;
@synthesize tableview;
@synthesize firstdetailview4;
@synthesize viewPDFbtn;
@synthesize option2btn;

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
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(gotoSignaturePage:)
     name:@"gotoSignaturePage" object:nil];
    
    [tableview setBackgroundView:nil];
    [tableview setBackgroundColor:nil];
    tableview.scrollEnabled = NO;
    roomListTextView.editable = NO;
    
    firstSwitch = [[UICustomSwitch alloc] initWithFrame: CGRectMake(55, 20, 87, 23)];
    [firstSwitch addTarget: self action: @selector(firstSwitch:) forControlEvents:UIControlEventValueChanged];
    // Set the desired frame location of onoff here
    [self.cell1 addSubview: firstSwitch];

    secondSwitch = [[UICustomSwitch alloc] initWithFrame: CGRectMake(55, 20, 87, 23)];
    [secondSwitch addTarget: self action: @selector(secondSwitch:) forControlEvents:UIControlEventValueChanged];
    // Set the desired frame location of onoff here
    [self.cell2 addSubview: secondSwitch];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setFirstdetailview4:nil];
    [self setViewPDFbtn:nil];
    [self setOption2btn:nil];
    [self setSecondSwitch:nil];
    [self setFirstSwitch:nil];
    [self setRoomListTextView:nil];
    [self setCell1:nil];
    [self setCell2:nil];
    [self setTableview:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)viewWillAppear:(BOOL)animated
{
    viewPDFbtn.enabled = NO;
    viewPDFbtn.alpha = 0.5;
    
    option2btn.enabled = NO;
    option2btn.alpha = 0.5;
    
    [self loadRoomFromDB];
    roomListTextView.text = roomListString;
    
    // data persistence
    isql *database = [isql initialize];
    if([database.current_agreement_1 isEqualToString:@"Yes"]){
        firstSwitch.on = YES;
    }
    else{
        firstSwitch.on = NO;
        database.current_agreement_1 = @"No";
    }
    if([database.current_agreement_2 isEqualToString:@"Yes"]){
        secondSwitch.on = YES;
    }
    else{
        secondSwitch.on = NO;
        database.current_agreement_2 = @"No";
    }
    
    [self checkSwitchState];
    [super viewWillAppear:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    //isql *database = [isql initialize];
    //[NSThread detachNewThreadSelector:@selector(myThreadMethodAfterExit:) toTarget:self withObject:nil];
    //[database updateLocalDestForCoverPage];
    
    //CompletePDFRenderer *renderer = [CompletePDFRenderer new];
    //renderer.callBackFunction = @"saving";
    
    //[renderer loadVariablesForPDF];
     
    [super viewDidDisappear:YES];
}

- (void)myThreadMethodAfterExit:(id)options
{
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    
    hud.activityIndicatorOn = YES;
    
    hud.topText = @"Loading";
    
    hud.bottomText = @"Please wait...";
    
    [hud showInView:super.splitViewController.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (IBAction)viewPDF:(id)sender {
    
    /*
    PDFModal *temp = [[PDFModal alloc] initWithNibName:@"PDFModal" bundle:[NSBundle mainBundle]];
    
    temp.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    // ANIMATED TRANSITION WILL RESULT IN ERROR
    //[super.splitViewController presentModalViewController:temp animated: YES];
    [super.splitViewController presentViewController:temp animated:YES completion:nil];
     */
    /*
    LGViewHUD *hud = [LGViewHUD defaultHUD];
    
    hud.activityIndicatorOn = YES;
    
    hud.topText = @"Loading";
    
    hud.bottomText = @"Please wait...";
    
    [hud showInView:super.splitViewController.view];
    */
    isql *database = [isql initialize];
    
    [NSThread detachNewThreadSelector:@selector(myThreadMethodAfterExit:) toTarget:self withObject:nil];
    
    [database saveVariableToLocalDest];
    
    //do not update the whole activity for PDF
    //[database updateLocalDestForSummary];
    
    CompletePDFRenderer *renderer = [CompletePDFRenderer new];
    renderer.callBackFunction = @"preview";
    
    [renderer loadVariablesForPDF];
}

-(void)gotoSignaturePage:(NSNotification*)notifications {
    
    [self.navigationController pushViewController:self.firstdetailview4 animated:YES];
}
 - (IBAction)option2:(id)sender {
    [self.navigationController pushViewController:self.firstdetailview4 animated:YES];
}
- (IBAction)firstSwitch:(id)sender {
    [self checkSwitchState];
    isql *database = [isql initialize];
    if (firstSwitch.isOn == YES) {
        database.current_agreement_1 = @"Yes";
    }
    else {
        database.current_agreement_1 = @"No";
    }
}

- (IBAction)secondSwitch:(id)sender {
    [self checkSwitchState];
    isql *database = [isql initialize];
    if (secondSwitch.isOn == YES) {
        database.current_agreement_2 = @"Yes";
    }
    else {
        database.current_agreement_2 = @"No";
    }
}
- (void)checkSwitchState {
    if (firstSwitch.isOn == YES && secondSwitch.isOn == YES) {
        viewPDFbtn.enabled = YES;
        viewPDFbtn.alpha = 1;
        option2btn.enabled = YES;
        option2btn.alpha = 1;
    }
    else {
        viewPDFbtn.enabled = NO;
        viewPDFbtn.alpha = 0.5;
        option2btn.enabled = NO;
        option2btn.alpha = 0.5;
    }
}
-(void)loadRoomFromDB {
    
    //load schoolName, teqRep, activityNo, date from variable
    isql *database = [isql initialize];    
        
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        roomList = [NSMutableArray array];
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSString *selectSQL = [NSString stringWithFormat:@"select Room_Number from local_dest where [Activity_no] = '%@' and [Teq_rep] like '%%%@%%' order by CASE WHEN cast(Room_Number as int) = 0 THEN 9999999999 ELSE cast(Room_Number as int) END, Room_Number;", database.current_activity_no, database.current_teq_rep];
            
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {                    
                    
                    [roomList addObject:[[NSString alloc]
                                             initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 0)]];                   
                }
                               
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare db statement failed: %s", sqlite3_errmsg(db));
                
            }
        }        
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
        roomListString = [NSMutableString string];
        for (int i=0; i<[roomList count]; i++) {
            [roomListString appendString:[roomList objectAtIndex:i]];
            if (i<[roomList count] - 1) {
                [roomListString appendString:@", "];
            }
        }
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row] == 0) {
        return cell1;
    }
    else {
        return cell2;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
@end
