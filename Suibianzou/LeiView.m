//
//  LeiView.m
//  Suibianzou
//
//  Created by 摇果 on 2017/9/15.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "LeiView.h"

#define degreesToRadians(x) (M_PI*(x)/180.0)
@implementation LeiView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:frame.size.width/2.0];
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;//中间镂空的关键点 填充规则
        fillLayer.fillColor = [UIColor blackColor].CGColor;
        fillLayer.opacity = 0.6;
        [self.layer addSublayer:fillLayer];
        
        [self aa];
    }
    return self;
}

- (void)aa {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.frame cornerRadius:0];
    NSArray *colors = @[
                        [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:0.8],
                        [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:0.8],
                        [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:0.8]
                        ];
    
    NSInteger radius = self.frame.size.width/6.0;
    NSInteger increment = self.frame.size.width/6.0;
    
    for (int i = 0; i < colors.count; i++) {
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                                                            radius:radius
                                                        startAngle:degreesToRadians(0)
                                                          endAngle:degreesToRadians(360)
                                                         clockwise:YES];
        [path appendPath:bezierPath];
        [path setUsesEvenOddFillRule:YES];
        
        CAShapeLayer *shapLayer = [CAShapeLayer layer];
        shapLayer.lineWidth = 0.5;
        shapLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapLayer.fillColor = [UIColor clearColor].CGColor;
        shapLayer.path = bezierPath.CGPath;
        [self.layer addSublayer:shapLayer];

        radius += increment;
    }
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGPoint point0 = CGPointMake(self.frame.size.width/2.0, 0);
    CGPoint point1 = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    [bezierPath moveToPoint:point0];
    [bezierPath addLineToPoint:point1];
    [bezierPath closePath];
    [path appendPath:bezierPath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *shapLayer = [CAShapeLayer layer];
    shapLayer.lineWidth = 1;
    shapLayer.strokeColor = [UIColor greenColor].CGColor;
    shapLayer.fillColor = [UIColor clearColor].CGColor;
    shapLayer.path = bezierPath.CGPath;
    [self.layer addSublayer:shapLayer];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
