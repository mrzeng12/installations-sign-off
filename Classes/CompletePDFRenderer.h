//
//  CompletePDFRenderer.h
//  Site Survey
//
//  Created by Helpdesk on 8/23/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface CompletePDFRenderer : NSObject {
    
    float factor;
    NSString *normalFont;
    NSString *boldFont;
    
    //NSArray
    NSMutableArray *classroom_number;
    NSMutableArray *classroom_floor;
    NSMutableArray *classroom_grade;
    NSMutableArray *classroom_notes;
    
    NSMutableArray *installer;
    NSMutableArray *status;
    NSMutableArray *serial_no;
    NSMutableArray *general_notes;
    
    NSMutableArray *Photo_file_directory_1;
    NSMutableArray *Photo_file_directory_2;
    NSMutableArray *Photo_file_directory_3;
    NSMutableArray *Photo_file_directory_4;
    NSMutableArray *Photo_file_directory_5;
    NSMutableArray *Photo_file_directory_6;
    NSMutableArray *Photo_file_directory_7;
    NSMutableArray *Photo_file_directory_8;
    
    /*** PDF ***/
    NSMutableArray *PDF_room; 
    
    NSMutableArray *PDF_status_installer;
    NSMutableArray *PDF_serial_no;
    NSMutableArray *PDF_comments;
    
    NSMutableArray *PDF_photo_file_directory_1;
    NSMutableArray *PDF_photo_file_directory_2;
    NSMutableArray *PDF_photo_file_directory_3;
    NSMutableArray *PDF_photo_file_directory_4;
    NSMutableArray *PDF_photo_file_directory_5;
    NSMutableArray *PDF_photo_file_directory_6;
    NSMutableArray *PDF_photo_file_directory_7;
    NSMutableArray *PDF_photo_file_directory_8;
    
}

@property (strong, nonatomic) NSString *callBackFunction;

- (void) loadVariablesForPDF;
- (void) rewriteVariablesToReadablePDFFields;
- (void) drawPDF:(NSString*)fileName;
- (UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath;
- (NSString*) getPDFFileName;

@end
