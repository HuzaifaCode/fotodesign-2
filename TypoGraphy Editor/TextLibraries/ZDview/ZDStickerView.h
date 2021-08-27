//
// ZDStickerView.h
//
// Created by Seonghyun Kim on 5/29/13.
// Copyright (c) 2013 scipi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZDAttributes.h"

typedef NS_ENUM(NSUInteger, ZDStickerViewButton) {
    ZDStickerViewButtonNull,
    ZDStickerViewButtonDel,
    ZDStickerViewButtonResize,
    ZDStickerViewButtonCustom,
    ZDStickerViewButtonEdit,
    ZDStickerViewButtonMax
};
typedef NS_ENUM(NSUInteger, ZDStickerViewType) {
    ZDStickerViewTypeNone,
    ZDStickerViewTypeText,
    ZDStickerViewTypeImage
};



@protocol ZDStickerViewDelegate;


@interface ZDStickerView : NSView

@property (nonatomic, strong) NSView *contentView;

@property (nonatomic) BOOL preventsPositionOutsideSuperview;    // default = YES
@property (nonatomic) BOOL preventsResizing;                    // default = NO
@property (nonatomic) BOOL preventsDeleting;                    // default = NO
@property (nonatomic) BOOL preventsCustomButton;                // default = YES
@property (nonatomic) BOOL translucencySticker;                 // default = YES
@property (nonatomic) BOOL preventsEditing;                    // default = YES
/// Allows user to zoom the sticker by pinching on the sticker view. Defaults to true.
@property (nonatomic) BOOL allowPinchToZoom;
/// Allows the user to rotate the sticker by using 2 finger rotation on the view. Defaults to true.
@property (nonatomic) BOOL allowRotationGesture;
/// Allows the user drag the sticker view around.
@property (nonatomic) BOOL allowDragging;
/// Defines the color of the border drawn around the content view. Defaults to gray.
@property (nonatomic) NSColor *borderColor;
/// Defines the width of the border drawn around the sticker view.
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;
@property (nonatomic) CGAffineTransform transform;
@property (nonatomic) ZDAttributes* attributes;


@property (weak, nonatomic) id <ZDStickerViewDelegate> stickerViewDelegate;

- (void)hideDelHandle;
- (void)showDelHandle;
- (void)hideEditingHandles;
- (void)showEditingHandles;
- (void)showCustomHandle;
- (void)hideCustomHandle;
- (void)setButton:(ZDStickerViewButton)type image:(NSImage *)image;
- (BOOL)isEditingHandlesHidden;
- (void)setCenterLocation:(CGPoint)point;
- (void)resizeStickerViewFrame:(NSRect)frame;

@end


@protocol ZDStickerViewDelegate <NSObject>
@required
@optional
- (void)stickerViewDidBeginEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidEndEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidCancelEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidClose:(ZDStickerView *)sticker;
- (void)stickerViewDidResize:(ZDStickerView *)sticker;
- (void)stickerViewDidBeginRotating:(ZDStickerView *)sticker;
- (void)stickerViewDidBeginResizing:(ZDStickerView *)sticker;
- (void)stickerViewDidBeginMoving:(ZDStickerView *)sticker;
- (void)stickerViewMoving:(ZDStickerView *)sticker;
#ifdef ZDSTICKERVIEW_LONGPRESS
- (void)stickerViewDidLongPressed:(ZDStickerView *)sticker;
#endif
- (void)stickerViewDidCustomButtonTap:(ZDStickerView *)sticker;
- (void)stickerViewDidEditButtonTap:(ZDStickerView *)sticker;
@end
