//
// ZDStickerView.m
//
// Created by Seonghyun Kim on 5/29/13.
// Copyright (c) 2013 scipi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ZDStickerView.h"
#import "SPGripViewBorderView.h"
#import <AppKit/AppKit.h>
//#import "NSImage+Rotated.h"

#define kSPUserResizableViewGlobalInset 5.0
#define kSPUserResizableViewDefaultMinWidth 48.0
#define kSPUserResizableViewInteractiveBorderSize 10.0
#define kZDStickerViewControlSize 20.0


#define autoResizeMask




@interface ZDStickerView ()

@property (nonatomic, strong) NSView *borderView;

@property (strong, nonatomic) NSImageView *resizingControl;
@property (strong, nonatomic) NSImageView *deleteControl;
@property (strong, nonatomic) NSImageView *customControl;
@property (strong, nonatomic) NSImageView *editControl;


@property (nonatomic) BOOL preventsLayoutWhileResizing;

@property (nonatomic) CGFloat deltaAngle;
@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGAffineTransform startTransform;

@property (nonatomic) CGPoint touchStart;
@property (nonatomic) NSTrackingArea* trackingArea;

@property (nonatomic) CGRect initialBounds;
@property (nonatomic) double initialDistance;


@end



@implementation ZDStickerView

/*
   // Only override drawRect: if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   - (void)drawRect:(CGRect)rect
   {
    // Drawing code
   }
 */

#ifdef ZDSTICKERVIEW_LONGPRESS
- (void)longPress:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidLongPressed:)])
        {
            [self.stickerViewDelegate stickerViewDidLongPressed:self];
        }
    }
}
#endif


- (void)singleTap:(NSPanGestureRecognizer *)recognizer
{
    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidClose:)])
    {
        [self.stickerViewDelegate stickerViewDidClose:self];
    }

//    if (NO == self.preventsDeleting)
//    {
//        NSView *close = (NSView *)[recognizer view];
//        [close.superview removeFromSuperview];
//    }
}



- (void)customTap:(NSPanGestureRecognizer *)recognizer
{
    if (NO == self.preventsCustomButton)
    {
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidCustomButtonTap:)])
        {
            [self.stickerViewDelegate stickerViewDidCustomButtonTap:self];
        }
    }
}
- (void)editTap:(NSPanGestureRecognizer *)recognizer
{
 if (NO == self.preventsEditing)
 {
 
  if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidEditButtonTap:)])
  {
   [self.stickerViewDelegate stickerViewDidEditButtonTap:self];
  }
 }
 
}


//- (void)pinchTranslate:(UIPinchGestureRecognizer *)recognizer {
//    static CGRect boundsBeforeScaling;
//    static CGAffineTransform transformBeforeScaling;
//
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        boundsBeforeScaling = recognizer.view.bounds;
//        transformBeforeScaling = recognizer.view.transform;
//    }
//
//    CGPoint center = recognizer.view.center;
//    CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity,
//                                                     recognizer.scale,
//                                                     recognizer.scale);
//    CGRect frame = CGRectApplyAffineTransform(boundsBeforeScaling, scale);
//
//    frame.origin = CGPointMake(center.x - frame.size.width / 2,
//                               center.y - frame.size.height / 2);
//
//    recognizer.view.transform = CGAffineTransformIdentity;
//    recognizer.view.frame = frame;
//    recognizer.view.transform = transformBeforeScaling;
//}

//- (void)rotateTranslate:(UIRotationGestureRecognizer *)recognizer {
//    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
//    recognizer.rotation = 0;
//}

- (void)resizeStickerViewFrame:(NSRect)frame {
     self.transform = self.layer.affineTransform;
     
     [self setCustomTransform:CGAffineTransformIdentity];
     self.frame = frame;
     self.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
 
     self.resizingControl.frame = CGRectMake(self.frame.size.width-kZDStickerViewControlSize,
                                             self.frame.size.height-kZDStickerViewControlSize,
                                             kZDStickerViewControlSize, kZDStickerViewControlSize);
     self.deleteControl.frame = CGRectMake(0, self.frame.size.height-kZDStickerViewControlSize,
                                           kZDStickerViewControlSize, kZDStickerViewControlSize);
     self.customControl.frame =CGRectMake(self.frame.size.width-kZDStickerViewControlSize,
                                          0,
                                          kZDStickerViewControlSize,
                                          kZDStickerViewControlSize);
     self.editControl.frame =CGRectMake(0,
                                      0,
                                      kZDStickerViewControlSize,
                                      kZDStickerViewControlSize);
 
     [self setCustomTransform:self.transform];
     self.borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
 
     [self.borderView setNeedsDisplay:YES];
 
     [self setNeedsDisplay:YES];
 
     [self resetCursorRects];
     if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidResize:)]) {
         [self.stickerViewDelegate stickerViewDidResize:self];
     }
}


- (void)resizeTranslate:(NSPanGestureRecognizer *)recognizer
{
 
    CGPoint point = [recognizer locationInView:self.superview];
    CGPoint center = self.center;

    if ([recognizer state] == NSGestureRecognizerStateBegan)
    {
        [self enableTransluceny:YES];
        self.prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay:YES];
     
        self.initialBounds = self.bounds;
        self.initialDistance = [self getDistanceBetweenPoint1:center andPoint2:point];
     
        // Inform delegate.
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidBeginEditing:)]) {
            [self.stickerViewDelegate stickerViewDidBeginEditing:self];
        }
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidBeginResizing:)]) {
           [self.stickerViewDelegate stickerViewDidBeginResizing:self];
        }
    }
    else if ([recognizer state] == NSGestureRecognizerStateChanged)
    {
     
        [self enableTransluceny:YES];
        self.transform = self.layer.affineTransform;
        [self setCustomTransform:CGAffineTransformIdentity];
     
         double distance = [self getDistanceBetweenPoint1:center andPoint2:point];
         //NSLog(@"test %f", distance);
         double scale = distance / self.initialDistance ;
         CGFloat minimumScale =  50.0f / MIN(self.initialBounds.size.width, self.initialBounds.size.height);
         scale = MAX(scale, minimumScale);
         
         CGRect newBounds = [self scaleRect:self.initialBounds wScale:scale hScale:scale];
     
         if (newBounds.size.width > self.superview.frame.size.width + 200 || newBounds.size.height > self.superview.frame.size.height + 200) {
          return;
         }

         self.frame = newBounds;
         self.bounds = newBounds;
            
         self.resizingControl.frame = CGRectMake(self.frame.size.width-kZDStickerViewControlSize,
                                                self.frame.size.height-kZDStickerViewControlSize,
                                                kZDStickerViewControlSize, kZDStickerViewControlSize);
         self.deleteControl.frame = CGRectMake(0, self.frame.size.height-kZDStickerViewControlSize,
                                               kZDStickerViewControlSize, kZDStickerViewControlSize);
         self.customControl.frame =CGRectMake(self.frame.size.width-kZDStickerViewControlSize,
                                              0,
                                              kZDStickerViewControlSize,
                                              kZDStickerViewControlSize);
     self.editControl.frame =CGRectMake(0,
                                          0,
                                          kZDStickerViewControlSize,
                                          kZDStickerViewControlSize);
     
         self.prevPoint = [recognizer locationInView:self];
         self.center = center;
     

        [self setCustomTransform:self.transform];
        self.borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
        
        [self.borderView setNeedsDisplay:YES];

        [self setNeedsDisplay:YES];
     
        [self resetCursorRects];
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidResize:)]) {
         [self.stickerViewDelegate stickerViewDidResize:self];
        }
    }
    else if ([recognizer state] == NSGestureRecognizerStateEnded)
    {
        [self enableTransluceny:NO];
        self.prevPoint = [recognizer locationInView:self];
        [self setCustomTransform:self.transform];
        [self setNeedsDisplay:YES];
        
        // Inform delegate.
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidEndEditing:)]) {
            [self.stickerViewDelegate stickerViewDidEndEditing:self];
        }
     
     
        
    }
    else if ([recognizer state] == NSGestureRecognizerStateCancelled)
    {
        // Inform delegate.
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidCancelEditing:)]) {
            [self.stickerViewDelegate stickerViewDidCancelEditing:self];
        }
    }
}
- (void)rotateTranslate:(NSPanGestureRecognizer *)recognizer
{
    if ([recognizer state] == NSGestureRecognizerStateBegan)
    {
        [self enableTransluceny:YES];
        self.prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay:YES];
        
        // Inform delegate.
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidBeginEditing:)]) {
            [self.stickerViewDelegate stickerViewDidBeginEditing:self];
        }
//        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidBeginRotating:)]) {
//            [self.stickerViewDelegate stickerViewDidBeginRotating:self];
//        }
     
    }
    else if ([recognizer state] == NSGestureRecognizerStateChanged)
    {
        [self enableTransluceny:YES];
        /* Rotation */
//        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
//                          [recognizer locationInView:self.superview].x - self.center.x);
     
    // float ang = atan2([recognizer locationInView:self.superview].y - NSMidY(self.frame),
   //                    [recognizer locationInView:self.superview].x - NSMidX(self.frame));
     float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
                             [recognizer locationInView:self.superview].x - self.center.x);
        
        float angleDiff = self.deltaAngle - ang;
        
        if (NO == self.preventsResizing)
        {
            self.transform = CGAffineTransformMakeRotation(-angleDiff);
            
            [self setCustomTransform:self.transform];
        }
        
        self.borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
        
        [self.borderView setNeedsDisplay:YES];
        
        [self setNeedsDisplay:YES];
    }
    else if ([recognizer state] == NSGestureRecognizerStateEnded)
    {
        [self enableTransluceny:NO];
        self.prevPoint = [recognizer locationInView:self];
        //[self setCustomTransform:self.transform];
        [self setNeedsDisplay:YES];
        
        // Inform delegate.
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidEndEditing:)]) {
            [self.stickerViewDelegate stickerViewDidEndEditing:self];
        }
        
        [self resetCursorRects];
    }
    else if ([recognizer state] == NSGestureRecognizerStateCancelled)
    {
        // Inform delegate.
        if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidCancelEditing:)]) {
            [self.stickerViewDelegate stickerViewDidCancelEditing:self];
        }
    }
}


- (void)setupDefaultAttributes
{
   // self.borderView = [[SPGripViewBorderView alloc] initWithFrame:CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset)];
 
 
    self.borderView = [[NSView alloc] initWithFrame:CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset)];
    self.borderView.wantsLayer = true;
    self.borderView.layer.borderColor = NSColor.blackColor.CGColor;
    self.borderWidth = 1;
    
    //self.borderView.layer.borderWidth = 1;
    //[self.borderView setHidden:YES];
    [self addSubview:self.borderView];

    if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0.5)
    {
        self.minWidth = kSPUserResizableViewDefaultMinWidth;
        self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
    }
    else
    {
        self.minWidth = self.bounds.size.width*0.5;
        self.minHeight = self.bounds.size.height*0.5;
    }

    self.preventsPositionOutsideSuperview = YES;
    self.preventsLayoutWhileResizing = YES;
    self.preventsResizing = NO;
    self.preventsDeleting = NO;
    self.preventsCustomButton = NO;
    self.translucencySticker = YES;
    self.allowDragging = YES;
    self.preventsEditing = YES;

#ifdef ZDSTICKERVIEW_LONGPRESS
    UILongPressGestureRecognizer*longpress = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self
                                                      action:@selector(longPress:)];
    [self addGestureRecognizer:longpress];
#endif

    self.deleteControl = [[NSImageView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-kZDStickerViewControlSize,
                                                                      kZDStickerViewControlSize, kZDStickerViewControlSize)];
    self.deleteControl.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.deleteControl.image = [NSImage imageNamed:@"ZDStickerView.bundle/ZDBtn3.png"];
    
    //self.deleteControl.userInteractionEnabled = YES;
    NSClickGestureRecognizer *singleTap = [[NSClickGestureRecognizer alloc]
                                         initWithTarget:self
                                                 action:@selector(singleTap:)];
    [self.deleteControl addGestureRecognizer:singleTap];
    [self addSubview:self.deleteControl];

    self.resizingControl = [[NSImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kZDStickerViewControlSize,
                                                                        self.frame.size.height-kZDStickerViewControlSize,
                                                                        kZDStickerViewControlSize, kZDStickerViewControlSize)];
    self.resizingControl.layer.backgroundColor = [NSColor clearColor].CGColor;
    //self.resizingControl.userInteractionEnabled = YES;
    self.resizingControl.image = [NSImage imageNamed:@"ZDStickerView.bundle/ZDBtn2.png.png"];
    NSPanGestureRecognizer*panResizeGesture = [[NSPanGestureRecognizer alloc]
                                               initWithTarget:self
                                                       action:@selector(resizeTranslate:)];
    [self.resizingControl addGestureRecognizer:panResizeGesture];
    
    
    [self addSubview:self.resizingControl];

    self.customControl = [[NSImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kZDStickerViewControlSize,
                                                                      0,
                                                                      kZDStickerViewControlSize, kZDStickerViewControlSize)];
    self.customControl.layer.backgroundColor = [NSColor clearColor].CGColor;
  //  self.customControl.userInteractionEnabled = YES;
    self.customControl.image = nil;
 

 
    
    // Add pinch gesture recognizer.
//    self.pinchRecognizer = [[NSPinchGestureRecognizer alloc]
//                            initWithTarget:self
//                            action:@selector(pinchTranslate:)];
//    [self addGestureRecognizer:self.pinchRecognizer];
    
    // Add rotation recognizer.
//    self.rotationRecognizer = [[UIRotationGestureRecognizer alloc]
//                               initWithTarget:self
//                               action:@selector(rotateTranslate:)];
//    [self addGestureRecognizer:self.rotationRecognizer];
    
    // Add custom control recognizer.
    NSPanGestureRecognizer*panCustomGesture = [[NSPanGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(rotateTranslate:)];
    [self.customControl addGestureRecognizer:panCustomGesture];
    
    
    
    NSClickGestureRecognizer *customTapGesture = [[NSClickGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(customTap:)];
    [self.customControl addGestureRecognizer:customTapGesture];
    [self addSubview:self.customControl];
 
 
 self.editControl = [[NSImageView alloc]initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 kZDStickerViewControlSize, kZDStickerViewControlSize)];
 self.editControl.layer.backgroundColor = [NSColor clearColor].CGColor;
 
 self.editControl.image = nil;
 NSClickGestureRecognizer *editTapGesture = [[NSClickGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(editTap:)];
 [self.editControl addGestureRecognizer:editTapGesture];
 [self addSubview:self.editControl];

    self.deltaAngle = atan2(self.frame.origin.y - self.center.y,
                            self.frame.origin.x + self.frame.size.width - self.center.x);
 
    self.transform = CGAffineTransformIdentity;
    
 
}
- (NSView *)hitTest:(NSPoint)point {
 
 
     if (self.isHidden) {
      return nil;
     }
 
    CGFloat angle = atan2f(self.transform.b, self.transform.a);
    CGAffineTransform t = CGAffineTransformIdentity;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    t = CGAffineTransformTranslate(t, center.x, center.y);
    t = CGAffineTransformRotate(t, -angle );
    t = CGAffineTransformTranslate(t, -center.x, -center.y);
    CGPoint pointInView = [self convertPoint:point fromView:self.superview];
    CGPoint finalPoint = CGPointApplyAffineTransform(pointInView,t);
 
 
 
    if (NSPointInRect(finalPoint, self.resizingControl.frame)) {
     return self.resizingControl.isHidden ? self.contentView : self.resizingControl;
    }
    if (NSPointInRect(finalPoint, self.deleteControl.frame)) {
     return self.deleteControl.isHidden ? self.contentView : self.deleteControl;
    }
    if (NSPointInRect(finalPoint, self.customControl.frame)) {
     return self.customControl.isHidden ? self.contentView : self.customControl;
    }
    if (NSPointInRect(finalPoint, self.editControl.frame)) {
     return self.editControl.isHidden ? self.contentView : self.editControl;
    }
 
    if (NSPointInRect(finalPoint, self.contentView.frame)) {
     return self.contentView;
    }
 return nil;
 
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setupDefaultAttributes];
    }

    return self;
}



- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setupDefaultAttributes];
    }

    return self;
}



- (void)setContentView:(NSView *)newContentView
{
    [self.contentView removeFromSuperview];
    _contentView = newContentView;

    self.contentView.frame = CGRectInset(self.bounds,
                                         kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2,
                                         kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);

    self.contentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable ;
   // self.contentView.autoresizingMask = NSViewAutoresizingFlexibleWidth | NSViewAutoresizingFlexibleHeight;

    [self addSubview:self.contentView];

    for (NSView *subview in [self.contentView subviews])
    {
        [subview setFrame:CGRectMake(0, 0,
                                     self.contentView.frame.size.width,
                                     self.contentView.frame.size.height)];

        subview.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable ;
    }

    [self bringSubviewToFront:self.borderView];
    [self bringSubviewToFront:self.resizingControl];
    [self bringSubviewToFront:self.deleteControl];
    [self bringSubviewToFront:self.customControl];
 [self bringSubviewToFront:self.editControl];
}



- (void)setFrame:(CGRect)newFrame
{
    [super setFrame:newFrame];
    self.contentView.frame = CGRectInset(self.bounds,
                                         kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2,
                                         kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);

    self.contentView.autoresizingMask = NSViewNotSizable | NSViewHeightSizable ;

    for (NSView *subview in [self.contentView subviews])
    {
        
        [subview setFrame:NSRectFromCGRect(CGRectMake(0, 0,
                                                      self.contentView.frame.size.width,
                                                      self.contentView.frame.size.height))];

        subview.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable ;
    }

    self.borderView.frame = CGRectInset(self.bounds,
                                        kSPUserResizableViewGlobalInset,
                                        kSPUserResizableViewGlobalInset);

    self.resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                           self.bounds.size.height-kZDStickerViewControlSize,
                                           kZDStickerViewControlSize,
                                           kZDStickerViewControlSize);

    self.deleteControl.frame = CGRectMake(0, self.frame.size.height-kZDStickerViewControlSize,
                                          kZDStickerViewControlSize, kZDStickerViewControlSize);

    self.customControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                         0,
                                         kZDStickerViewControlSize,
                                         kZDStickerViewControlSize);
 self.editControl.frame =CGRectMake(0,
                                      0,
                                      kZDStickerViewControlSize,
                                      kZDStickerViewControlSize);

    [self.borderView setNeedsDisplay:YES];
}




- (void)mouseDown:(NSEvent *)event {
    //[super mouseDown:event];
    if (!self.allowDragging)
    {
        return;
    }
    
    [self enableTransluceny:YES];
    
    self.touchStart = event.locationInWindow;
    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidBeginEditing:)])
    {
        [self.stickerViewDelegate stickerViewDidBeginEditing:self];
    }
    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidBeginMoving:)]) {
     [self.stickerViewDelegate stickerViewDidBeginMoving:self];
    }
    [[NSCursor closedHandCursor] set];
}

- (void)mouseUp:(NSEvent *)event {
 //[super mouseUp:event];
    [self enableTransluceny:NO];
    
    // Notify the delegate we've ended our editing session.
    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidEndEditing:)])
    {
        [self.stickerViewDelegate stickerViewDidEndEditing:self];
    }
   [[NSCursor openHandCursor] set];
}


- (void)mouseExited:(NSEvent *)event {
   [super mouseExited:event];
   //[[NSCursor arrowCursor] set];
    [self enableTransluceny:NO];
    
    // Notify the delegate we've ended our editing session.
    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewDidCancelEditing:)])
    {
        [self.stickerViewDelegate stickerViewDidCancelEditing:self];
    }
  [[NSCursor arrowCursor] set];
}



- (void)mouseMoved:(NSEvent *)event {
 [super mouseMoved:event];
}
//-(void)updateTrackingAreas
//{
// [super updateTrackingAreas];
// if(self.trackingArea != nil) {
//  [self removeTrackingArea:self.trackingArea];
//  //[self.trackingArea release];
// }
//
// int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
// self.trackingArea = [ [NSTrackingArea alloc] initWithRect:[self.layer bounds]
//                                              options:opts
//                                                owner:self
//                                             userInfo:nil];
// [self addTrackingArea:self.trackingArea];
//}
- (void)resetCursorRects {
    
    for (int i = 0; i < self.trackingAreas.count; i++){
        [self removeTrackingArea: self.trackingAreas[i]];
       }
    
    
 
       NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                                   options:(NSTrackingCursorUpdate | NSTrackingActiveAlways)
                                                                     owner:self
                                                                  userInfo:nil];
       [self addTrackingArea:trackingArea];
 
       [self discardCursorRects];
 
       CGRect trackingRect = CGRectMake(0, 0, self.layer.frame.size.width, self.layer.frame.size.height);
 
       [self addCursorRect:trackingRect cursor: [NSCursor openHandCursor]];
 

       CGFloat angle = atan2f(self.transform.b, self.transform.a);
       CGAffineTransform t = CGAffineTransformIdentity;
       CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
       t = CGAffineTransformTranslate(t, center.x, center.y);
       t = CGAffineTransformRotate(t, angle );
       t = CGAffineTransformTranslate(t, -center.x, -center.y);
 
 
       CGPoint pointInViewCustomControl = CGPointMake(CGRectGetMidX(self.customControl.frame), CGRectGetMidY(self.customControl.frame));
       CGPoint finalPointCustomControl = CGPointApplyAffineTransform(pointInViewCustomControl,t);
       CGRect newRectCustomControl = CGRectMake(finalPointCustomControl.x - 10, finalPointCustomControl.y - 10, 20, 20);
       if (self.customControl.isHidden) {
        [self addCursorRect:newRectCustomControl cursor: [NSCursor arrowCursor]];
       }else {
        NSCursor *rotateCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"rotate_pointer"] hotSpot:NSMakePoint(7, 7)];
        [self addCursorRect:newRectCustomControl cursor: rotateCursor];
       }
       
 
 
       CGPoint pointInViewResizingControl = CGPointMake(CGRectGetMidX(self.resizingControl.frame), CGRectGetMidY(self.resizingControl.frame));
       CGPoint finalPointResizingControl = CGPointApplyAffineTransform(pointInViewResizingControl,t);
       CGRect newRectResizingControl = CGRectMake(finalPointResizingControl.x - 10, finalPointResizingControl.y - 10, 20, 20);
       if (self.resizingControl.isHidden) {
        [self addCursorRect:newRectResizingControl cursor: [NSCursor arrowCursor]];
       }else {
        NSImage *resizeImage = [NSImage imageNamed:@"resize_pointer"];
        NSCursor *resizeCursor = [[NSCursor alloc] initWithImage:resizeImage hotSpot:NSMakePoint(7, 7)];
        
        [self addCursorRect:newRectResizingControl cursor: resizeCursor];
       }
 
 
 
 
       CGPoint pointInViewDeleteControl = CGPointMake(CGRectGetMidX(self.deleteControl.frame), CGRectGetMidY(self.deleteControl.frame));
       CGPoint finalPointDeleteControl = CGPointApplyAffineTransform(pointInViewDeleteControl,t);
       CGRect newRectDeleteControl = CGRectMake(finalPointDeleteControl.x - 10, finalPointDeleteControl.y - 10, 20, 20);
       if (self.deleteControl.isHidden) {
        [self addCursorRect:newRectDeleteControl cursor: [NSCursor arrowCursor]];
       }else {
        [self addCursorRect:newRectDeleteControl cursor: [NSCursor pointingHandCursor]];
       }
 
 
     CGPoint pointInViewEditControl = CGPointMake(CGRectGetMidX(self.editControl.frame), CGRectGetMidY(self.editControl.frame));
     CGPoint finalPointEditControl = CGPointApplyAffineTransform(pointInViewEditControl,t);
     CGRect newRectEditControl = CGRectMake(finalPointEditControl.x - 10, finalPointEditControl.y - 10, 20, 20);
     if (self.editControl.isHidden) {
      [self addCursorRect:newRectEditControl cursor: [NSCursor arrowCursor]];
     }else {
      [self addCursorRect:newRectEditControl cursor: [NSCursor pointingHandCursor]];
     }
 
 
 
 
}



//- (void)createTrackingArea
//{
// NSTrackingAreaOptions options = NSTrackingInVisibleRect | NSTrackingCursorUpdate;
// NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:self.bounds options:options owner:self userInfo:nil];
// [self addTrackingArea:area];
//}
//
//
//- (void)cursorUpdate:(NSEvent *)event
//{
// [[NSCursor pointingHandCursor] set];
//}



- (void)translateUsingTouchLocation:(CGPoint)touchPoint
{
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - self.touchStart.x,
                                    self.center.y + touchPoint.y - self.touchStart.y);

    if (self.preventsPositionOutsideSuperview)
    {
        // Ensure the translation won't cause the view to move offscreen.
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > (self.superview.bounds.size.width - midPointX + self.bounds.size.width/2))
        {
            newCenter.x = (self.superview.bounds.size.width - midPointX + self.bounds.size.width/2);
        }

        if (newCenter.x < midPointX - self.bounds.size.width/2)
        {
            newCenter.x = midPointX - self.bounds.size.width/2;
        }

        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > (self.superview.bounds.size.height - midPointY + self.bounds.size.height/2))
        {
            newCenter.y = (self.superview.bounds.size.height - midPointY + self.bounds.size.height/2);
        }

        if (newCenter.y < midPointY - self.bounds.size.height/2)
        {
            newCenter.y = midPointY - self.bounds.size.height/2;
        }
    }

    self.center = newCenter;
}

- (void)mouseDragged:(NSEvent *)event {
    if (!self.allowDragging)
    {
        return;
    }
    
    [self enableTransluceny:YES];
    
    CGPoint touchLocation = event.locationInWindow;
    if (CGRectContainsPoint(self.resizingControl.frame, touchLocation))
    {
        return;
    }
    
    CGPoint touch = event.locationInWindow;
    [self translateUsingTouchLocation:touch];
    if ([self.stickerViewDelegate respondsToSelector:@selector(stickerViewMoving:)]) {
     [self.stickerViewDelegate stickerViewMoving:self];
    }
 
    self.touchStart = touch;
    
    [self setCustomTransform:self.transform];
    [[NSCursor closedHandCursor] set];
    
}
- (void)setCenterLocation:(CGPoint)point {
    self.center = point;
    [self setCustomTransform:self.transform];
}

#pragma mark - Property setter and getter

- (void)hideDelHandle
{
    self.deleteControl.hidden = YES;
}



- (void)showDelHandle
{
    self.deleteControl.hidden = NO;
}



- (void)hideEditingHandles
{
    self.resizingControl.hidden = YES;
    self.deleteControl.hidden = YES;
    self.customControl.hidden = YES;
 self.editControl.hidden = YES;
    [self.borderView setHidden:YES];
}



- (void)showEditingHandles
{
    if (NO == self.preventsCustomButton)
    {
        self.customControl.hidden = NO;
    }
    else
    {
        self.customControl.hidden = YES;
    }

    if (NO == self.preventsDeleting)
    {
        self.deleteControl.hidden = NO;
    }
    else
    {
        self.deleteControl.hidden = YES;
    }

    if (NO == self.preventsResizing)
    {
        self.resizingControl.hidden = NO;
    }
    else
    {
        self.resizingControl.hidden = YES;
    }
    if (NO == self.preventsEditing)
    {
     self.editControl.hidden = NO;
    }
    else
    {
     self.editControl.hidden = YES;
    }

    [self.borderView setHidden:NO];
}



- (void)showCustomHandle
{
    self.customControl.hidden = NO;
}



- (void)hideCustomHandle
{
    self.customControl.hidden = YES;
}



- (void)setButton:(ZDStickerViewButton)type image:(NSImage*)image
{
    switch (type)
    {
        case ZDStickerViewButtonResize:
            self.resizingControl.image = image;
            break;
        case ZDStickerViewButtonDel:
            self.deleteControl.image = image;
            break;
        case ZDStickerViewButtonCustom:
            self.customControl.image = image;
            break;
        case ZDStickerViewButtonEdit:
            self.editControl.image = image;
            break;

        default:
            break;
    }
}



- (BOOL)isEditingHandlesHidden
{
    return self.borderView.hidden;
}



- (void)enableTransluceny:(BOOL)state
{
    if (self.translucencySticker == YES)
    {
        if (state == YES)
        {
            self.alphaValue = 0.65;
        }
        else
        {
            self.alphaValue = 1.0;
        }
    }
}
//
//- (NSColor *)borderColor {
//    return self.borderView.borderColor;
//}
//
//- (void)setBorderColor:(NSColor *)borderColor {
//    self.borderView.borderColor = borderColor;
//}
//
//- (CGFloat)borderWidth {
//    return self.borderView.borderWidth;
//}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.borderView.layer.borderWidth = borderWidth;
}








-(void)bringSubviewToFront:(NSView*)view
{
    [view removeFromSuperview];
    [self addSubview:view];
}


-(void)setCustomTransform:(CGAffineTransform)transform {
    CGRect frame = self.layer.frame;
    
    CGPoint center =  CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    self.wantsLayer = true ;
    [self.layer setPosition:center];
    [self.layer setAnchorPoint:CGPointMake(0.5,0.5)];
    [self.layer setAffineTransform:transform];
}

- (void)setTransform:(CGAffineTransform)transform {
     _transform = transform;
     [self setCustomTransform:transform];
 
}



-(double) getDistanceBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {

   CGFloat fx = point2.x - point1.x;
   CGFloat fy = point2.y - point1.y;
 NSLog(@"%f", sqrt(fx * fx + fy * fy));
   return sqrt(fx * fx + fy * fy);
}


- (CGRect) scaleRect:(CGRect)rect wScale:(CGFloat)wScale hScale:(CGFloat)hScale {
 
 return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * wScale,  rect.size.height * hScale);

}



@end


