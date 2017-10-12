//
//  TagModel.m
//  Suibianzou
//
//  Created by 摇果 on 2017/9/19.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "TagModel.h"

@implementation TagModel

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithText:(NSString *)text distance:(CGFloat)distance azimuth:(CGFloat)azimuth width:(CGFloat)width {
    self = [self init];
    if (self) {
        self.text = text;
        self.distance = distance;
        self.azimuth = azimuth;
        self.width = width;
        [self createTagView];
    }
    return self;
}

- (void)createTagView {
    UILabel *logoView = [[UILabel alloc] initWithFrame:CGRectMake(0, -100, self.width, 40)];
    logoView.backgroundColor = [UIColor blueColor];
    logoView.textAlignment = NSTextAlignmentCenter;
    logoView.text = self.text;
    logoView.hidden = YES;
    self.tagView = logoView;
    
    UIView *azimuthView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
    azimuthView.layer.cornerRadius = 2;
    azimuthView.backgroundColor = [UIColor redColor];
    self.azimuthView = azimuthView;
}

@end
