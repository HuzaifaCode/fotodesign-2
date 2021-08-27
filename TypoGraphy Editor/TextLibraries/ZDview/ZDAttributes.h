//
//  ZDAttributes.h
//  Quote Maker - Asif Nadeem
//
//  Created by Asif Nadeem on 03/08/2019.
//  Copyright © 2019 Asif Nadeem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZDAttributes : NSObject


@property (nonatomic) float shapeOpacity;
@property (nonatomic) NSColor* pathFillColor;
@property (nonatomic) NSColor* pathStrokeColor;
@property (nonatomic) NSColor* shadowColor;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) CGFloat shadowRadius;
@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic) float shadowOpacity;
@property (nonatomic) NSArray* lineDashedPattern;
@property (nonatomic) BOOL isBorderActive;
@property (nonatomic) BOOL isShadowActive;
@end

NS_ASSUME_NONNULL_END
