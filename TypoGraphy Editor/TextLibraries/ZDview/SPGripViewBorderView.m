//
//  SPGripViewBorderView.m
//
//  Created by Seonghyun Kim on 6/3/13.
//  Copyright (c) 2013 scipi. All rights reserved.
//
//  This file was modified from SPUserResizableView.

#import "SPGripViewBorderView.h"

@implementation SPGripViewBorderView

#define kSPUserResizableViewGlobalInset 5.0
#define kSPUserResizableViewDefaultMinWidth 48.0
#define kSPUserResizableViewDefaultMinHeight 48.0
#define kSPUserResizableViewInteractiveBorderSize 10.0

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Clear background to ensure the content view shows through.
        self.wantsLayer = true;
        self.layer.backgroundColor = [NSColor clearColor].CGColor;
        self.borderColor = [NSColor grayColor];
        self.borderWidth = 1.f;
        self.layer.borderWidth = self.borderWidth;
        self.layer.borderColor = NSColor.whiteColor.CGColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
//    CGContextRef context = NSGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//    
//    CGContextSetLineWidth(context, self.borderWidth);
//    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
//    CGContextAddRect(context, CGRectInset(self.bounds, kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewInteractiveBorderSize/2));
//    CGContextStrokePath(context);
//    
//    CGContextRestoreGState(context);
}

@end
