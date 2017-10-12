//
//  TagModel.h
//  Suibianzou
//
//  Created by 摇果 on 2017/9/19.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TagModel : NSObject

@property (nonatomic, copy) NSString *text;
//距离
@property (nonatomic, assign) CGFloat distance;
//方位角
@property (nonatomic, assign) CGFloat azimuth;

@property (nonatomic, assign) CGFloat lastDirection;

@property (nonatomic, assign) CGFloat width;
//标签
@property (nonatomic, strong) UIView *tagView;
//雷达位置
@property (nonatomic, strong) UIView *azimuthView;

- (instancetype)initWithText:(NSString *)text distance:(CGFloat)distance azimuth:(CGFloat)azimuth width:(CGFloat)width;

@end
