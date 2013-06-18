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
    smartboard = [NSMutableArray array];
    smartboard_other = [NSMutableArray array];
    projector = [NSMutableArray array];
    projector_type = [NSMutableArray array];
    projector_notes = [NSMutableArray array];
    mounting = [NSMutableArray array];
    mounting_notes = [NSMutableArray array];
    CMP_mounting = [NSMutableArray array];
    CMP_mouting_notes = [NSMutableArray array];
    
    audios = [NSMutableArray array];
    audio_notes = [NSMutableArray array];
    audio_ceilingSpeakers = [NSMutableArray array];
    audio_wallMountedSpeakers = [NSMutableArray array];
    audio_includeReceiver = [NSMutableArray array];
    audio_ceiling_sensor = [NSMutableArray array];
    audio_wall_sensor = [NSMutableArray array];
    
    cable_type = [NSMutableArray array];
    cable_type_notes = [NSMutableArray array];
    peripherals = [NSMutableArray array];
    peripherals_others = [NSMutableArray array];
    
    client_agrees_to_remove = [NSMutableArray array];
    client_agrees_to_remove_other = [NSMutableArray array];
    client_will_provide_power = [NSMutableArray array];
    client_will_provide_power_notes = [NSMutableArray array];
    power_within_three_feet = [NSMutableArray array];
    
    general_notes = [NSMutableArray array];
    diagram_file_directory = [NSMutableArray array];
    
    Cables_other = [NSMutableArray array];
    
    /*** Group 2 ***/
    Projection_availability = [NSMutableArray array];
    New_projection_type = [NSMutableArray array];
    Existing_projection_type = [NSMutableArray array];
    No_projection_type = [NSMutableArray array];
    Existing_board_notes = [NSMutableArray array];
    Existing_projector_notes = [NSMutableArray array];
    Projectors_include_mounts = [NSMutableArray array];
    Existing_cmp_notes = [NSMutableArray array];
    Existing_projector_serial = [NSMutableArray array];
    Existing_CMP_throw_distance = [NSMutableArray array];
    Existing_CMP_remount = [NSMutableArray array];
    Cmp_mounting_location = [NSMutableArray array];
    Cmp_poleLength = [NSMutableArray array];
    Cmp_poleLength_notes = [NSMutableArray array];
    Cable_ports = [NSMutableArray array];
    Height_of_smartboard = [NSMutableArray array];
    Height_of_smartboard_notes = [NSMutableArray array];
    Height_of_smartboard_classroom_type = [NSMutableArray array];
    Ceiling_height = [NSMutableArray array];
    Ceiling_structure = [NSMutableArray array];
    Ceiling_structure_other = [NSMutableArray array];
    Wall_structure = [NSMutableArray array];
    Wall_structure_notes = [NSMutableArray array];
    Wall_structure_board = [NSMutableArray array];
    Wall_structure_board_notes = [NSMutableArray array];
    Photo_file_directory_1 = [NSMutableArray array];
    Photo_file_directory_2 = [NSMutableArray array];
    Photo_file_directory_3 = [NSMutableArray array];
    Photo_file_directory_4 = [NSMutableArray array];
    Photo_file_directory_5 = [NSMutableArray array];
    Photo_file_directory_6 = [NSMutableArray array];
    Photo_file_directory_7 = [NSMutableArray array];
    Photo_file_directory_8 = [NSMutableArray array];
    Raceway_part_1 = [NSMutableArray array];
    Raceway_part_2 = [NSMutableArray array];
    Raceway_part_3 = [NSMutableArray array];
    Raceway_part_4 = [NSMutableArray array];
    Raceway_part_5 = [NSMutableArray array];
    Raceway_part_6 = [NSMutableArray array];
    Raceway_part_7 = [NSMutableArray array];
    Raceway_part_8 = [NSMutableArray array];
    Raceway_part_9 = [NSMutableArray array];
    Raceway_part_10 = [NSMutableArray array];
    
    //Group 3;
    Speaker = [NSMutableArray array];
    Audio_package = [NSMutableArray array];
    Audio_accessories = [NSMutableArray array];
    Internal_notes = [NSMutableArray array];
    Port_desc = [NSMutableArray array];
    Nyc_cable_bundle = [NSMutableArray array];
    Existing_board_other = [NSMutableArray array];
    Custom_build_rail = [NSMutableArray array];
    CMP_mounting_other = [NSMutableArray array];
    Mounting_location = [NSMutableArray array];
    
    Flat_panel = [NSMutableArray array];
    Flat_panel_other = [NSMutableArray array];
    Cork_penetrated = [NSMutableArray array];
    Audio_accessories_other = [NSMutableArray array];
    Wall_number = [NSMutableArray array];
    
    sqlite3 *db;
    sqlite3_stmt    *statement;
    
    @try {
        
        const char *dbpath = [database.dbpathString UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {            
            
            NSString *selectSQL = [NSString stringWithFormat:@"select [Room_Number], [Room_Floor_Number], [Classroom_grade], [Room_Notes], [Smartboard] ,[Smartboard_other], [Projector] ,[Projection_type], [Projector_notes] ,[Mounting] ,[Mounting_notes], [Cmp_mounting], [CMP_mouting_notes], [Audio], [Audio_notes], [Audio_ceilingSpeakers] ,[Audio_wallMountedSpeakers] ,[Audio_includeReceiver] , [Audio_ceiling_sensor], [Audio_wall_sensor], [Cable_type],[Cable_type_notes], [Peripherals] ,[Peripherals_others], [Existing_board_removal], [Other_removal], [Power_provided], [Power_provided_notes], [Power_within_three_feet], [General_notes], [Diagram_file_directory], [Cables_other], [Projection_availability], [New_projection_type], [Existing_projection_type], [No_projection_type], [Existing_board_notes], [Existing_projector_notes], [Projectors_include_mounts], [Existing_cmp_notes], [Existing_projector_serial], [Existing_CMP_throw_distance], [Existing_CMP_remount], [Cmp_mounting_location], [Cmp_poleLength], [Cmp_poleLength_notes], [Cable_ports], [Height_of_smartboard], [Height_of_smartboard_notes], [Height_of_smartboard_classroom_type], [Ceiling_height], [Ceiling_structure], [Ceiling_structure_other], [Wall_structure], [Wall_structure_notes], [Wall_structure_board], [Wall_structure_board_notes], [Photo_file_directory_1], [Photo_file_directory_2], [Photo_file_directory_3], [Photo_file_directory_4], [Photo_file_directory_5], [Photo_file_directory_6], [Photo_file_directory_7], [Photo_file_directory_8], [Raceway_part_1], [Raceway_part_2], [Raceway_part_3], [Raceway_part_4], [Raceway_part_5], [Raceway_part_6], [Raceway_part_7], [Raceway_part_8], [Raceway_part_9], [Raceway_part_10], [Speaker], [Audio_package], [Audio_accessories], [Internal_notes], [Port_desc], [Nyc_cable_bundle], [Existing_board_other], [Custom_build_rail], [CMP_mounting_other], [Equipment_location_notes], [Flat_panel], [Cork_penetrated], [Audio_accessories_other], [Flat_panel_other], [Wall_number] from local_dest where [Activity_no] = '%@' and [Teq_rep] like '%%%@%%' order by CASE WHEN cast(Room_Number as int) = 0 THEN 9999999999 ELSE cast(Room_Number as int) END, Room_Number;", database.current_activity_no, database.current_teq_rep];
            
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
                    [smartboard addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [smartboard_other addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [projector addObject:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [projector_type addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [projector_notes addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [mounting addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [mounting_notes addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [CMP_mounting addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [CMP_mouting_notes addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [audios addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    
                    [audio_notes addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [audio_ceilingSpeakers addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [audio_wallMountedSpeakers addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [audio_includeReceiver addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [audio_ceiling_sensor addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [audio_wall_sensor  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [cable_type  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [cable_type_notes  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    
                    [peripherals  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [peripherals_others  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    
                    [client_agrees_to_remove  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [client_agrees_to_remove_other  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    
                    [client_will_provide_power  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [client_will_provide_power_notes  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    
                    [power_within_three_feet  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    
                    [general_notes  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [diagram_file_directory  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    
                    [Cables_other  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    
                    /*** group 2 ***/
                    [Projection_availability  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [New_projection_type  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Existing_projection_type  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [No_projection_type  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Existing_board_notes  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Existing_projector_notes  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Projectors_include_mounts  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Existing_cmp_notes  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Existing_projector_serial  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Existing_CMP_throw_distance  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Existing_CMP_remount  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];                    
                    [Cmp_mounting_location  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];                    
                    [Cmp_poleLength  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Cmp_poleLength_notes  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Cable_ports  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Height_of_smartboard  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Height_of_smartboard_notes  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Height_of_smartboard_classroom_type  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Ceiling_height  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Ceiling_structure  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Ceiling_structure_other  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Wall_structure  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Wall_structure_notes  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Wall_structure_board  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Wall_structure_board_notes  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_1  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_2  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_3  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_4  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_5  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_6  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_7  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Photo_file_directory_8  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Raceway_part_1  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Raceway_part_2  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Raceway_part_3  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Raceway_part_4  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Raceway_part_5  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Raceway_part_6  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Raceway_part_7  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Raceway_part_8  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Raceway_part_9  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Raceway_part_10  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Speaker  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Audio_package  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Audio_accessories addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Internal_notes addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Port_desc  addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Nyc_cable_bundle addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Existing_board_other addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Custom_build_rail addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [CMP_mounting_other addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Mounting_location addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    
                    [Flat_panel addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Cork_penetrated addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Audio_accessories_other addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Flat_panel_other addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
                    [Wall_number addObject: [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, i++)]];
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
    PDF_projection = [NSMutableArray array];
    for (int i = 0; i < [Projection_availability count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Projection_availability objectAtIndex:i]];
        if ([[New_projection_type objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [New_projection_type objectAtIndex:i]];
        }
        if ([[Existing_projection_type objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [Existing_projection_type objectAtIndex:i]];
        }
        if ([[No_projection_type objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [No_projection_type objectAtIndex:i]];
        }
        if ([[projector_type objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [projector_type objectAtIndex:i]];
        }
        if ([[projector objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [projector objectAtIndex:i]];
        }
        if ([[projector_notes objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [projector_notes objectAtIndex:i]];
        }
        [PDF_projection addObject:string];
    }
    
    PDF_board = [NSMutableArray array];
    for (int i = 0; i < [smartboard count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [smartboard objectAtIndex:i]];
        if ([[smartboard_other objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [smartboard_other objectAtIndex:i]];
        }
        [PDF_board addObject:string];
    }
    
    PDF_mounting = [NSMutableArray array];
    for (int i = 0; i < [mounting count]; i++) {
        
        NSMutableString *stringData = [NSMutableString stringWithFormat:@"%@", [mounting objectAtIndex:i]];
        NSData *data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e = nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSMutableString *string = [NSMutableString string];
        for (id key in dict) {
            if ([string length] > 0) {
                [string appendString:@", "];
            }
            if ([[dict objectForKey:key] isEqualToString:@"Existing"])
            {
                [string appendString:@"(existing) "];
            }
            [string appendString:key];
        }
        if ([[Custom_build_rail objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [Custom_build_rail objectAtIndex:i]];
        }
        if ([[mounting_notes objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [mounting_notes objectAtIndex:i]];
        }
        [PDF_mounting addObject:string];
    }
    
    PDF_projector_mounting = [NSMutableArray array];
    for (int i = 0; i < [Cmp_mounting_location count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Cmp_mounting_location objectAtIndex:i]];
        if ([[CMP_mounting objectAtIndex:i] length] > 0) {
            NSMutableString *stringData = [NSMutableString stringWithFormat:@"%@", [CMP_mounting objectAtIndex:i]];
            NSData *data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
            NSError *e = nil;
            NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];            
            for (id key in dict) {
                [string appendString:@", "];
                if ([[dict objectForKey:key] isEqualToString:@"Existing"])
                {
                    [string appendString:@"(existing) "];
                }
                [string appendString:key];                
            }
        }
        if ([[CMP_mouting_notes objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [CMP_mouting_notes objectAtIndex:i]];
        }
        if ([[CMP_mounting_other objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [CMP_mounting_other objectAtIndex:i]];
        }
        [PDF_projector_mounting addObject:string];
    }
        
    /*
    PDF_ceiling_speakers = [NSMutableArray array];
    for (int i = 0; i < [audio_ceilingSpeakers count]; i++) {
        [PDF_ceiling_speakers addObject:[audio_ceilingSpeakers objectAtIndex:i]];
    }
    
    PDF_wall_speakers = [NSMutableArray array];
    for (int i = 0; i < [audio_wallMountedSpeakers count]; i++) {
        [PDF_wall_speakers addObject:[audio_wallMountedSpeakers objectAtIndex:i]];
    }
    
    PDF_mounting_bracket = [NSMutableArray array];
    for (int i = 0; i < [audio_includeReceiver count]; i++) {
        [PDF_mounting_bracket addObject:[audio_includeReceiver objectAtIndex:i]];
    }
    
    PDF_ceiling_sensors = [NSMutableArray array];
    for (int i = 0; i < [audio_ceiling_sensor count]; i++) {
        [PDF_ceiling_sensors addObject:[audio_ceiling_sensor objectAtIndex:i]];
    }
    
    PDF_wall_sensors = [NSMutableArray array];
    for (int i = 0; i < [audio_wall_sensor count]; i++) {
        [PDF_wall_sensors addObject:[audio_wall_sensor objectAtIndex:i]];
    }
     */
    
    PDF_device_plate = [NSMutableArray array];
    for (int i = 0; i < [cable_type count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [cable_type objectAtIndex:i]];
        if ([[Cable_ports objectAtIndex:i] length] > 0 && ![string isEqual:@"NYC Cable Bundle"]) {
            [string appendFormat:@", %@", [Cable_ports objectAtIndex:i]];
        }
        if ([[Nyc_cable_bundle objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [Nyc_cable_bundle objectAtIndex:i]];
        }
        [PDF_device_plate addObject:string];
    }
    
    PDF_peripherals = [NSMutableArray array];
    for (int i = 0; i < [peripherals count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [peripherals objectAtIndex:i]];
        if ([[peripherals_others objectAtIndex:i] length] > 0) {
            if ([string length] > 0) {
                [string appendFormat:@", %@", [peripherals_others objectAtIndex:i]];
            }
            else {
                [string appendFormat:@"%@", [peripherals_others objectAtIndex:i]];
            }
        }
        [PDF_peripherals addObject:string];
    }
    
    PDF_client_remove = [NSMutableArray array];
    for (int i = 0; i < [client_agrees_to_remove count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [client_agrees_to_remove objectAtIndex:i]];
        if ([[client_agrees_to_remove_other objectAtIndex:i] length] > 0) {
            if ([string length] > 0) {
                [string appendFormat:@", %@", [client_agrees_to_remove_other objectAtIndex:i]];
            }
            else {
                [string appendFormat:@"%@", [client_agrees_to_remove_other objectAtIndex:i]];
            }
        }
        [PDF_client_remove addObject:string];
    }
    
    PDF_client_provide_power = [NSMutableArray array];
    for (int i = 0; i < [client_will_provide_power count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [client_will_provide_power objectAtIndex:i]];
        if ([[client_will_provide_power_notes objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [client_will_provide_power_notes objectAtIndex:i]];
        }
        [PDF_client_provide_power addObject:string];
    }
    
    PDF_power_within_three_feet = [NSMutableArray array];
    for (int i = 0; i < [power_within_three_feet count]; i++) {
        [PDF_power_within_three_feet addObject:[power_within_three_feet objectAtIndex:i]];
    }
    
    PDF_comments = [NSMutableArray array];
    for (int i = 0; i < [general_notes count]; i++) {
        [PDF_comments addObject:[general_notes objectAtIndex:i]];
    }
    
    PDF_drawing = [NSMutableArray array];
    for (int i = 0; i < [diagram_file_directory count]; i++) {
        [PDF_drawing addObject:[diagram_file_directory objectAtIndex:i]];
    }
    
    /*** Group 2 ***/
    PDF_existing_board = [NSMutableArray array];
    for (int i = 0; i < [Existing_board_notes count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Existing_board_notes objectAtIndex:i]];
        if ([[Existing_board_other objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [Existing_board_other objectAtIndex:i]];
        }
        [PDF_existing_board addObject:string];
    }
    
    PDF_existing_projector = [NSMutableArray array];
    for (int i = 0; i < [Existing_projector_notes count]; i++) {
        
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Existing_projector_notes objectAtIndex:i]];
        /*
        if ([[Projectors_include_mounts objectAtIndex:i] length] > 0) {
            if ([[Projectors_include_mounts objectAtIndex:i] isEqualToString:@"Yes"]) {
                [string appendFormat:@" All projectors include mounts"];
            }            
        }
         */
        [PDF_existing_projector addObject:string];
    }
    
    PDF_existing_cmp_model = [NSMutableArray array];
    for (int i = 0; i < [Existing_cmp_notes count]; i++) {
        [PDF_existing_cmp_model addObject:[Existing_cmp_notes objectAtIndex:i]];
    }
    PDF_existing_projector_serial = [NSMutableArray array];
    for (int i = 0; i < [Existing_projector_serial count]; i++) {
        [PDF_existing_projector_serial addObject:[Existing_projector_serial objectAtIndex:i]];
    }
    PDF_existing_cmp_throw_distance = [NSMutableArray array];
    for (int i = 0; i < [Existing_CMP_throw_distance count]; i++) {
        [PDF_existing_cmp_throw_distance addObject:[Existing_CMP_throw_distance objectAtIndex:i]];
    }
    PDF_existing_cmp_remount = [NSMutableArray array];
    for (int i = 0; i < [Existing_CMP_remount count]; i++) {
        [PDF_existing_cmp_remount addObject:[Existing_CMP_remount objectAtIndex:i]];
    }        
    PDF_cmp_polelength = [NSMutableArray array];
    for (int i = 0; i < [Cmp_poleLength count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Cmp_poleLength objectAtIndex:i]];
        if ([[Cmp_poleLength_notes objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [Cmp_poleLength_notes objectAtIndex:i]];
        }
        [PDF_cmp_polelength addObject:string];
    }
    PDF_ports = [NSMutableArray array];
    for (int i = 0; i < [Cable_ports count]; i++) {
        //[PDF_ports addObject:[Cable_ports objectAtIndex:i]];
        [PDF_ports addObject:@""];
    }
    PDF_height_of_smartboard = [NSMutableArray array];
    for (int i = 0; i < [Height_of_smartboard count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Height_of_smartboard objectAtIndex:i]];
        NSArray *array = [string componentsSeparatedByString:@","];
        if ([array count] > 1) {
            string = [NSMutableString stringWithFormat:@"Pen tray: %@\',  Top: %@\'", [array objectAtIndex:0], [array objectAtIndex:1]];
        }
        else {
            string = [NSMutableString stringWithFormat:@"%@", [array objectAtIndex:0]];
        }
        if ([[Height_of_smartboard_notes objectAtIndex:i] length] > 0) {
            [string appendFormat:@", Pen tray: %@'", [Height_of_smartboard_notes objectAtIndex:i]];
        }
        [PDF_height_of_smartboard addObject:string];
    }
    PDF_height_of_smartboard_classroom_type = [NSMutableArray array];
    for (int i = 0; i < [Height_of_smartboard_classroom_type count]; i++) {
        [PDF_height_of_smartboard_classroom_type addObject:[Height_of_smartboard_classroom_type objectAtIndex:i]];
    }
    PDF_ceiling_height = [NSMutableArray array];
    for (int i = 0; i < [Ceiling_height count]; i++) {
        [PDF_ceiling_height addObject:[Ceiling_height objectAtIndex:i]];
    }
    PDF_ceiling_structure = [NSMutableArray array];
    for (int i = 0; i < [Ceiling_structure count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Ceiling_structure objectAtIndex:i]];
        if ([[Ceiling_structure_other objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [Ceiling_structure_other objectAtIndex:i]];
        }
        [PDF_ceiling_structure addObject:string];
    }
    PDF_wall_structure = [NSMutableArray array];
    for (int i = 0; i < [Wall_structure count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Wall_structure objectAtIndex:i]];
        if ([[Wall_structure_notes objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [Wall_structure_notes objectAtIndex:i]];
        }
        [PDF_wall_structure addObject:string];
    }
    PDF_wall_structure_board = [NSMutableArray array];
    for (int i = 0; i < [Wall_structure_board count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Wall_structure_board objectAtIndex:i]];
        if ([[Wall_structure_board_notes objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [Wall_structure_board_notes objectAtIndex:i]];
        }
        [PDF_wall_structure_board addObject:string];
    }
    PDF_photo_file_directory_1 = [NSMutableArray array];
    for (int i = 0; i < [Photo_file_directory_1 count]; i++) {
        [PDF_photo_file_directory_1 addObject:[Photo_file_directory_1 objectAtIndex:i]];
    }
    PDF_photo_file_directory_2 = [NSMutableArray array];
    for (int i = 0; i < [Photo_file_directory_2 count]; i++) {
        [PDF_photo_file_directory_2 addObject:[Photo_file_directory_2 objectAtIndex:i]];
    }
    PDF_photo_file_directory_3 = [NSMutableArray array];
    for (int i = 0; i < [Photo_file_directory_3 count]; i++) {
        [PDF_photo_file_directory_3 addObject:[Photo_file_directory_3 objectAtIndex:i]];
    }
    PDF_photo_file_directory_4 = [NSMutableArray array];
    for (int i = 0; i < [Photo_file_directory_4 count]; i++) {
        [PDF_photo_file_directory_4 addObject:[Photo_file_directory_4 objectAtIndex:i]];
    }
    PDF_photo_file_directory_5 = [NSMutableArray array];
    for (int i = 0; i < [Photo_file_directory_5 count]; i++) {
        [PDF_photo_file_directory_5 addObject:[Photo_file_directory_5 objectAtIndex:i]];
    }
    PDF_photo_file_directory_6 = [NSMutableArray array];
    for (int i = 0; i < [Photo_file_directory_6 count]; i++) {
        [PDF_photo_file_directory_6 addObject:[Photo_file_directory_6 objectAtIndex:i]];
    }
    PDF_photo_file_directory_7 = [NSMutableArray array];
    for (int i = 0; i < [Photo_file_directory_7 count]; i++) {
        [PDF_photo_file_directory_7 addObject:[Photo_file_directory_7 objectAtIndex:i]];
    }
    PDF_photo_file_directory_8 = [NSMutableArray array];
    for (int i = 0; i < [Photo_file_directory_8 count]; i++) {
        [PDF_photo_file_directory_8 addObject:[Photo_file_directory_8 objectAtIndex:i]];
    }
            
    PDF_Raceway_parts = [NSMutableArray array];
    for (int i = 0; i < [Raceway_part_1 count]; i++) {
        NSString *string = @"";
        if ([[Raceway_part_1 objectAtIndex:i] length] > 0) {
            string = [NSString stringWithFormat:@"Total feet required: %@\'", [Raceway_part_1 objectAtIndex:i]];
        }
        [PDF_Raceway_parts addObject:string];
    }
    
    //group 3
    
    PDF_room_number = [NSMutableString string];
    [PDF_room_number appendString:@"Installation Room Location(s):   "];
    for (int i = 0; i < [classroom_number count]; i++) {
        NSMutableString *string;
        if (i < [classroom_number count] - 1) {
            string = [NSMutableString stringWithFormat:@"%@, ", [classroom_number objectAtIndex:i]];
        }else {
            string = [NSMutableString stringWithFormat:@"%@", [classroom_number objectAtIndex:i]];
        }
        [PDF_room_number appendString:string];
    }
    
    PDF_port_desc= [NSMutableArray array];
    for (int i = 0; i < [Port_desc count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Port_desc objectAtIndex:i]];
        if ([[cable_type_notes objectAtIndex:i] length] > 0) {
            if ([string length]>0) {
                [string appendFormat:@", %@", [cable_type_notes objectAtIndex:i]];                
            }
            else {
                [string appendFormat:@"%@", [cable_type_notes objectAtIndex:i]];
                //if nyc_cable_bundle is chosen, port_desc is nil
            }
        }
        [PDF_port_desc addObject:string];
    }
    
    PDF_speaker = [NSMutableArray array];
    for (int i = 0; i < [Speaker count]; i++) {
        NSMutableString *stringData = [NSMutableString stringWithFormat:@"%@", [Speaker objectAtIndex:i]];
        NSData *data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e = nil;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSMutableString *string = [NSMutableString string];
        for (id key in dict) {
            if ([[dict objectForKey:key] isEqualToString:@"Existing"])
            {
                [string appendString:@"(existing) "];
            }
            [string appendString:key];
            [string appendString:@", "];
        }
        if ([string length] > 0) {
            string = [NSMutableString stringWithFormat:@"%@", [string substringToIndex:(string.length - 2)]];            
        }
        
        if ([[audio_notes objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [audio_notes objectAtIndex:i]];
        }
        [PDF_speaker addObject:string];
    }
    PDF_audio = [NSMutableArray array];
    for (int i = 0; i < [audios count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [audios objectAtIndex:i]];
        if ([[Audio_package objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [Audio_package objectAtIndex:i]];
        }
        [PDF_audio addObject:string];
    }
    PDF_audio_accessories = [NSMutableArray array];
    for (int i = 0; i < [Audio_accessories count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Audio_accessories objectAtIndex:i]];
        if ([[Audio_accessories_other objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [Audio_accessories_other objectAtIndex:i]];
        }
        [PDF_audio_accessories addObject:string];
    }
    PDF_internal_notes = [NSMutableArray array];
    for (int i = 0; i < [Internal_notes count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Internal_notes objectAtIndex:i]];
        
        [PDF_internal_notes addObject:string];
    }
    PDF_mounting_location = [NSMutableArray array];
    for (int i = 0; i < [Mounting_location count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Mounting_location objectAtIndex:i]];
        
        [PDF_mounting_location addObject:string];
    }
    PDF_flat_panel = [NSMutableArray array];
    for (int i = 0; i < [Flat_panel count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Flat_panel objectAtIndex:i]];
        if ([[Flat_panel_other objectAtIndex:i] length] > 0) {
            [string appendFormat:@", %@", [Flat_panel_other objectAtIndex:i]];
        }
        [PDF_flat_panel addObject:string];
    }
    PDF_cork_penetrated = [NSMutableArray array];
    for (int i = 0; i < [Cork_penetrated count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Cork_penetrated objectAtIndex:i]];
        
        [PDF_cork_penetrated addObject:string];
    }
    PDF_wall_number = [NSMutableArray array];
    for (int i = 0; i < [Wall_number count]; i++) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%@", [Wall_number objectAtIndex:i]];
        
        [PDF_wall_number addObject:string];
    }
    /*
    for (int i = 0; i < [Raceway_parts count]; i++) {
        NSString *stringData = [Raceway_parts objectAtIndex:i];
        NSData *data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        
        NSMutableString *raceway = [NSMutableString string];
        NSEnumerator *enumerator = [jsonDict keyEnumerator];
        NSString *key;
        while ((key = [enumerator nextObject])) {
            NSString *tmp = [jsonDict objectForKey:key];
            if (![tmp isEqualToString:@"None"]) {
                [raceway appendFormat:@"%@ pieces of %@;    ", tmp, key];
            }
        }
        [PDF_Raceway_parts addObject:raceway];
    }
    */
    
    /*
    isql *database = [isql initialize];
    [database loadRacewayData];
    for (int i = 0; i < [Raceway_part_1 count]; i++) {
        NSMutableString *tempString = [NSMutableString string];
        
        int j = 0;
        if (![[Raceway_part_1 objectAtIndex:i] isEqualToString:@"None"]) {
            [tempString appendFormat:@"%@ pieces of %@;    ", [Raceway_part_1 objectAtIndex:i], [database.raceway_parts_description objectAtIndex:j]];
        }
        j++;
        if (![[Raceway_part_2 objectAtIndex:i] isEqualToString:@"None"]) {
            [tempString appendFormat:@"%@ pieces of %@;    ", [Raceway_part_2 objectAtIndex:i], [database.raceway_parts_description objectAtIndex:j]];
        }
        j++;
        if (![[Raceway_part_3 objectAtIndex:i] isEqualToString:@"None"]) {
            [tempString appendFormat:@"%@ pieces of %@;    ", [Raceway_part_3 objectAtIndex:i], [database.raceway_parts_description objectAtIndex:j]];
        }
        j++;
        if (![[Raceway_part_4 objectAtIndex:i] isEqualToString:@"None"]) {
            [tempString appendFormat:@"%@ pieces of %@;    ", [Raceway_part_4 objectAtIndex:i], [database.raceway_parts_description objectAtIndex:j]];
        }
        j++;
        if (![[Raceway_part_5 objectAtIndex:i] isEqualToString:@"None"]) {
            [tempString appendFormat:@"%@ pieces of %@;    ", [Raceway_part_5 objectAtIndex:i], [database.raceway_parts_description objectAtIndex:j]];
        }
        j++;
        if (![[Raceway_part_6 objectAtIndex:i] isEqualToString:@"None"]) {
            [tempString appendFormat:@"%@ pieces of %@;    ", [Raceway_part_6 objectAtIndex:i], [database.raceway_parts_description objectAtIndex:j]];
        }
        j++;
        if (![[Raceway_part_7 objectAtIndex:i] isEqualToString:@"None"]) {
            [tempString appendFormat:@"%@ pieces of %@;    ", [Raceway_part_7 objectAtIndex:i], [database.raceway_parts_description objectAtIndex:j]];
        }
        j++;
        if (![[Raceway_part_8 objectAtIndex:i] isEqualToString:@"None"]) {
            [tempString appendFormat:@"%@ pieces of %@;    ", [Raceway_part_8 objectAtIndex:i], [database.raceway_parts_description objectAtIndex:j]];
        }
        j++;
        [PDF_Raceway_parts addObject:tempString];
    }
    */
    NSString* fileName = [self getPDFFileName];
    
    [self drawPDF:fileName];
}

-(NSString*)getPDFFileName
{
    isql *database = [isql initialize];
       // Convert string to date object
    //completereport
    NSString* fileName = [NSString stringWithFormat:@"SS-%@-%@.PDF", (database.current_activity_no  == nil)? @"": database.current_activity_no, (database.current_username == nil)? @"":[database.current_username capitalizedString]];
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
    const CGRect cgrect = {{0.0f, 0.0f},{2550.0f *factor,3300.0f *factor}};
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
        NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"site-survey-cover-page" ofType:@"jpg"];
        NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
        UIImage * logo = [UIImage imageWithData:imageData];
        
        //logo = [UIImage imageWithData:imageData];
        [logo drawInRect:CGRectMake(0, 0, 2550 *factor, 3300 *factor)];
        
        //draw first two green lines
        //CGContextSetFillColorWithColor(pdfContext, [UIColor colorWithRed:142.0/255.0 green:198.0/255.0 blue:63.0/255.0 alpha:1.0].CGColor);
        CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
        UIFont *font = [UIFont fontWithName:boldFont
     size:48.0f *factor];
        [[NSString stringWithFormat:@"%@, %@",database.current_location, database.current_date ] drawAtPoint:CGPointMake(468 *factor, 259 *factor) withFont: font];
        //[database.current_address drawAtPoint:CGPointMake(468 *factor, 332 *factor) withFont: font];
                        
        //draw white fonts for titles
        CGContextSetFillColorWithColor(pdfContext, [UIColor whiteColor].CGColor);
        font = [UIFont fontWithName:boldFont
     size:42.0f *factor];
        [@"Activity #" drawAtPoint:CGPointMake(170 *factor, 488 *factor) withFont: font];
        [@"Sales Quote #" drawAtPoint:CGPointMake(446 *factor, 488 *factor) withFont: font];
        [@"Sales Order #" drawAtPoint:CGPointMake(803 *factor, 488 *factor) withFont: font];
        [@"Job Name" drawAtPoint:CGPointMake(1123 *factor, 488 *factor) withFont: font];
        [@"Teq Representative" drawAtPoint:CGPointMake(1469 *factor, 488 *factor) withFont: font];
        [@"Date" drawAtPoint:CGPointMake(1928 *factor, 488 *factor) withFont: font];
        
        [@"Primary Contact" drawAtPoint:CGPointMake(170 *factor, 780 *factor) withFont: font];
        [@"Secondary Contact" drawAtPoint:CGPointMake(918 *factor, 780 *factor) withFont: font];
        [@"Custodial Contact" drawAtPoint:CGPointMake(1666 *factor, 780 *factor) withFont: font];
        
        [@"School Hours" drawAtPoint:CGPointMake(170 *factor, 1274 *factor) withFont: font];
        [@"Elevator Available" drawAtPoint:CGPointMake(918 *factor, 1274 *factor) withFont: font];
        [@"Loading Dock Available" drawAtPoint:CGPointMake(1666 *factor, 1274 *factor) withFont: font];
        
        //self explanatory
        CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
        [@"Purchasing Agent: " drawAtPoint:CGPointMake(132 *factor, 2110 *factor) withFont:font];
        font = [UIFont fontWithName:normalFont
     size:42.0f *factor];
        [database.current_activity_no drawAtPoint:CGPointMake(170 *factor, 565 *factor) withFont: font];
        //[database.current_sq drawAtPoint:CGPointMake(446 *factor, 565 *factor) withFont: font];
        [database.current_so drawAtPoint:CGPointMake(803 *factor, 565 *factor) withFont: font];
        //[database.current_job_name drawAtPoint:CGPointMake(1123 *factor, 565 *factor) withFont: font];
        [database.current_teq_rep drawAtPoint:CGPointMake(1469 *factor, 565 *factor) withFont: font];
        [database.current_date drawAtPoint:CGPointMake(1928 *factor, 565 *factor) withFont: font];
        //[database.current_purchasing_agent drawAtPoint:CGPointMake(490 *factor, 2110 *factor) withFont:font];
        
        [database.current_primary_contact drawAtPoint:CGPointMake(170 *factor, 857 *factor) withFont: font];
        //[database.current_second_contact drawAtPoint:CGPointMake(918 *factor, 857 *factor) withFont: font];
        //[database.current_engineer_contact drawAtPoint:CGPointMake(1666 *factor, 857 *factor) withFont: font];
        
        //[database.current_primary_contact_title drawAtPoint:CGPointMake(170 *factor, 923 *factor) withFont: font];
        //[database.current_second_contact_title drawAtPoint:CGPointMake(918 *factor, 923 *factor) withFont: font];
        //[database.current_engineer_contact_title drawAtPoint:CGPointMake(1666 *factor, 923 *factor) withFont: font];
        
        //[database.current_primary_contact_phone drawAtPoint:CGPointMake(170 *factor, 989 *factor) withFont: font];
        //[database.current_second_contact_phone drawAtPoint:CGPointMake(918 *factor, 989 *factor) withFont: font];
        //[database.current_engineer_contact_phone drawAtPoint:CGPointMake(1666 *factor, 989 *factor) withFont: font];
        
        //[database.current_primary_contact_email drawAtPoint:CGPointMake(170 *factor, 1055 *factor) withFont: font];
        //[database.current_second_contact_email drawAtPoint:CGPointMake(918 *factor, 1055 *factor) withFont: font];
        //[database.current_engineer_contact_email drawAtPoint:CGPointMake(1666 *factor, 1055 *factor) withFont: font];
        
        //[database.current_school_hours drawAtPoint:CGPointMake(170 *factor, 1350 *factor) withFont: font];
        //[database.current_elevator_available drawAtPoint:CGPointMake(918 *factor, 1350 *factor) withFont: font];
        //[database.current_loading_available drawAtPoint:CGPointMake(1666 *factor, 1350 *factor) withFont: font];
        
        CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
        font = [UIFont fontWithName:normalFont
     size:48.0f *factor];
        [database.current_print_name_1 drawAtPoint:CGPointMake(653 *factor, 2641 *factor) withFont: font];
        //[database.current_print_name_2 drawAtPoint:CGPointMake(653 *factor, 2758 *factor) withFont: font];
        [database.current_print_name_3 drawAtPoint:CGPointMake(653 *factor, 2875 *factor) withFont: font];
        
        CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
        font = [UIFont fontWithName:normalFont
     size:48.0f *factor];
        [PDF_room_number drawInRect:CGRectMake(132 *factor, 1650 *factor, 2258 *factor, 544 *factor) withFont:font];
        //NSString *temp_special_instructions = [[database.current_special_instructions componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@"; "];
        //[temp_special_instructions drawInRect:CGRectMake(132 *factor, 1780 *factor, 2258 *factor, 300 *factor) withFont:font];
        //if([database.current_inventory_existing_equip isEqualToString:@"1188"]){
        //    [@"(Inventory of existing equipment)"  drawInRect:CGRectMake(700 *factor, 1553 *factor, 2258 *factor, 300 *factor) withFont:font];
        //}
        //NSLog(@"%@", PDF_room_number);
        
        CGContextSetFillColorWithColor(pdfContext, [UIColor darkGrayColor].CGColor);
        font = [UIFont fontWithName:normalFont
     size:48.0f *factor];
        [@"I acknowledge that the aforementioned technology products are to be installed only in the previously surveyed locations. Any changes to the room location(s) or sales order may result in a delay of installation." drawInRect:CGRectMake(170 *factor, 2380 *factor, 2210 *factor, 162 *factor) withFont:font];
        
        NSString *imageString1 = [NSString stringWithFormat:@"SS - %@ - Activity#%@ (%@) - signature1", (database.current_teq_rep == nil)? @"":database.current_teq_rep, (database.current_activity_no  == nil)? @"": database.current_activity_no, (database.current_date == nil)? @"":database.current_date];
        imageString1 = [database sanitizeFile:imageString1];
        
        UIImage *backgroundImage1 = [self loadImage: imageString1 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        [backgroundImage1 drawInRect:CGRectMake(1786 *factor, 2587 *factor, 245 *factor, 98 *factor)];
        
        NSString *imageString2 = [NSString stringWithFormat:@"SS - %@ - Activity#%@ (%@) - signature2", (database.current_teq_rep == nil)? @"":database.current_teq_rep, (database.current_activity_no  == nil)? @"": database.current_activity_no, (database.current_date == nil)? @"":database.current_date];
        imageString2 = [database sanitizeFile:imageString2];
        
        UIImage *backgroundImage2 = [self loadImage: imageString2 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        [backgroundImage2 drawInRect:CGRectMake(1786 *factor, 2704 *factor, 245 *factor, 98 *factor)];
        
        NSString *imageString3 = [NSString stringWithFormat:@"SS - %@ - Activity#%@ (%@) - signature3", (database.current_teq_rep == nil)? @"":database.current_teq_rep, (database.current_activity_no  == nil)? @"": database.current_activity_no, (database.current_date == nil)? @"":database.current_date];
        imageString3 = [database sanitizeFile:imageString3];
        
        UIImage *backgroundImage3 = [self loadImage: imageString3 ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        [backgroundImage3 drawInRect:CGRectMake(1786 *factor, 2822 *factor, 245 *factor, 98 *factor)];
        
        // Clean up
        UIGraphicsPopContext();
        CGPDFContextEndPage(pdfContext);
        /*
         for (NSString *family in [UIFont familyNames]) {
         NSLog(@"%@", [UIFont fontNamesForFamilyName:family]);
         }
         */
    }
    [self printRooms:pdfContext withRoomIndex:0];
    //CGPDFContextClose(pdfContext);
    //CGContextRelease(pdfContext);
    //[[NSNotificationCenter defaultCenter]
     //postNotificationName:@"showCompletePDF" object:self userInfo:nil];
}

- (void) printRooms: (CGContextRef) pdfContext withRoomIndex: (int) i {
    //for (int i = 0; i < [PDF_board count]; i++)
    //{
    isql *database = [isql initialize];
    if (i == [PDF_board count]) {
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
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor grayColor].CGColor);
    font = [UIFont fontWithName:normalFont
                           size:48.0f *factor];
    
    [@"Projection: " drawAtPoint:CGPointMake(129 *factor, bl_projection *factor) withFont: font];
    [@"Interactive Whiteboard: " drawAtPoint:CGPointMake(129 *factor, (bl_projection+103) *factor) withFont: font];
    [@"Flat Panel / Interactive Display: " drawAtPoint:CGPointMake(1400 *factor, (bl_projection+103) *factor) withFont: font];
    [@"Mounting Equipment: " drawAtPoint:CGPointMake(129 *factor, (bl_projection+206) *factor) withFont: font];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    font = [UIFont fontWithName:boldFont
                           size:48.0f *factor];
    
    [[PDF_projection objectAtIndex:i ] drawInRect:CGRectMake(370 *factor, bl_projection *factor, 2005 *factor, 140 *factor) withFont:font];
    [[PDF_board objectAtIndex:i ]  drawInRect:CGRectMake(600 *factor, (bl_projection+103) *factor, 760 *factor, 140 *factor) withFont: font];
    [[PDF_flat_panel objectAtIndex:i ] drawInRect:CGRectMake(2000 *factor, (bl_projection+103) *factor, 385 *factor, 270 *factor) withFont: font];
    [[PDF_mounting objectAtIndex:i ] drawInRect:CGRectMake(570 *factor, (bl_projection+206) *factor, 1800 *factor, 140 *factor) withFont: font];
        
    //CMP
        
    float bl_cmp = bl_projection + 373;//987; //1093
    
    fileLocation = [[NSBundle mainBundle] pathForResource:@"black-line" ofType:@"png"];
    imageData = [NSData dataWithContentsOfFile:fileLocation];
    logo = [UIImage imageWithData:imageData];
    [logo drawInRect:CGRectMake(0, (bl_cmp+87) *factor, 2549 *factor, 29 *factor)];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor grayColor].CGColor);
    font = [UIFont fontWithName:normalFont
                           size:48.0f *factor];
    
    [@"CMP Mounting: " drawAtPoint:CGPointMake(129 *factor, bl_cmp *factor) withFont: font];
    [@"CMP Pole Length: " drawAtPoint:CGPointMake(1800 *factor, bl_cmp *factor) withFont: font];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    font = [UIFont fontWithName:boldFont
                           size:48.0f *factor];
    
    [[PDF_projector_mounting objectAtIndex:i ] drawInRect:CGRectMake(450 *factor, bl_cmp *factor, 1340 *factor, 200 *factor) withFont:font];
    [[PDF_cmp_polelength objectAtIndex:i ] drawInRect:CGRectMake(2150 *factor, bl_cmp *factor, 225 *factor, 200 *factor) withFont: font];
    
    //Existing row
    
    float bl_existing = bl_cmp + 87;
    
    fileLocation = [[NSBundle mainBundle] pathForResource:@"black-line" ofType:@"png"];
    imageData = [NSData dataWithContentsOfFile:fileLocation];
    logo = [UIImage imageWithData:imageData];
    [logo drawInRect:CGRectMake(0, (bl_existing+476) *factor, 2549 *factor, 29 *factor)];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor grayColor].CGColor);
    font = [UIFont fontWithName:normalFont
                           size:48.0f *factor];
    [@"Existing Board: " drawAtPoint:CGPointMake(129 *factor, (bl_existing+80) *factor) withFont: font];
    [@"Existing Projector: " drawAtPoint:CGPointMake(1200 *factor, (bl_existing+80) *factor) withFont: font];
    [@"Existing Projector Serial No: " drawAtPoint:CGPointMake(129 *factor, (bl_existing+183) *factor) withFont: font];
    [@"Existing CMP Model: " drawAtPoint:CGPointMake(1200 *factor, (bl_existing+183) *factor) withFont: font];
    [@"Throw Distance from Existing Projector to SB: " drawAtPoint:CGPointMake(129 *factor, (bl_existing+286) *factor) withFont: font];
    [@"Relocate Existing Ceiling Mount (Y/N): " drawAtPoint:CGPointMake(1200 *factor, (bl_existing+286) *factor) withFont: font];
    [@"Current Equipment Location: " drawAtPoint:CGPointMake(129 *factor, (bl_existing+389) *factor) withFont: font];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    font = [UIFont fontWithName:boldFont
                           size:48.0f *factor];
    
    [[PDF_existing_board objectAtIndex:i ] drawInRect:CGRectMake(440 *factor, (bl_existing+80) *factor, 740 *factor, 170 *factor) withFont: font];
    [[PDF_existing_projector objectAtIndex:i ]  drawInRect:CGRectMake(1560 *factor, (bl_existing+80) *factor, 815 *factor, 170 *factor) withFont: font];
    [[PDF_existing_projector_serial objectAtIndex:i ] drawInRect:CGRectMake(660 *factor, (bl_existing+183) *factor, 500 *factor, 170 *factor)  withFont: font];
    [[PDF_existing_cmp_model objectAtIndex:i ] drawInRect:CGRectMake(1610 *factor, (bl_existing+183) *factor, 770 *factor, 170 *factor) withFont: font];
    [[PDF_existing_cmp_throw_distance objectAtIndex:i ]  drawInRect:CGRectMake(980 *factor, (bl_existing+286) *factor, 200 *factor, 170 *factor) withFont: font];
    [[PDF_existing_cmp_remount objectAtIndex:i ] drawAtPoint:CGPointMake(1920 *factor, (bl_existing+286) *factor) withFont: font];
    [[PDF_mounting_location objectAtIndex:i ] drawInRect:CGRectMake(679 *factor, (bl_existing+389) *factor, 1700 *factor, 170 *factor) withFont: font];
                      
    //audio
    float bl_audio = bl_existing+476;//1360;
    
    
    fileLocation = [[NSBundle mainBundle] pathForResource:@"black-line" ofType:@"png"];
    imageData = [NSData dataWithContentsOfFile:fileLocation];
    logo = [UIImage imageWithData:imageData];
    [logo drawInRect:CGRectMake(0, (bl_audio+270) *factor, 2549 *factor, 29 *factor)];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor grayColor].CGColor);
    font = [UIFont fontWithName:normalFont
                           size:48.0f *factor];
    
    [@"Speaker: " drawAtPoint:CGPointMake(129 *factor, (bl_audio+80) *factor) withFont: font];
    [@"Room Audio System: " drawAtPoint:CGPointMake(1094 *factor, (bl_audio+80) *factor) withFont: font];
    [@"Audio Accessories: " drawAtPoint:CGPointMake(129 *factor, (bl_audio+183) *factor) withFont: font];
    /*
    [@"Ceiling Speakers: " drawAtPoint:CGPointMake(1094 *factor, (bl_audio+80) *factor) withFont: font];
    [@"Wall Speakers: " drawAtPoint:CGPointMake(1726 *factor, (bl_audio+80) *factor) withFont: font];
    
    [@"Receiver Mounting Bracket: " drawAtPoint:CGPointMake(129 *factor, (bl_audio+183) *factor) withFont: font];
    [@"Ceiling Sensors: " drawAtPoint:CGPointMake(1094 *factor, (bl_audio+183) *factor) withFont: font];
    [@"Wall Sensors: " drawAtPoint:CGPointMake(1726 *factor, (bl_audio+183) *factor) withFont: font];
    */
    CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    font = [UIFont fontWithName:boldFont
                           size:48.0f *factor];
    
    
    [[PDF_speaker objectAtIndex:i] drawInRect:CGRectMake(320 *factor, (bl_audio+80) *factor, 730 *factor, 170 *factor) withFont: font];
    [[PDF_audio objectAtIndex:i] drawInRect:CGRectMake(1523 *factor, (bl_audio+80) *factor, 860 *factor, 170 *factor) withFont:font];
    [[PDF_audio_accessories objectAtIndex:i] drawInRect:CGRectMake(503 *factor, (bl_audio+183) *factor, 1880 *factor, 170 *factor) withFont:font];
        
    /*
    [[PDF_ceiling_speakers objectAtIndex:i] drawAtPoint:CGPointMake(1443 *factor, (bl_audio+80) *factor) withFont: font];
    [[PDF_wall_speakers objectAtIndex:i] drawAtPoint:CGPointMake(2029 *factor, (bl_audio+80) *factor) withFont: font];
    
    [[PDF_mounting_bracket objectAtIndex:i] drawAtPoint:CGPointMake(673 *factor, (bl_audio+183) *factor) withFont: font];
    [[PDF_ceiling_sensors objectAtIndex:i] drawAtPoint:CGPointMake(1424 *factor, (bl_audio+183) *factor) withFont: font];
    [[PDF_wall_sensors objectAtIndex:i] drawAtPoint:CGPointMake(2009 *factor, (bl_audio+183) *factor) withFont: font];
    */        
    //Cables row
    
    float bl_cable = bl_audio+270;//1733;//1630;
        
    fileLocation = [[NSBundle mainBundle] pathForResource:@"black-line" ofType:@"png"]; //peripheral line
    imageData = [NSData dataWithContentsOfFile:fileLocation];
    logo = [UIImage imageWithData:imageData];
    [logo drawInRect:CGRectMake(0, (bl_cable+477) *factor, 2549 *factor, 29 *factor)];
            
    CGContextSetFillColorWithColor(pdfContext, [UIColor grayColor].CGColor);
    font = [UIFont fontWithName:normalFont
                           size:48.0f *factor];
    
    [@"Cable Type, Length, Quantity: " drawAtPoint:CGPointMake(129 *factor, (bl_cable+80) *factor) withFont: font];
    [@"Device Plate: " drawAtPoint:CGPointMake(129 *factor, (bl_cable+284) *factor) withFont: font];
    [@"Ports: " drawAtPoint:CGPointMake(1500 *factor, (bl_cable+284) *factor) withFont: font];
    
    [@"Raceway: " drawAtPoint:CGPointMake(129 *factor, (bl_cable+387) *factor) withFont: font];
    [@"Peripherals: " drawAtPoint:CGPointMake(1500 *factor, (bl_cable+387) *factor) withFont: font];
    CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    font = [UIFont fontWithName:boldFont
                           size:48.0f *factor];
        
    [[PDF_cables objectAtIndex:i] drawInRect:CGRectMake(711 *factor, (bl_cable+80) *factor, 1660 *factor, 200 *factor) withFont:font];
    [[PDF_device_plate objectAtIndex:i] drawInRect:CGRectMake(410 *factor, (bl_cable+284) *factor, 1050 *factor, 140 *factor) withFont: font];
    [[PDF_port_desc objectAtIndex:i] drawInRect:CGRectMake(1650 *factor, (bl_cable+284) *factor, 700 *factor, 170 *factor) withFont: font];
    [[PDF_Raceway_parts objectAtIndex:i] drawInRect:CGRectMake(360 *factor, (bl_cable+387) *factor, 720 *factor, 170 *factor) withFont: font];    
    [[PDF_peripherals objectAtIndex:i] drawInRect:CGRectMake(1770 *factor, (bl_cable+387) *factor, 600 *factor, 170 *factor) withFont: font];
    
    float bl_height = bl_cable+557;//527;
    
    fileLocation = [[NSBundle mainBundle] pathForResource:@"black-line" ofType:@"png"];
    imageData = [NSData dataWithContentsOfFile:fileLocation];
    logo = [UIImage imageWithData:imageData];
    [logo drawInRect:CGRectMake(0, (bl_height+80) *factor, 2549 *factor, 29 *factor)];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor grayColor].CGColor);
    font = [UIFont fontWithName:normalFont
                           size:48.0f *factor];
    
    [@"Height of SB: " drawAtPoint:CGPointMake(129 *factor, bl_height *factor) withFont: font];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    font = [UIFont fontWithName:boldFont
                           size:48.0f *factor];
    
    [[PDF_height_of_smartboard objectAtIndex:i] drawInRect:CGRectMake(420 *factor, bl_height *factor, 1955 *factor, 170 *factor) withFont: font];
    
    //Ceiling Structure row
    float bl_ceiling = bl_height + 160;
    
    fileLocation = [[NSBundle mainBundle] pathForResource:@"black-line" ofType:@"png"];
    imageData = [NSData dataWithContentsOfFile:fileLocation];
    logo = [UIImage imageWithData:imageData];
    [logo drawInRect:CGRectMake(0, (bl_ceiling+80) *factor, 2549 *factor, 29 *factor)];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor grayColor].CGColor);
    font = [UIFont fontWithName:normalFont
                           size:48.0f *factor];
    
    [@"Ceiling Height: " drawAtPoint:CGPointMake(129 *factor, bl_ceiling *factor) withFont: font];
    [@"Ceiling Structure: " drawAtPoint:CGPointMake(1200 *factor, bl_ceiling *factor) withFont: font];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    font = [UIFont fontWithName:boldFont
                           size:48.0f *factor];
    
    [[PDF_ceiling_height objectAtIndex:i] drawAtPoint:CGPointMake(430 *factor, bl_ceiling *factor) withFont: font];
    [[PDF_ceiling_structure objectAtIndex:i] drawInRect:CGRectMake(1550 *factor, bl_ceiling *factor, 830 *factor, 170 *factor) withFont: font];
    
    //Wall Structure row
    float bl_wall = bl_height + 320;
    
    fileLocation = [[NSBundle mainBundle] pathForResource:@"black-line" ofType:@"png"];
    imageData = [NSData dataWithContentsOfFile:fileLocation];
    logo = [UIImage imageWithData:imageData];
    [logo drawInRect:CGRectMake(0, (bl_wall+183) *factor, 2549 *factor, 29 *factor)];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor grayColor].CGColor);
    font = [UIFont fontWithName:normalFont
                           size:48.0f *factor];
    
    [@"Wall Structure: " drawAtPoint:CGPointMake(129 *factor, bl_wall *factor) withFont: font];
    [@"Existing Board: " drawAtPoint:CGPointMake(1200 *factor, bl_wall *factor) withFont: font];
    [@"Cork Penetrated: " drawAtPoint:CGPointMake(129 *factor, (bl_wall + 103) *factor) withFont: font];
    [@"Wall Number: " drawAtPoint:CGPointMake(1200 *factor, (bl_wall + 103) *factor) withFont: font];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    font = [UIFont fontWithName:boldFont
                           size:48.0f *factor];
    
    [[PDF_wall_structure objectAtIndex:i] drawInRect:CGRectMake(430 *factor, bl_wall *factor, 750 *factor, 170 *factor) withFont: font];
    [[PDF_wall_structure_board objectAtIndex:i] drawInRect:CGRectMake(1500 *factor, bl_wall *factor, 880 *factor, 170 *factor) withFont: font];
    [[PDF_cork_penetrated objectAtIndex:i] drawAtPoint:CGPointMake(480 *factor, (bl_wall + 103) *factor) withFont: font];
    [[PDF_wall_number objectAtIndex:i] drawAtPoint:CGPointMake(1500 *factor, (bl_wall + 103) *factor) withFont: font];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor grayColor].CGColor);
    font = [UIFont fontWithName:normalFont
                           size:48.0f *factor];
    
    float bl_client = bl_height + 583;
    
    [@"Client agrees to remove: " drawAtPoint:CGPointMake(129 *factor, bl_client *factor) withFont: font];
    [@"Client will provide power: " drawAtPoint:CGPointMake(129 *factor, (bl_client+103) *factor) withFont: font];
    [@"Existing Power within 3' of SB:" drawAtPoint:CGPointMake(1600 *factor, (bl_client + 103) *factor) withFont: font];
    
    CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    font = [UIFont fontWithName:boldFont
                           size:48.0f *factor];
    
    [[PDF_client_remove objectAtIndex:i] drawInRect:CGRectMake(610 *factor, bl_client *factor, 1770 *factor, 170 *factor) withFont: font];
    [[PDF_client_provide_power objectAtIndex:i] drawInRect:CGRectMake(630 *factor, (bl_client+103) *factor, 1750 *factor, 170 *factor) withFont: font];
    [[PDF_power_within_three_feet objectAtIndex:i] drawInRect: CGRectMake(2195 *factor, (bl_client + 103) *factor, 200 *factor, 100 *factor) withFont: font];
    
    
    
    
    
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
        
    UIImage *drawImage = [self loadImage: [PDF_drawing objectAtIndex:i] ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    [drawImage drawInRect:CGRectMake(995 *factor, (cm_client-140) *factor, 1509 *factor, 1509 *factor)];
    
   
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
