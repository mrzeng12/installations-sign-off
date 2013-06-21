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

    int row_number = 0; //for drawing table cells
    int row_number2 = 0;    //for drawing serials
    int row_number3 = 0;    //for drawing room number, installer, comments
    int page = 0;
    for (int i = 0; i < [PDF_room count]; i++) {
        
        //parse serial number
        NSString *serial_string = [PDF_serial_no objectAtIndex:i];
        
        NSData *data = [serial_string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e = nil;
        NSMutableArray *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];

        //decide how many lines needed in this room
        float height_room = [self textAreaHight: [PDF_room objectAtIndex:i] withRect:CGRectMake(0, 0, 128, 100000) andFont:font];
        float height_installer = [self textAreaHight: [PDF_status_installer objectAtIndex:i] withRect:CGRectMake(0, 0, 265, 100000) andFont:font];
        float height_comments = [self textAreaHight: [self conciseText:[PDF_comments objectAtIndex:i]] withRect:CGRectMake(0, 0, 317, 100000) andFont:font];
        float height_serial = 0;
        NSMutableArray *rows_needed_for_serial = [NSMutableArray array];
        for (int j = 0; j < [dictArray count]; j++) {
            NSMutableDictionary *dict = [dictArray objectAtIndex:j];
            NSString *type_and_serial = [NSString stringWithFormat:@"%@: %@", [dict objectForKey:@"type"], [dict objectForKey:@"serial"]];
            float height_one_serial = [self textAreaHight: type_and_serial withRect:CGRectMake(0, 0, 394, 100000) andFont:font];
            int rows_needed = [self findNumberOfLines:height_one_serial withLineHeight:44];
            [rows_needed_for_serial addObject:[NSNumber numberWithInt:rows_needed]];
            height_serial += rows_needed * 44;
        }
        
        float highest = height_room;
        if (height_installer > highest) highest = height_installer;
        if (height_comments > highest) highest = height_comments;
        if (height_serial > highest) highest = height_serial;
        int number_of_lines = [self findNumberOfLines:highest withLineHeight:44];
        
        if ([dictArray count] > number_of_lines) {
            number_of_lines = [dictArray count];
        }
        if (number_of_lines == 0) {
            number_of_lines = 1;
        }
        //decide where the data form row ends
        int cutoff_rows;
        if (page == 0) {
            cutoff_rows = 16;
        }
        else {
            cutoff_rows = 30;
        }
        if ((row_number + number_of_lines) > cutoff_rows) {
            
            UIGraphicsPopContext();
            CGPDFContextEndPage(pdfContext);
            
            CGPDFContextBeginPage(pdfContext, NULL);
            UIGraphicsPushContext(pdfContext);
            
            // Flip coordinate system
            CGRect bounds = CGContextGetClipBoundingBox(pdfContext);
            CGContextScaleCTM(pdfContext, 1.0, -1.0);
            CGContextTranslateCTM(pdfContext, 0.0, -bounds.size.height);
            
            // Drawing backgrounds            
            NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"installation-reports-2" ofType:@"jpg"];
            NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
            UIImage * logo = [UIImage imageWithData:imageData];
            [logo drawInRect:CGRectMake(0, 0, 1275, 1650)];
            row_number = 0;
            row_number2 = 0;
            row_number3 = 0;
            page++;
        }
        float base_height;
        if (page == 0) {
            base_height = 882;
        }
        else {
            base_height = 234;
        }
        // draw table cells
        for (int j = 0; j < number_of_lines; j++) {            
            
            NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"table-cell" ofType:@"jpg"];
            NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
            UIImage * logo = [UIImage imageWithData:imageData];
            [logo drawInRect:CGRectMake(56, base_height + row_number * 44, 1152, 44)];
            row_number++;
        }
        // draw blank space in the form.
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(pdfContext, [UIColor whiteColor].CGColor);
        CGContextFillRect(ctx, CGRectMake(58, base_height + row_number3 * 44, 137, 44 * number_of_lines - 2));
        CGContextFillRect(ctx, CGRectMake(197, base_height + row_number3 * 44, 276, 44 * number_of_lines - 2));
        CGContextFillRect(ctx, CGRectMake(881, base_height + row_number3 * 44, 325, 44 * number_of_lines - 2));
        int existing_rows = 0;
        for (int j = 0; j < [dictArray count]; j++) {
            int rows_needed = [[rows_needed_for_serial objectAtIndex:j] integerValue];
            if (rows_needed > 1) {
                CGContextFillRect(ctx, CGRectMake(475, base_height + row_number3 * 44 + existing_rows * 44, 404, 44 * rows_needed - 2));
            }
            existing_rows += rows_needed;
        }
        CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
        // draw room number
        [[PDF_room objectAtIndex:i] drawInRect:CGRectMake(68, base_height+10 + row_number3 * 44, 128, 100000) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
        // draw status installer        
        [[PDF_status_installer objectAtIndex:i] drawInRect:CGRectMake(208, base_height+10 + row_number3 * 44, 265, 100000) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
        // draw serial
        for (int j = 0; j < [dictArray count]; j++) {
            NSMutableDictionary *dict = [dictArray objectAtIndex:j];
            NSString *type_and_serial = [NSString stringWithFormat:@"%@: %@", [dict objectForKey:@"type"], [dict objectForKey:@"serial"]];                       
            [type_and_serial drawInRect:CGRectMake(485, base_height+10 + row_number2 * 44, 394, 100000) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
            row_number2 += [[rows_needed_for_serial objectAtIndex:j] integerValue];
        }
        row_number2 = row_number;
        //draw comments
        NSString *comments = [self conciseText:[PDF_comments objectAtIndex:i]];
        [comments drawInRect:CGRectMake(891, base_height+10 + row_number3 * 44, 317, 100000) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
        row_number3 = row_number;
    }
    float base_height;
    if (page == 0) {
        base_height = 882;
    }
    else {
        base_height = 234;
    }
    int pic_base_hight = base_height + (row_number) * 44 + 26; //26 is the padding between last line of the data form and picture title
    
    for (int i = 0; i < [PDF_room count]; i++) {
     
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
        
        //create picture hight array
        NSMutableArray *heightArray = [NSMutableArray array];
        NSMutableArray *updated_url = [NSMutableArray array];
        
        for (int imageIndex = 0; imageIndex < [urls count]; imageIndex++) {
            UIImage *myImage = [self loadImage: [urls objectAtIndex:imageIndex] ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
            
            if (myImage != nil) {
                [heightArray addObject: [NSNumber numberWithFloat: (myImage.size.height > myImage.size.width)? 552 : 414]];
                [updated_url addObject:[urls objectAtIndex:imageIndex]];
            }
        }
        if ([heightArray count] != 0) {
            //if there is at least one picture, draw room number
            float first_two_page_height = [[heightArray objectAtIndex:0] floatValue];
            if ([heightArray count] > 1) {
                if ([[heightArray objectAtIndex:1] floatValue] > first_two_page_height) {
                    first_two_page_height = [[heightArray objectAtIndex:1] floatValue];
                }
            }
            if ((pic_base_hight + 26 + 21 + 26 + first_two_page_height) > 1624 ){
                
                //if first two pics plus room number are off the edge, create a new page
                UIGraphicsPopContext();
                CGPDFContextEndPage(pdfContext);
                
                CGPDFContextBeginPage(pdfContext, NULL);
                UIGraphicsPushContext(pdfContext);
                
                // Flip coordinate system
                CGRect bounds = CGContextGetClipBoundingBox(pdfContext);
                CGContextScaleCTM(pdfContext, 1.0, -1.0);
                CGContextTranslateCTM(pdfContext, 0.0, -bounds.size.height);
                
                // Drawing backgrounds
                NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"installation-reports-4" ofType:@"jpg"];
                NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
                UIImage * logo = [UIImage imageWithData:imageData];
                [logo drawInRect:CGRectMake(0, 0, 1275, 1650)];
                pic_base_hight = 163;
            }
            // draw room
            font = [UIFont fontWithName:boldFont size:22.0f];
            [[NSString stringWithFormat:@"%@:", [PDF_room objectAtIndex:i]] drawInRect:CGRectMake(56, pic_base_hight + 26, 1151, 100000) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
            font = [UIFont fontWithName:normalFont size:21.0f];
            pic_base_hight += 26 + 21;
            //loop through all the photos
            for (int imageIndex = 0; imageIndex < [updated_url count]; imageIndex += 2) {
                float image_height = [[heightArray objectAtIndex:imageIndex] floatValue];
                if ((imageIndex+1) < [updated_url count]) {
                    if (image_height < [[heightArray objectAtIndex:(imageIndex+1)] floatValue]) {
                        image_height = [[heightArray objectAtIndex:(imageIndex+1)] floatValue];
                    }
                }
                if ((pic_base_hight + 26 + image_height) > 1624) {
                    
                    //if the upcoming two photos are off the edge, create a new page
                    UIGraphicsPopContext();
                    CGPDFContextEndPage(pdfContext);
                    
                    CGPDFContextBeginPage(pdfContext, NULL);
                    UIGraphicsPushContext(pdfContext);
                    
                    // Flip coordinate system
                    CGRect bounds = CGContextGetClipBoundingBox(pdfContext);
                    CGContextScaleCTM(pdfContext, 1.0, -1.0);
                    CGContextTranslateCTM(pdfContext, 0.0, -bounds.size.height);
                    
                    // Drawing backgrounds
                    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"installation-reports-4" ofType:@"jpg"];
                    NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
                    UIImage * logo = [UIImage imageWithData:imageData];
                    [logo drawInRect:CGRectMake(0, 0, 1275, 1650)];
                    pic_base_hight = 163;
                }
                
                //draw the photos on canvas
                for (int offset = 0; offset < 2; offset++) {
                    if ((imageIndex+offset) == [updated_url count]) {
                        break;
                    }
                    UIImage *myImage = [self loadImage: [updated_url objectAtIndex:(imageIndex+offset)] ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
                    CGRect tempRect;
                    float tempHeight = myImage.size.height;
                    float tempWidth = myImage.size.width;
                    if (tempHeight > tempWidth) {
                        if ((imageIndex+offset) % 2 == 0) {
                            tempRect = CGRectMake(56, pic_base_hight + 26, 414, 552);
                        }
                        else {
                            tempRect = CGRectMake(655, pic_base_hight + 26, 414, 552);
                        }
                    }
                    else {
                        if ((imageIndex+offset) % 2 == 0) {
                            tempRect = CGRectMake(56, pic_base_hight + 26, 552, 414);
                        }
                        else {
                            tempRect = CGRectMake(655, pic_base_hight + 26, 552, 414);
                        }
                    }
                    
                    NSData *imageData = UIImageJPEGRepresentation(myImage, 0.75);
                    myImage = [UIImage imageWithData:imageData];
                    [myImage drawInRect:tempRect];
                    myImage = nil;
                }
                
                pic_base_hight += 26 + image_height;
            }
        }
        
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

- (float)drawText: (NSString *) string withX: (CGFloat) x withY: (CGFloat) y andWidth: (CGFloat) width andFont: (UIFont *)font andFontSize: (CGFloat) fontsize {
    
    float serial_height = [self textAreaHight: string withRect:CGRectMake(0, 0, width, 100000) andFont:font];
    if (serial_height > 88) {
        font = [UIFont fontWithName:normalFont size:15.0f];
        float real_height = [self textAreaHight: string withRect:CGRectMake(0, 0, width, 100000) andFont:font];
        [string drawInRect:CGRectMake(x, y - 3, width, 100000) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
        return real_height;
    }
    else if (serial_height > 44) {
        font = [UIFont fontWithName:normalFont size:18.0f];
        float real_height = [self textAreaHight: string withRect:CGRectMake(0, 0, width, 100000) andFont:font];
        if (real_height > 44) {
            [string drawInRect:CGRectMake(x, y - 7, width, 100000) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
        }
        else {
            [string drawInRect:CGRectMake(x, y, width, 100000) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
        }
        return real_height;
    }
    else {
        [string drawInRect:CGRectMake(x, y, width, 100000) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
        return serial_height;
    }
    if (serial_height > 44) {
        font = [UIFont fontWithName:normalFont size:fontsize];
    }
    
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

- (int)findNumberOfLines: (float)height withLineHeight: (int)lineHeight {
    int int_height = (int) ceilf(height);
    int number_of_lines;
    if (int_height % lineHeight == 0) {
        number_of_lines = int_height / lineHeight;
    }
    else {
        number_of_lines = int_height / lineHeight + 1;
    }
    return number_of_lines;
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    return result;
}

@end
