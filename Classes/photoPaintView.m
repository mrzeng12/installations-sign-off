//
//  photoPaintView.m
//  Site Survey
//
//  Created by Helpdesk on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "photoPaintView.h"
#import "isql.h"
#import "UIImage+fixOrientation.h"
#import <QuartzCore/QuartzCore.h>

@implementation photoPaintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        screenScale = [UIScreen mainScreen].scale;
        strokeWidth = 3* screenScale;
        
        [self initContext:frame.size];
    }
    return self;
}

-(void)photoEditorNotification:(NSNotification*)notifications {
    
    int tagNumber = [[[notifications userInfo] valueForKey:@"index"] intValue];
    
    if (tagNumber == 0) {
        //cancel
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"customizedDismissModalForPhotoPaintView" object:self];
        
        NSDictionary *dict= [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:3] forKey:@"index"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
    }
    if (tagNumber == 1) {
        //clear
        isql *database = [isql initialize];
        
        UIImage *myImage = [self loadImage: database.editingNSUrl ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        myImage = [myImage fixOrientationWithOrientation:5];
        CGContextDrawImage(cacheContext,CGRectMake(0, 0, myImage.size.width*screenScale, myImage.size.height*screenScale),myImage.CGImage);
        myImage = nil;
        [self setNeedsDisplay];
        
    }
    if (tagNumber == 2) {
        //done
        UIImage *newImage = nil;
        
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
        
        [self.layer renderInContext: UIGraphicsGetCurrentContext()];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        if ([UIScreen mainScreen].scale == 2.0) {
            //retina screen
            if (newImage.size.width > newImage.size.height) {
                newImage = [self imageWithImage:newImage scaledToSize:CGSizeMake(320, 240)];
            }
            else {
                newImage = [self imageWithImage:newImage scaledToSize:CGSizeMake(240, 320)];
            }
        }
        else {
            if (newImage.size.width > newImage.size.height) {
                newImage = [self imageWithImage:newImage scaledToSize:CGSizeMake(640, 480)];
            }
            else {
                newImage = [self imageWithImage:newImage scaledToSize:CGSizeMake(480, 640)];
            }
        }
        
        
        isql *database = [isql initialize];
        database.editedPhoto = newImage;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"finshedEditingPhotos" object:self];
                
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"customizedDismissModalForPhotoPaintView" object:self];
        
        NSDictionary *dict= [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:3] forKey:@"index"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"moveOnToCertainMenuPage" object:self userInfo:dict];
    }
    
}

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
    CGColorSpaceRelease(colorSpace);
	//return YES;
    
    
    isql *database = [isql initialize];
    
    UIImage *myImage = [self loadImage: database.editingNSUrl ofType:@"jpg" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    myImage = [myImage fixOrientationWithOrientation:5];
    CGContextDrawImage(cacheContext,CGRectMake(0, 0, myImage.size.width*screenScale, myImage.size.height*screenScale),myImage.CGImage);
    myImage = nil;
    [self setNeedsDisplay];
    
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
    UIColor *color = [UIColor redColor];
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
        
        UIColor *color = [UIColor redColor];
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
        //[self setNeedsDisplay];
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
    //CGContextRelease(context);
    //NSLog(@"draw");
}

-(UIImage *)imageWithImage:(UIImage *)imageToCompress scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [imageToCompress drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    return result;
}

@end
