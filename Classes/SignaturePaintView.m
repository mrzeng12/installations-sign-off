//
//  SignaturePaintView.m
//  Site Survey
//
//  Created by Helpdesk on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignaturePaintView.h"
#import <QuartzCore/QuartzCore.h>
#import "isql.h"

@implementation SignaturePaintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        screenScale = [UIScreen mainScreen].scale;
        strokeWidth = 7* screenScale;
        [self initContext:frame.size];
        //[self drawToCache];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) initContext:(CGSize)size {
	
	int	bitmapBytesPerRow;
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow = (size.width*screenScale * 4);
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	cacheContext = CGBitmapContextCreate (nil, size.width*screenScale, size.height*screenScale, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst);
	//return YES;
    CGColorSpaceRelease(colorSpace);
    
    CGRect rectangle_bg = CGRectMake(0,0,self.frame.size.width*screenScale,self.frame.size.height*screenScale);
    CGContextAddRect(cacheContext, rectangle_bg);
    CGContextStrokePath(cacheContext);
    CGContextSetFillColorWithColor(cacheContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(cacheContext, rectangle_bg);
    
    doneBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneBtn.frame= CGRectMake(895, 15, 80, 40);
    [doneBtn setTitle:@"Save" forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:doneBtn];
    
    clearBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    clearBtn.frame= CGRectMake(100, 15, 80, 40);
    [clearBtn setTitle:@"Clear" forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:clearBtn];
    
    cancelBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelBtn.frame= CGRectMake(10, 15, 80, 40);
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];

}
//CGImageRef UIGetScreenImage(void);
- (void) cancelButtonAction {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"cancelPopover" object:self];
}

- (void) clearButtonAction {
    CGRect rectangle_bg = CGRectMake(0,0,self.frame.size.width*screenScale,self.frame.size.height*screenScale);
    CGContextAddRect(cacheContext, rectangle_bg);
    CGContextStrokePath(cacheContext);
    CGContextSetFillColorWithColor(cacheContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(cacheContext, rectangle_bg);
    [self setNeedsDisplay];
}

- (void) doneButtonAction {
    
    isql *database = [isql initialize];
    //The image where the view content is going to be saved.
    UIImage* image = nil;
    
    [doneBtn setHidden:YES];
    [clearBtn setHidden:YES];
    [cancelBtn setHidden:YES];
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    
    [self.layer renderInContext: UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    //CGImageRef screen = UIGetScreenImage();
    //image = [UIImage imageWithCGImage:screen];

    UIGraphicsEndImageContext();
    [doneBtn setHidden:NO];
    [clearBtn setHidden:NO];
    [cancelBtn setHidden:NO];
    
    NSData* imgData = UIImageJPEGRepresentation(image, 0.75);
    //UIImagePNGRepresentation(image);
    NSString *imageString;
    if ([database.signature_filename isEqualToString:@"Primary_Contact"]) {
        imageString = [NSString stringWithFormat:@"SS - %@ - Activity#%@ (%@) - signature1", (database.current_teq_rep == nil)? @"":database.current_teq_rep, (database.current_activity_no  == nil)? @"": database.current_activity_no, (database.current_date == nil)? @"":database.current_date];
        imageString = [database sanitizeFile:imageString];
        database.current_signature_file_directory_1 = imageString;
    }
    if ([database.signature_filename isEqualToString:@"Custodial_Engineer"]) {
        imageString = [NSString stringWithFormat:@"SS - %@ - Activity#%@ (%@) - signature2", (database.current_teq_rep == nil)? @"":database.current_teq_rep, (database.current_activity_no  == nil)? @"": database.current_activity_no, (database.current_date == nil)? @"":database.current_date];
        imageString = [database sanitizeFile:imageString];
        database.current_signature_file_directory_2 = imageString;
    }
    if ([database.signature_filename isEqualToString:@"Teq_Representative"]) {
        imageString = [NSString stringWithFormat:@"SS - %@ - Activity#%@ (%@) - signature3", (database.current_teq_rep == nil)? @"":database.current_teq_rep, (database.current_activity_no  == nil)? @"": database.current_activity_no, (database.current_date == nil)? @"":database.current_date];
        imageString = [database sanitizeFile:imageString];
        database.current_signature_file_directory_3 = imageString;
    }
    NSString* targetPath = [NSString stringWithFormat:@"%@/%@.%@", [self writablePath], imageString, @"jpg" ];
    
    [imgData writeToFile:targetPath atomically:YES]; 
    //NSLog(@"%@",[NSString stringWithFormat:@"%@/%@.%@", [self writablePath], database.signature_filename, @"png" ]);
        
    //PDFRenderer *renderer = [PDFRenderer new];
    //renderer.callBackString = @"none";
    //[renderer loadVariablesForPDF];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"customizedDismissPopover" object:self];
}

-(NSString*) writablePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}



- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    point0 = CGPointMake(-1, -1);
    point1 = CGPointMake(-1, -1); // previous previous point
    point2 = CGPointMake(-1, -1); // previous touch point
    point3 = [touch locationInView:self]; // current touch point
    point3 = CGPointMake(point3.x*screenScale, point3.y*screenScale);
    //NSLog(@"touch began");
    [self drawPoint];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    point0 = point1;
    point1 = point2;
    point2 = point3;
    point3 = [touch locationInView:self];
    point3 = CGPointMake(point3.x*screenScale, point3.y*screenScale);
    //NSLog(@"moved");
    [self drawToCache];
}

- (void) drawPoint {
    UIColor *color = [UIColor blackColor];
    CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
    CGContextSetLineCap(cacheContext, kCGLineCapRound);
    CGContextSetLineWidth(cacheContext, strokeWidth);
    
    CGContextMoveToPoint(cacheContext, point3.x, point3.y);
    CGContextAddLineToPoint(cacheContext, point3.x, point3.y);
    CGContextStrokePath(cacheContext);
    
    [self setNeedsDisplay];
}

- (void) drawToCache {
    if(point1.x > -1){
        
        UIColor *color = [UIColor blackColor];
        CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
        CGContextSetLineCap(cacheContext, kCGLineCapRound);
        CGContextSetLineWidth(cacheContext, strokeWidth);
        
        double x0 = (point0.x > -1) ? point0.x : point1.x; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double y0 = (point0.y > -1) ? point0.y : point1.y; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double x1 = point1.x;
        double y1 = point1.y;
        double x2 = point2.x;
        double y2 = point2.y;
        double x3 = point3.x;
        double y3 = point3.y;
        // Assume we need to calculate the control
        // points between (x1,y1) and (x2,y2).
        // Then x0,y0 - the previous vertex,
        //      x3,y3 - the next one.
        
        double xc1 = (x0 + x1) / 2.0;
        double yc1 = (y0 + y1) / 2.0;
        double xc2 = (x1 + x2) / 2.0;
        double yc2 = (y1 + y2) / 2.0;
        double xc3 = (x2 + x3) / 2.0;
        double yc3 = (y2 + y3) / 2.0;
        
        double len1 = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0));
        double len2 = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1));
        double len3 = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2));
        
        double k1 = len1 / (len1 + len2);
        double k2 = len2 / (len2 + len3);
        
        double xm1 = xc1 + (xc2 - xc1) * k1;
        double ym1 = yc1 + (yc2 - yc1) * k1;
        
        double xm2 = xc2 + (xc3 - xc2) * k2;
        double ym2 = yc2 + (yc3 - yc2) * k2;
        double smooth_value = 0.8;
        // Resulting control points. Here smooth_value is mentioned
        // above coefficient K whose value should be in range [0...1].
        float ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
        float ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;
        
        float ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
        float ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;
        
        
        CGContextMoveToPoint(cacheContext, point1.x, point1.y);
        CGContextAddCurveToPoint(cacheContext, ctrl1_x, ctrl1_y, ctrl2_x, ctrl2_y, point2.x, point2.y);
        CGContextStrokePath(cacheContext);
        
        CGRect dirtyPoint1 = CGRectMake(point1.x/screenScale-10, point1.y/screenScale-10, 20, 20);
        CGRect dirtyPoint2 = CGRectMake(point2.x/screenScale-10, point2.y/screenScale-10, 20, 20);
        [self setNeedsDisplayInRect:CGRectUnion(dirtyPoint1, dirtyPoint2)];
    }
}

- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
    CGContextDrawImage(context, self.bounds, cacheImage);
    CGImageRelease(cacheImage);
}



@end
