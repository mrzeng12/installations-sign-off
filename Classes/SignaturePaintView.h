//
//  SignaturePaintView.h
//  Site Survey
//
//  Created by Helpdesk on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignaturePaintView : UIView {
    void *cacheBitmap;
    CGContextRef cacheContext;
    
    UIButton *doneBtn;
    UIButton *clearBtn;
    UIButton *cancelBtn;
    
    CGPoint point0;
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
    
    int screenScale;
    int strokeWidth;
}
- (void) initContext:(CGSize)size;
- (void) drawToCache;
- (void) drawPoint;
- (NSString*) writablePath;


@end
