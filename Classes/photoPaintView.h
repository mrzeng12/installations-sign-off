//
//  photoPaintView.h
//  Site Survey
//
//  Created by Helpdesk on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

@interface photoPaintView : UIView {
   
    CGContextRef cacheContext;
    
    CGPoint point0;
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
    
    UIButton *doneBtn;
    UIButton *clearBtn;
    UIButton *cancelBtn;
    
    int screenScale;
    int strokeWidth;
}
- (void) initContext:(CGSize)size;
- (void) drawToCache;
- (void) drawPoint;
- (NSString*) writablePath;
@end
