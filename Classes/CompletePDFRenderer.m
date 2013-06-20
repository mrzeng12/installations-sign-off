//
//  CompletePDFRenderer.m
//  Site Survey
//
//  Created by Helpdesk on 8/23/12.
//
//
//CGContextRef ctx = UIGraphicsGetCurrentContext();
//CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 1.0);
//CGContextFillRect(ctx, CGRectMake(132 *factor, 1780 *factor, 2258 *factor, 300 *factor));

#import "CompletePDFRenderer.h"
#import "isql.h"
#import "SqlClient.h"
#import "SqlClientQuery.h"
#import "SqlResultSet.h"
#import <sqlite3.h>
#import "UIImage+fixOrientation.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "LGViewHUD.h"

@implementation CompletePDFRenderer
@synthesize callBackFunction;

- (void) loadVariablesForPDF {
    
    isql *database = [isql initialize];
    
    factor = 0.5;
    normalFont = @"FrutigerLTStd-Cn";//@"Arial";
    boldFont = @"FrutigerLTStd-BoldCn";//@"Arial-BoldMT";
    
    /*** Group 1 ***/
    classroom_number = [NSMutableArray array];
    classroom_floor = [NSMutableArray array];
    classroom_grade = [NSMutableArray array];
    classroom_notes = [NSMutableArray array];        
    general_notes = [NSMutableArray array];
    
    installer = [NSMutableArray array];
    status = [NSMutableArray array];
    serial_no = [NSMutableArray array];
    general_notes = [NSMutableArray array];
    
    Photo_file_directory_1 = [NSMutableArray array];
    Photo_file_directory_2 = [NSMutableArray array];
    Photo_file_directory_3 = [NSMutableArray array];
    Photo_file_directory_4 = [NSMutableArray array];
    Photo_file_directory_5 = [NSMutableArray array];
    Photo_file_directory_6 = [NSMutableArray array];
    Photo_file_directory_7 = [NSMutableArray array];
    Photo_file_directory_8 = [NSMutableArray array];    
       
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {            
            
            NSString *selectSQL = [NSString stringWithFormat:@"select [Room_Number], [Room_Floor_Number], [Classroom_grade], [Room_Notes], [Installer], [Status], [Serial_no], [General_notes], [Photo_file_directory_1], [Photo_file_directory_2], [Photo_file_directory_3], [Photo_file_directory_4], [Photo_file_directory_5], [Photo_file_directory_6], [Photo_file_directory_7], [Photo_file_directory_8] from local_dest where [Activity_no] = '%@' and [Teq_rep] like '%%%@%%' order by CASE WHEN cast(Room_Number as int) = 0 THEN 9999999999 ELSE cast(Room_Number as int) END, Room_Number;", database.current_activity_no, database.current_teq_rep];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if ( sqlite3_prepare_v2(db, select_stmt,  -1, &statement, NULL) == SQLITE_OK) {
                //NSLog(@"%@", selectSQL);
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    int i = 0;
                    
                    /*** group 1 ***/
                    [classroom_number addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [classroom_floor addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [classroom_grade addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [classroom_notes addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [installer  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [status  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [serial_no  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [general_notes  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    
                    [Photo_file_directory_1  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_2  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_3  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_4  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_5  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_6  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_7  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_8  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];                    
                    NSLog(@"loadVariablesForPDF for room %@ success", [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)]);
                }
                
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"prepare PDF db statement failed: %s", sqlite3_errmsg(db));
                
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_close(db);
        NSLog(@"loadVariablesForPDF success");
        
        [self rewriteVariablesToReadablePDFFields];
        
    }
    
}

-(void) rewriteVariablesToReadablePDFFields {
    
    /*** Group 1 ***/
    
    PDF_room = [NSMutableArray array];
    for (int i = 0; i < [classroom_number count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"Room %@", [classroom_number objectAtIndex:i]];
        if ([[classroom_floor objectAtIndex:i] length] > 0) {
            [string appendFormat:@", Floor %@", [classroom_floor objectAtIndex:i]];
        }
        if ([[classroom_grade objectAtIndex:i] length] > 0) {
            [string appendFormat:@", Grade %@", [classroom_grade objectAtIndex:i]];
        }
        if ([[classroom_notes objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [classroom_notes objectAtIndex:i]];
        }
        
        [PDF_room addObject:string];
    }
    
    PDF_status_installer = [NSMutableArray array];    
    for (int i = 0; i < [status count]; i++) {
        NSMutableString *temp_status_installer = [NSMutableString string];
        if ([[installer objectAtIndex:i] length] > 0) {
            [temp_status_installer appendString:[installer objectAtIndex:i]];
        }
        if ([[status objectAtIndex:i] length] > 0) {
            if ([temp_status_installer length] > 0) {
                [temp_status_installer appendString:@" / "];
            }
            [temp_status_installer appendString:[status objectAtIndex:i]];
        }
        [PDF_status_installer addObject:temp_status_installer];
    }

    PDF_serial_no = serial_no;

    PDF_comments = general_notes;
    
    PDF_photo_file_directory_1 = Photo_file_directory_1;
    
    PDF_photo_file_directory_2 = Photo_file_directory_2;
    
    PDF_photo_file_directory_3 = Photo_file_directory_3;
    
    PDF_photo_file_directory_4 = Photo_file_directory_4;
    
    PDF_photo_file_directory_5 = Photo_file_directory_5;
    
    PDF_photo_file_directory_6 = Photo_file_directory_6;
    
    PDF_photo_file_directory_7 = Photo_file_directory_7;
    
    PDF_photo_file_directory_8 = Photo_file_directory_8;
    
    NSString* fileName = [self getPDFFileName];
    
    [self drawPDF:fileName];
}

-(NSString*)getPDFFileName
{
    isql *database = [isql initialize];
       // Convert string to date object
    //completereport
    NSString* fileName = [NSString stringWithFormat:@"IR-%@-%@.PDF", (database.current_activity_no  == nil)? @"": database.current_activity_no, (database.current_username == nil)? @"":[database.current_username capitalizedString]];
    fileName = [database sanitizeFile:fileName];
    database.current_comlete_pdf_file_name = fileName;
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    return pdfFileName;
    
}

-(void)testFonts
{
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily = 0; indFamily < [familyNames count]; indFamily++) {
        
        NSLog(@"Family name:%@", [familyNames objectAtIndex:indFamily]);
        fontNames = [[NSArray alloc] initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
        for (indFont = 0; indFont < [fontNames count]; indFont++) {
            NSLog(@" Font name: %@", [fontNames objectAtIndex:indFont]);
        }
    }
}

- (UIImage *) imageWithImage: (UIImage *)image scaledToSize: (CGSize) newSize;
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)drawPDF:(NSString*)fileName
{
    
    //[self testFonts];
    isql *database = [isql initialize];
    
    NSURL *fileURL = [NSURL fileURLWithPath:fileName];
    const CGRect cgrect = {{0.0f, 0.0f},{1275,1650}};
    // Create PDF context
    CGContextRef pdfContext = CGPDFContextCreateWithURL((__bridge CFURLRef)fileURL, &cgrect, NULL);
    {
        CGPDFContextBeginPage(pdfContext, NULL);
        UIGraphicsPushContext(pdfContext);
        
        // Flip coordinate system
        CGRect bounds = CGContextGetClipBoundingBox(pdfContext);
        CGContextScaleCTM(pdfContext, 1.0, -1.0);
        CGContextTranslateCTM(pdfContext, 0.0, -bounds.size.height);
        
        //set up the background
        NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"installations-signoff-cover-page-4" ofType:@"jpg"];
        NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
        UIImage * logo = [UIImage imageWithData:imageData];        
        [logo drawInRect:CGRectMake(0, 0, 1275, 1650)];
        
        CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
        UIFont *font = [UIFont fontWithName:boldFont size:24.0f];
        [database.current_location drawInRect:CGRectMake(241, 350, 473, 68) withFont:font];
        [database.current_so drawInRect:CGRectMake(742, 350, 462, 68) withFont:font];                       
        
        font = [UIFont fontWithName:boldFont size:26.0f];
        if ([database.current_type_of_work isEqualToString:@"Installation"]) {
            [@"X" drawInRect:CGRectMake(251, 241, 21, 21) withFont:font];
        }
        if ([database.current_type_of_work isEqualToString:@"Uninstall"]) {
            [@"X" drawInRect:CGRectMake(756, 240, 21, 21) withFont:font];
        }               
                
        CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
        font = [UIFont fontWithName:normalFont
     size:21.0f];
        
        [database.current_arrival_time drawInRect:CGRectMake(289, 1201, 284, 30) withFont:font];
        [database.current_departure_time drawInRect:CGRectMake(672, 1201, 284, 30) withFont:font];
        [self drawText:database.current_print_name_1 withX:359 withY:1239 andWidth:214 andFont:font andFontSize:21.0];
        [self drawText:database.current_print_name_3 withX:359 withY:1378 andWidth:214 andFont:font andFontSize:21.0];
        [database.current_date drawInRect:CGRectMake(1101, 1201, 108, 30) withFont:font];
        
        [[self conciseText:database.current_customer_notes] drawInRect:CGRectMake(359, 1276, 845, 86) withFont:font];
        
        NSString *imageString1 = database.current_signature_file_directory_1;
        if ([imageString1 length] > 0) {
            UIImage *backgroundImage1 = [self loadImage: imageString1 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
            [backgroundImage1 drawInRect:CGRectMake(743, 1230, 88, 35)];
            [database.current_date drawInRect:CGRectMake(1101, 1239, 108, 30) withFont:font];
        }
        
        NSString *imageString3 = database.current_signature_file_directory_3;
        if ([imageString3 length] > 0) {
            UIImage *backgroundImage3 = [self loadImage: imageString3 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
            [backgroundImage3 drawInRect:CGRectMake(743, 1369, 88, 35)];
            [database.current_date drawInRect:CGRectMake(1101, 1378, 108, 30) withFont:font];
        } 
        
        // Clean up
        UIGraphicsPopContext();
        CGPDFContextEndPage(pdfContext);       
    }
    [self printReports:pdfContext];
    //[self printRooms:pdfContext withRoomIndex:0];
}

- (void) printReports: (CGContextRef) pdfContext {
    
    isql *database = [isql initialize];
    CGPDFContextBeginPage(pdfContext, NULL);
    UIGraphicsPushContext(pdfContext);
    
    // Flip coordinate system
    CGRect bounds = CGContextGetClipBoundingBox(pdfContext);
    CGContextScaleCTM(pdfContext, 1.0, -1.0);
    CGContextTranslateCTM(pdfContext, 0.0, -bounds.size.height);
    
    // Drawing commands
    
    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"installation-reports-3" ofType:@"jpg"];
    NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
    UIImage * logo = [UIImage imageWithData:imageData];
    [logo drawInRect:CGRectMake(0, 0, 1275, 1650)];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    UIFont *font = [UIFont fontWithName:normalFont size:21.0f];
    [self drawText:database.current_location withX:183 withY:253 andWidth:421 andFont:font andFontSize:21];
    [self drawText:database.current_pod withX:679 withY:253 andWidth:519 andFont:font andFontSize:21];
    [self drawText:database.current_district withX:134 withY:297 andWidth:472 andFont:font andFontSize:21];
    [self drawText:database.current_so withX:670 withY:297 andWidth:146 andFont:font andFontSize:21];
    [self drawText:database.current_primary_contact withX:907 withY:297 andWidth:291 andFont:font andFontSize:21];
    [self drawText:database.current_job_status withX:160 withY:341 andWidth:1039 andFont:font andFontSize:21];
    [self drawText:database.current_date withX:118 withY:407 andWidth:210 andFont:font andFontSize:21];
    [self drawText:database.current_arrival_time withX:492 withY:407 andWidth:246 andFont:font andFontSize:21];
    [self drawText:database.current_departure_time withX:774 withY:407 andWidth:246 andFont:font andFontSize:21];
    [self drawText:database.current_reason_for_visit withX:199 withY:451 andWidth:999 andFont:font andFontSize:21];
    
    [[self conciseText:database.current_job_summary] drawInRect:CGRectMake(68, 526, 1130, 299) withFont:font];
    
    //PDF_room;    PDF_status_installer;    PDF_serial_no;    PDF_comments;
    int row_number = 0;
    int row_number2 = 0;
    int row_number3 = 0;
    for (int i = 0; i < [PDF_room count]; i++) {
        NSString *serial_string = [PDF_serial_no objectAtIndex:i];
        
        NSData *data = [serial_string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e = nil;
        NSMutableArray *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];

        float height = [self textAreaHight: [self conciseText:[PDF_comments objectAtIndex:i]] withRect:CGRectMake(0, 0, 317, 100000) andFont:font];
        int int_height = (int) ceilf(height);
        int number_of_lines;
        if (int_height % 44 == 0) {
            number_of_lines = int_height / 44;
        }
        else {
            number_of_lines = int_height / 44 + 1;
        }
        
        if ([dictArray count] > number_of_lines) {
            number_of_lines = [dictArray count];
        }
        if (number_of_lines == 0) {
            number_of_lines = 1;
        }
        // draw table cells
        for (int j = 0; j < number_of_lines; j++) {            
            
            NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"table-cell" ofType:@"jpg"];
            NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
            UIImage * logo = [UIImage imageWithData:imageData];
            [logo drawInRect:CGRectMake(56, 882 + row_number * 44, 1152, 44)];
            row_number++;
        }
        // draw room
        [self drawText:[PDF_room objectAtIndex:i] withX:68 withY:892 + row_number3 * 44 andWidth:128 andFont:font andFontSize:21.0];
        // draw status installer
        [self drawText:[PDF_status_installer objectAtIndex:i] withX:208 withY:892 + row_number3 * 44 andWidth:265 andFont:font andFontSize:21.0];
        // draw serial
        for (int j = 0; j < [dictArray count]; j++) {
            NSMutableDictionary *dict = [dictArray objectAtIndex:j];
            NSString *type_and_serial = [NSString stringWithFormat:@"%@: %@", [dict objectForKey:@"type"], [dict objectForKey:@"serial"]];
            
            //[self drawText:type_and_serial withX:485 withY:892 + row_number2 * 44 andWidth:394 andFont:font andFontSize:21];
            [self drawText:type_and_serial withX:485 withY:892 + row_number2 * 44 andWidth:394 andFont:font andFontSize:21.0];
            row_number2++;
        }
        //draw comments
        NSString *comments = [self conciseText:[PDF_comments objectAtIndex:i]];
        [comments drawInRect:CGRectMake(891, 892 + row_number3 * 44, 317, 100000) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
        row_number3 += [dictArray count];
    }
    
    UIGraphicsPopContext();
    CGPDFContextEndPage(pdfContext);
    //close up
    CGPDFContextClose(pdfContext);
    CGContextRelease(pdfContext);
    NSLog(@"create %@", database.current_comlete_pdf_file_name);
    if ([callBackFunction isEqualToString:@"preview"]) {
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"showCompletePDF" object:self userInfo:nil];
        [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    }
    else if ([callBackFunction isEqualToString:@"saving"]) {
        [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    }
    else if ([callBackFunction isEqualToString:@"finishEditing"]) {
        
        [database resetVariables];
        database.current_classroom_number = nil;
        database.current_classroom_floor = nil;
        database.current_classroom_grade = nil;
        database.current_classroom_notes = nil;
        database.current_raceway_part_9 = nil;
        database.current_raceway_part_10 = nil;
        [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
    }
    else if ([callBackFunction isEqualToString:@"sync"]){
        [database resetVariables];
        database.current_classroom_number = nil;
        database.current_classroom_floor = nil;
        database.current_classroom_grade = nil;
        database.current_classroom_notes = nil;
        database.current_raceway_part_9 = nil;
        database.current_raceway_part_10 = nil;
        
        [database uploadSpeedTestFile];
        //[database localDestToRemoteDest];
        //[database remoteSrcToLocalSrc:YES];
    }
    else if ([callBackFunction isEqualToString:@"continueToCreateNewActivity"]){
        [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"continueToCreateNewActivity" object:self userInfo:nil];
    }
    else if ([callBackFunction isEqualToString:@"continueToLoadOldActivity"]){
        [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"continueToLoadOldActivity" object:self userInfo:nil];
    }
    else if ([callBackFunction isEqualToString:@"continueToCreateEmptySurvey"]){
        [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"continueToCreateEmptySurvey" object:self userInfo:nil];
    }
    return;
}
- (void) printReportsPageEmptyWithTitle: (CGContextRef) pdfContext AndIndex: (int) index {
    
}
- (void) printReportsPageEmpty: (CGContextRef) pdfContext {
    
}

- (void)drawText: (NSString *) string withX: (CGFloat) x withY: (CGFloat) y andWidth: (CGFloat) width andFont: (UIFont *)font andFontSize: (CGFloat) fontsize {
    
    float serial_height = [self textAreaHight: string withRect:CGRectMake(0, 0, width, 100000) andFont:font];
    if (serial_height > 88) {
        font = [UIFont fontWithName:normalFont size:15.0f];
        [string drawInRect:CGRectMake(x, y - 3, width, 100000) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
    }
    else if (serial_height > 44) {
        font = [UIFont fontWithName:normalFont size:18.0f];
        [string drawInRect:CGRectMake(x, y - 7, width, 100000) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
    }
    else {
        [string drawInRect:CGRectMake(x, y, width, 100000) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
    }
    if (serial_height > 44) {
        font = [UIFont fontWithName:normalFont size:fontsize];
    }
    
    //[string drawAtPoint:CGPointMake(x, y) forWidth:width withFont:font minFontSize:12.0 actualFontSize:&fontsize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
}

- (float)textAreaHight: (NSString *) string withRect: (CGRect) rect andFont: (UIFont *) font {
    CGFloat *width = &rect.size.width;        
    return [string sizeWithFont:font constrainedToSize:CGSizeMake(*width, 100000) lineBreakMode:NSLineBreakByWordWrapping].height;
}

- (NSString *)conciseText: (NSString *)string {
    NSArray *array = [NSArray array];
    array = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *array_updated = [NSMutableArray array];
    for (NSString *breakdown in array) {
        if ([breakdown length] > 0) {
            [array_updated addObject:breakdown];
        }
    }
    return [array_updated componentsJoinedByString:@"; "];
}

- (void) printRooms: (CGContextRef) pdfContext withRoomIndex: (int) i {
    //for (int i = 0; i < [PDF_board count]; i++)
    //{
    isql *database = [isql initialize];
    if (i == [PDF_comments count]) {
        CGPDFContextClose(pdfContext);
        CGContextRelease(pdfContext);
        NSLog(@"create %@", database.current_comlete_pdf_file_name);
        if ([callBackFunction isEqualToString:@"preview"]) {
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"showCompletePDF" object:self userInfo:nil];
            [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
        }
        else if ([callBackFunction isEqualToString:@"saving"]) {
            [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
        }
        else if ([callBackFunction isEqualToString:@"finishEditing"]) {
            
            [database resetVariables];
            database.current_classroom_number = nil;
            database.current_classroom_floor = nil;
            database.current_classroom_grade = nil;
            database.current_classroom_notes = nil;
            database.current_raceway_part_9 = nil;
            database.current_raceway_part_10 = nil;
            [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
        }
        else if ([callBackFunction isEqualToString:@"sync"]){
            [database resetVariables];
            database.current_classroom_number = nil;
            database.current_classroom_floor = nil;
            database.current_classroom_grade = nil;
            database.current_classroom_notes = nil;
            database.current_raceway_part_9 = nil;
            database.current_raceway_part_10 = nil;
            
            [database uploadSpeedTestFile];
            //[database localDestToRemoteDest];
            //[database remoteSrcToLocalSrc:YES];
        }
        else if ([callBackFunction isEqualToString:@"continueToCreateNewActivity"]){
            [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"continueToCreateNewActivity" object:self userInfo:nil];
        }
        else if ([callBackFunction isEqualToString:@"continueToLoadOldActivity"]){
            [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"continueToLoadOldActivity" object:self userInfo:nil];
        }
        else if ([callBackFunction isEqualToString:@"continueToCreateEmptySurvey"]){
            [[LGViewHUD defaultHUD] hideWithAnimation:HUDAnimationHideFadeOut];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"continueToCreateEmptySurvey" object:self userInfo:nil];
        }
        return;
    }
    CGPDFContextBeginPage(pdfContext, NULL);
    UIGraphicsPushContext(pdfContext);
    
    // Flip coordinate system
    CGRect bounds = CGContextGetClipBoundingBox(pdfContext);
    CGContextScaleCTM(pdfContext, 1.0, -1.0);
    CGContextTranslateCTM(pdfContext, 0.0, -bounds.size.height);
    
    // Drawing commands
    
    //NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"site-survey-customer-report" ofType:@"jpg"];
    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"site-survey-blank-page" ofType:@"jpg"];
    NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
    UIImage * logo = [UIImage imageWithData:imageData];
    [logo drawInRect:CGRectMake(0, 0, 2550 *factor, 3300 *factor)];
    
    //first two green lines
    //CGContextSetFillColorWithColor(pdfContext, [UIColor colorWithRed:142.0/255.0 green:198.0/255.0 blue:63.0/255.0 alpha:1.0].CGColor);
    CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    UIFont *font = [UIFont fontWithName:boldFont
                                   size:48.0f *factor];
    [[NSString stringWithFormat:@"%@, %@",database.current_location, database.current_date ] drawAtPoint:CGPointMake(468 *factor, 259 *factor) withFont: font];
    // [database.current_address drawAtPoint:CGPointMake(468, 332) withFont: font];
    [[PDF_room objectAtIndex: i] drawAtPoint:CGPointMake(468 *factor, 332 *factor) withFont: font];
    
    //first row
    float bl_projection = 527;
    fileLocation = [[NSBundle mainBundle] pathForResource:@"black-line" ofType:@"png"];
    imageData = [NSData dataWithContentsOfFile:fileLocation];
    logo = [UIImage imageWithData:imageData];
    [logo drawInRect:CGRectMake(0, (bl_projection+293) *factor, 2549 *factor, 29 *factor)];
    
    // Clean up
    UIGraphicsPopContext();
    CGPDFContextEndPage(pdfContext);
    
    CGPDFContextBeginPage(pdfContext, NULL);
    UIGraphicsPushContext(pdfContext);
    
    // Flip coordinate system
    bounds = CGContextGetClipBoundingBox(pdfContext);
    CGContextScaleCTM(pdfContext, 1.0, -1.0);
    CGContextTranslateCTM(pdfContext, 0.0, -bounds.size.height);
    
    // Drawing commands
    
    //NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"site-survey-customer-report" ofType:@"jpg"];
    fileLocation = [[NSBundle mainBundle] pathForResource:@"site-survey-blank-page" ofType:@"jpg"];
    imageData = [NSData dataWithContentsOfFile:fileLocation];
    logo = [UIImage imageWithData:imageData];
    [logo drawInRect:CGRectMake(0, 0, 2550 *factor, 3300 *factor)];
    
    //first two green lines
    //CGContextSetFillColorWithColor(pdfContext, [UIColor colorWithRed:142.0/255.0 green:198.0/255.0 blue:63.0/255.0 alpha:1.0].CGColor);
    font = [UIFont fontWithName:boldFont
                           size:48.0f *factor];
    [[NSString stringWithFormat:@"%@, %@",database.current_location, database.current_date ] drawAtPoint:CGPointMake(468 *factor, 259 *factor) withFont: font];
    // [database.current_address drawAtPoint:CGPointMake(468, 332) withFont: font];
    [[PDF_room objectAtIndex: i] drawAtPoint:CGPointMake(468 *factor, 332 *factor) withFont: font];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor grayColor].CGColor);
    font = [UIFont fontWithName:normalFont
                           size:48.0f *factor];
    
    float cm_client = 527;
    
    [@"Comments: " drawAtPoint:CGPointMake(129 *factor, (cm_client) *factor) withFont: font];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    font = [UIFont fontWithName:boldFont
                           size:48.0f *factor];
    [[PDF_comments objectAtIndex:i] drawInRect:CGRectMake(129 *factor, (cm_client+80) *factor, 850 *factor, 1600 *factor) withFont:font];
           
   
    NSMutableArray *urls = [NSMutableArray arrayWithObjects: nil];
    if ([[PDF_photo_file_directory_1 objectAtIndex:i] length] > 0) {
        [urls addObject:[PDF_photo_file_directory_1 objectAtIndex:i]];
    }
    if ([[PDF_photo_file_directory_2 objectAtIndex:i] length] > 0) {
        [urls addObject:[PDF_photo_file_directory_2 objectAtIndex:i]];
    }
    if ([[PDF_photo_file_directory_3 objectAtIndex:i] length] > 0) {
        [urls addObject:[PDF_photo_file_directory_3 objectAtIndex:i]];
    }
    if ([[PDF_photo_file_directory_4 objectAtIndex:i] length] > 0) {
        [urls addObject:[PDF_photo_file_directory_4 objectAtIndex:i]];
    }
    if ([[PDF_photo_file_directory_5 objectAtIndex:i] length] > 0) {
        [urls addObject:[PDF_photo_file_directory_5 objectAtIndex:i]];
    }
    if ([[PDF_photo_file_directory_6 objectAtIndex:i] length] > 0) {
        [urls addObject:[PDF_photo_file_directory_6 objectAtIndex:i]];
    }
    if ([[PDF_photo_file_directory_7 objectAtIndex:i] length] > 0) {
        [urls addObject:[PDF_photo_file_directory_7 objectAtIndex:i]];
    }
    if ([[PDF_photo_file_directory_8 objectAtIndex:i] length] > 0) {
        [urls addObject:[PDF_photo_file_directory_8 objectAtIndex:i]];
    }
    CGRect rect1 = CGRectMake(129 *factor, 1950 *factor, 1100 *factor, 1100 *factor);
    CGRect rect2 = CGRectMake(1300 *factor, 1950 *factor, 1100 *factor, 1100 *factor);
    CGRect rect3 = CGRectMake(129 *factor, 500 *factor, 1100 *factor, 1100 *factor);
    CGRect rect4 = CGRectMake(1300 *factor, 500 *factor, 1100 *factor, 1100 *factor);
    CGRect rect5 = CGRectMake(129 *factor, 1900 *factor, 1100 *factor, 1100 *factor);
    CGRect rect6 = CGRectMake(1300 *factor, 1900 *factor, 1100 *factor, 1100 *factor);
    CGRect rect7 = CGRectMake(129 *factor, 500 *factor, 1100 *factor, 1100 *factor);
    CGRect rect8 = CGRectMake(1300 *factor, 500 *factor, 1100 *factor, 1100 *factor);
    /*
    CGRect rect1 = CGRectMake(129 *factor, 500 *factor, 1100 *factor, 1100 *factor);
    CGRect rect2 = CGRectMake(1300 *factor, 500 *factor, 1100 *factor, 1100 *factor);
    CGRect rect3 = CGRectMake(129 *factor, 1900 *factor, 1100 *factor, 1100 *factor);
    CGRect rect4 = CGRectMake(1300 *factor, 1900 *factor, 1100 *factor, 1100 *factor);
    CGRect rect5 = CGRectMake(129 *factor, 500 *factor, 1100 *factor, 1100 *factor);
    CGRect rect6 = CGRectMake(1300 *factor, 500 *factor, 1100 *factor, 1100 *factor);
    CGRect rect7 = CGRectMake(129 *factor, 1900 *factor, 1100 *factor, 1100 *factor);
    CGRect rect8 = CGRectMake(1300 *factor, 1900 *factor, 1100 *factor, 1100 *factor);
    */
    NSArray *rectArray = [NSArray arrayWithObjects:[NSValue valueWithCGRect:rect1], [NSValue valueWithCGRect:rect2],[NSValue valueWithCGRect:rect3], [NSValue valueWithCGRect:rect4],[NSValue valueWithCGRect:rect5], [NSValue valueWithCGRect:rect6],[NSValue valueWithCGRect:rect7], [NSValue valueWithCGRect:rect8], nil];
    
    [self loadImage:urls withPDFContent:pdfContext andURLIndex:0 andRects:rectArray andRoomIndex:i];
    //UIGraphicsPopContext();
    //CGPDFContextEndPage(pdfContext);
    
    //}
}

- (void) loadImage: (NSMutableArray *)urls withPDFContent: (CGContextRef)pdfContext andURLIndex: (int) index andRects: (NSArray *) rectArray andRoomIndex: (int) roomIndex {
    
    if (index == 2) {
        UIGraphicsPopContext();
        CGPDFContextEndPage(pdfContext);
        
        //if ([[[urls objectAtIndex:0] absoluteString] length] < 10) {
        if ([urls count] <= 2) {
            /*
            CGPDFContextClose(pdfContext);
            CGContextRelease(pdfContext);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"showCompletePDF" object:self userInfo:nil];
             */
            [self printRooms:pdfContext withRoomIndex:(roomIndex+1)];
            return;
        }
        else {
            //going to create a third page.
            CGPDFContextBeginPage(pdfContext, NULL);
            UIGraphicsPushContext(pdfContext);
            // Flip coordinate system
            CGRect bounds = CGContextGetClipBoundingBox(pdfContext);
            CGContextScaleCTM(pdfContext, 1.0, -1.0);
            CGContextTranslateCTM(pdfContext, 0.0, -bounds.size.height);
            
            // Drawing commands
            
            //NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"site-survey-customer-report" ofType:@"jpg"];
            NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"site-survey-blank-page" ofType:@"jpg"];
            NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
            UIImage *logo = [UIImage imageWithData:imageData];
            [logo drawInRect:CGRectMake(0, 0, 2550 *factor, 3300 *factor)];
            
            //first two green lines
            CGContextSetFillColorWithColor(pdfContext, [UIColor colorWithRed:142.0/255.0 green:198.0/255.0 blue:63.0/255.0 alpha:1.0].CGColor);
            UIFont *font = [UIFont fontWithName:boldFont
     size:48.0f *factor];
            isql *database = [isql initialize];
            [[NSString stringWithFormat:@"%@, %@",database.current_location, database.current_date ] drawAtPoint:CGPointMake(468 *factor, 259 *factor) withFont: font];
            // [database.current_address drawAtPoint:CGPointMake(468, 332) withFont: font];
            [[PDF_room objectAtIndex: roomIndex] drawAtPoint:CGPointMake(468 *factor, 332 *factor) withFont: font];
        }
    }
    if (index == 6) {
        UIGraphicsPopContext();
        CGPDFContextEndPage(pdfContext);
        
        //if ([[[urls objectAtIndex:4] absoluteString] length] < 10) {
        if ([urls count] <= 6) {
            /*
            CGPDFContextClose(pdfContext);
            CGContextRelease(pdfContext);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"showCompletePDF" object:self userInfo:nil];
             */
            [self printRooms:pdfContext withRoomIndex:(roomIndex+1)];
            return;
        }
        else {
            //going to create a third page.
            CGPDFContextBeginPage(pdfContext, NULL);
            UIGraphicsPushContext(pdfContext);
            // Flip coordinate system
            CGRect bounds = CGContextGetClipBoundingBox(pdfContext);
            CGContextScaleCTM(pdfContext, 1.0, -1.0);
            CGContextTranslateCTM(pdfContext, 0.0, -bounds.size.height);
            
            // Drawing commands
            
            //NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"site-survey-customer-report" ofType:@"jpg"];
            NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"site-survey-blank-page" ofType:@"jpg"];
            NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
            UIImage *logo = [UIImage imageWithData:imageData];
            [logo drawInRect:CGRectMake(0, 0, 2550 *factor, 3300 *factor)];
            
            //first two green lines
            CGContextSetFillColorWithColor(pdfContext, [UIColor colorWithRed:142.0/255.0 green:198.0/255.0 blue:63.0/255.0 alpha:1.0].CGColor);
            UIFont *font = [UIFont fontWithName:boldFont
     size:48.0f *factor];
            isql *database = [isql initialize];
            [[NSString stringWithFormat:@"%@, %@",database.current_location, database.current_date ] drawAtPoint:CGPointMake(468 *factor, 259 *factor) withFont: font];
            // [database.current_address drawAtPoint:CGPointMake(468, 332) withFont: font];
            [[PDF_room objectAtIndex: roomIndex] drawAtPoint:CGPointMake(468 *factor, 332 *factor) withFont: font];
        }
    }
    if (index == 8) {
        UIGraphicsPopContext();
        CGPDFContextEndPage(pdfContext);
        /*
        CGPDFContextClose(pdfContext);
        CGContextRelease(pdfContext);
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"showCompletePDF" object:self userInfo:nil];
         */
        [self printRooms:pdfContext withRoomIndex:(roomIndex+1)];
        return;
    }
    
    if ([urls count] > index) {
        
        UIImage *myImage = [self loadImage: [urls objectAtIndex:index] ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        
        if (myImage != nil) {
            
            //myImage = [myImage fixOrientationWithOrientation:5];
            NSValue *tempValue = [rectArray objectAtIndex:index];
            
            CGRect tempRect = [tempValue CGRectValue];
            float tempHeight = myImage.size.height;
            float tempWidth = myImage.size.width;
            if (tempHeight > tempWidth) {
                tempWidth = tempWidth / tempHeight * (1100 *factor);
                tempHeight = 1100 *factor;
            }
            else {
                tempHeight = tempHeight / tempWidth * (1100 *factor);
                tempWidth = 1100 *factor;
            }
            
            NSData *imageData = UIImageJPEGRepresentation(myImage, 0.75);
            myImage = [UIImage imageWithData:imageData];
            tempRect = CGRectMake(tempRect.origin.x, tempRect.origin.y, tempWidth, tempHeight);
            
            [myImage drawInRect:tempRect];
            myImage = nil;
            //CGImageRelease(imageRef);
            
        }
    }
    
    [self loadImage:urls withPDFContent:pdfContext andURLIndex:(index+1) andRects:rectArray andRoomIndex:roomIndex];
    
}   

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    return result;
}

@end
