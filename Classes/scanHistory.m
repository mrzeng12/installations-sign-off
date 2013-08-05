//
//  scanHistory.m
//  Installation
//
//  Created by Chao Zeng on 8/2/13.
//
//

#import "scanHistory.h"
#import "RedLaserSDK.h"
#import "isql.h"

@interface scanHistory ()

@end

@implementation scanHistory

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
}

- (void)viewDidAppear:(BOOL)animated {
    @try {
        NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                      NSUserDomainMask, YES) objectAtIndex:0];
        NSString *archivePath = [documentsDir stringByAppendingPathComponent:@"ScanHistoryArchive"];
        scanHistoryArray = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
    }
    @catch (...)
    {
    }
    if (!scanHistoryArray)
        scanHistoryArray = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return [scanHistoryArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSMutableDictionary *scanSession = [scanHistoryArray objectAtIndex:section];
	
	NSDate *scanTime = [scanSession objectForKey:@"Session End Time"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	NSString *formattedDateString = [dateFormatter stringFromDate:scanTime];
	
	return formattedDateString;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSMutableDictionary *scanSession = [scanHistoryArray objectAtIndex:section];
	
	return [[scanSession objectForKey:@"Scanned Items"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get the barcodeResult that has the data backing this cell
	NSMutableDictionary *scanSession = [scanHistoryArray objectAtIndex:indexPath.section];
	BarcodeResult *barcode = [[scanSession objectForKey:@"Scanned Items"] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = barcode.barcodeString;
			
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    isql *database = [isql initialize];
    NSMutableDictionary *scanSession = [scanHistoryArray objectAtIndex:indexPath.section];
	BarcodeResult *barcode = [[scanSession objectForKey:@"Scanned Items"] objectAtIndex:indexPath.row];    
    database.scanBarCode = barcode.barcodeString;
  
    [self.thirdViewController.scanHistoryPopoverController dismissPopoverAnimated:YES];
    if (self.thirdViewController.scanTag == 0) {
        self.thirdViewController.SerialSB.text = database.scanBarCode;
    }
    else if (self.thirdViewController.scanTag == 1) {
        self.thirdViewController.SerialPJ.text = database.scanBarCode;
    }
    else if (self.thirdViewController.scanTag == 2) {
        self.thirdViewController.SerialSK.text = database.scanBarCode;
    }
    else {
        NSMutableDictionary *dict = [self.thirdViewController.addBtnArray objectAtIndex:(self.thirdViewController.scanTag-3)];
        UITextField *textField = [dict objectForKey:@"textFieldRounded"];
        textField.text = database.scanBarCode;
    }
    [self.thirdViewController saveSerialNumber];
    [self.thirdViewController checkComplete];
}

@end
