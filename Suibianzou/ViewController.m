//
//  ViewController.m
//  Suibianzou
//
//  Created by 摇果 on 2017/9/15.
//  Copyright © 2017年 摇果. All rights reserved.
//

#import "ViewController.h"
#import "LeiView.h"
#import "TagModel.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

#define toDeg(X) (X*180.0/M_PI)
#define degreesToRadians(x) (M_PI*(x)/180.0)
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
@interface ViewController ()<CLLocationManagerDelegate>
{
    CGFloat _direction;
    CGFloat _zTheta;
    BOOL _isCreate;
}
/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

@property (nonatomic, strong) LeiView *leiView;

@property (nonatomic, strong) CMMotionManager *manager;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, assign) CGFloat longitude;

@property (nonatomic, assign) CGFloat latitude;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) NSMutableArray *tagArray;

@property (nonatomic, strong) NSMutableArray *currentArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initAVCaptureSession];

    _backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _backView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_backView];

    TagModel *model0 = [[TagModel alloc] initWithText:@"dhhdajdkahlahdkaja" distance:50.0 azimuth:20.0 width:150.0];
    [self.backView addSubview:model0.tagView];
    [self.tagArray addObject:model0];

    TagModel *model1 = [[TagModel alloc] initWithText:@"进口顶级阿卡的卡了；蒂法激动哦痘痘快点开大了点" distance:20.0 azimuth:50.0 width:200.0];
    [self.backView addSubview:model1.tagView];
    [self.tagArray addObject:model1];
    
    TagModel *model2 = [[TagModel alloc] initWithText:@"蒂法激动哦痘痘快点开大了点" distance:30.0 azimuth:100.0 width:120.0];
    [self.backView addSubview:model2.tagView];
    [self.tagArray addObject:model2];
    
    TagModel *model3 = [[TagModel alloc] initWithText:@"12312312312" distance:40.0 azimuth:170.0 width:70.0];
    [self.backView addSubview:model3.tagView];
    [self.tagArray addObject:model3];
    
    TagModel *model4 = [[TagModel alloc] initWithText:@"SHSKDA点开大了点" distance:40.0 azimuth:240.0 width:100.0];
    [self.backView addSubview:model4.tagView];
    [self.tagArray addObject:model4];
 
    TagModel *model5 = [[TagModel alloc] initWithText:@"进口顶级阿卡点开大了点" distance:50.0 azimuth:300.0 width:200.0];
    [self.backView addSubview:model5.tagView];
    [self.tagArray addObject:model5];

    TagModel *model6 = [[TagModel alloc] initWithText:@"123SFSG号的大红包" distance:55 azimuth:270.0 width:160.0];
    [self.backView addSubview:model6.tagView];
    [self.tagArray addObject:model6];
    
    TagModel *model7 = [[TagModel alloc] initWithText:@"123红包！！！" distance:55 azimuth:270.0 width:160.0];
    [self.backView addSubview:model7.tagView];
    [self.tagArray addObject:model7];
 
    _leiView = [[LeiView alloc] initWithFrame:CGRectMake(10, 20, 120, 120)];
    [self.view addSubview:_leiView];
    
    [self drawRect:CGRectMake(0, 0, 120, 120)];
    
    self.locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 100.0f;
        if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
    }

    [self.session startRunning];
    
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    _manager = manager;
    
    [self useGyroPush];
}

#pragma mark - 陀螺仪
- (void)useGyroPush {
    if (![_manager isDeviceMotionActive] && [_manager isDeviceMotionAvailable]) {
        //设置采样间隔
        _manager.deviceMotionUpdateInterval = 0.001;
         NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [_manager startDeviceMotionUpdatesToQueue:queue
                                  withHandler:^(CMDeviceMotion * _Nullable motion,
                                                NSError * _Nullable error) {
                                      
                                      double gravityX = motion.gravity.x;
                                      double gravityY = motion.gravity.y;
                                      double gravityZ = motion.gravity.z;
                                      if (gravityY<=0 && gravityY>=-1) {
                                          //获取手机的倾斜角度(zTheta是手机与水平面的夹角， xyTheta是手机绕自身旋转的角度)：
                                          _zTheta = atan2(gravityZ,sqrtf(gravityX*gravityX+gravityY*gravityY))/M_PI*180.0;
                                          _zTheta += 90.0;
                                          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                              if (self.currentArr.count > 0) {
                                                  [self updataPoint];
                                              }
                                          }];
                                      }
                                  }];
    }
}

- (void)updataPoint {
    
    for (TagModel *model in self.currentArr) {
        if (_zTheta > 50.0 && _zTheta < 110.0) {
            model.tagView.hidden = NO;
            CGFloat height = (ScreenHeight+model.width/2.0)/60.0;
            CGFloat y = _zTheta - 50.0;
            CGFloat pointY = y*height;
            CGPoint center = model.tagView.center;
            center.y = pointY-(model.width/2.0)/2.0;
            model.tagView.center = center;
        }else{
            model.tagView.hidden = YES;
            CGPoint center = model.tagView.center;
            model.tagView.center = CGPointMake(center.x, -100);
        }
        
    }
}

#pragma mark - 定位成功
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [_locationManager stopUpdatingLocation];
    // 1.获取用户位置的对象
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    _longitude = coordinate.longitude;
    _latitude = coordinate.latitude;
//    CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake(_longitude-50, _latitude);
//    CGFloat s = [self DistanceFromCoordinates:coordinate other:coordinate1];
//    _z = [self getHeadingForDirectionFromCoordinate:coordinate toCoordinate:coordinate1];
    if (_isCreate == NO) {
        _isCreate = YES;
        for (TagModel *model in self.tagArray) {
            [self createTagView:model withDistance:model.distance];
        }
        
        // 判断两个坐标是有没有重和部分，有的话移除其中一个（这里移除了后一个）
        for (int i = 0; i < self.tagArray.count - 1; i++) {
            UIView *view0 = ((TagModel *)self.tagArray[i]).azimuthView;
            for (int j = i + 1; j < self.tagArray.count; j++) {
                UIView *view1 = ((TagModel *)self.tagArray[j]).azimuthView;
                if (CGRectIntersectsRect(view0.frame, view1.frame)) {
                    [((TagModel *)self.tagArray[j]).tagView removeFromSuperview];
                    [((TagModel *)self.tagArray[j]).azimuthView removeFromSuperview];
                    [self.tagArray removeObjectAtIndex:j];
                }
            }
        }
    }
}

- (void)createTagView:(TagModel *)model withDistance:(CGFloat)distance {
    CGFloat pointx;
    CGFloat pointy;
    if (model.azimuth > 0 && model.azimuth< 90) {
        CGFloat x = sin(degreesToRadians(model.azimuth))*distance;
        CGFloat y = cos(degreesToRadians(model.azimuth))*distance;
        pointx = 60+fabs(x);
        pointy = 60-fabs(y);
    }else if (model.azimuth > 90 && model.azimuth <= 180) {
        CGFloat x = sin(degreesToRadians(180-model.azimuth))*distance;
        CGFloat y = cos(degreesToRadians(180-model.azimuth))*distance;
        pointx = 60+fabs(x);
        pointy = 60+fabs(y);
    }else if (model.azimuth > 180 && model.azimuth <= 270) {
        CGFloat x = sin(degreesToRadians(model.azimuth-180))*distance;
        CGFloat y = cos(degreesToRadians(model.azimuth-180))*distance;
        pointx = 60-fabs(x);
        pointy = 60+fabs(y);
    }else{
        CGFloat x = sin(degreesToRadians(360-model.azimuth))*distance;
        CGFloat y = cos(degreesToRadians(360-model.azimuth))*distance;
        pointx = 60-fabs(x);
        pointy = 60-fabs(y);
    }

    model.azimuthView.center = CGPointMake(pointx, pointy);
    [_leiView addSubview:model.azimuthView];
}

#pragma mark - 定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        NSLog(@"location error: %ld", error.code);
    }
}

#pragma mark - 两点的经纬度计算距离
-(float) DistanceFromCoordinates:(CLLocationCoordinate2D) myDot other:(CLLocationCoordinate2D)otherDot {
    double EARTH_RADIUS = 6378137.0;
    
    double radLat1 = (myDot.latitude * M_PI / 180.0);
    double radLat2 = (otherDot.latitude * M_PI / 180.0);
    double a = radLat1 - radLat2;
    double b = (myDot.longitude - otherDot.longitude) * M_PI / 180.0;
    double s = 22 * asin(sqrt(pow(sin(a / 2), 2)
                              + cos(radLat1) * cos(radLat2)
                              * pow(sin(b / 2), 2)));
    s = s * EARTH_RADIUS;
    s = round(s * 10000) / 10000;
    
    return s;
}
#pragma mark - 两点的经纬度计算方位角
- (CGFloat)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc {
    CGFloat fLat = degreesToRadians(fromLoc.latitude);
    CGFloat fLng = degreesToRadians(fromLoc.longitude);
    CGFloat tLat = degreesToRadians(toLoc.latitude);
    CGFloat tLng = degreesToRadians(toLoc.longitude);
    
    CGFloat degree = toDeg(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    if (degree >= 0) {
        return degree;
    }else{
        return 360+degree;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(nonnull CLHeading *)newHeading {

    _direction = newHeading.trueHeading;
//    NSLog(@"%f", _direction);
    float headingAngle = -degreesToRadians(_direction);
    _leiView.transform = CGAffineTransformMakeRotation(headingAngle);
    
    for (TagModel *model in self.tagArray) {
        [self calculateHidden:model];
    }
}

- (void)calculateHidden:(TagModel *)model {
    if (_direction > 0 && _direction < 30) {
        if (model.azimuth > 330+_direction || model.azimuth < _direction+30) {
            [self updataPoint:model];
            [self.currentArr addObject:model];
        }else{
            model.tagView.hidden = YES;
            model.lastDirection = _direction;
            [self.currentArr removeObject:model];
        }
    }else if (_direction >= 30 && _direction < 330) {
        if (model.azimuth > (_direction-30) && model.azimuth < (_direction+30)) {
            [self updataPoint:model];
            [self.currentArr addObject:model];
        }else{
            model.tagView.hidden = YES;
            model.lastDirection = _direction;
            [self.currentArr removeObject:model];
        }
    }else{
        if (model.azimuth < _direction-330 || model.azimuth > _direction-30) {
            [self updataPoint:model];
            [self.currentArr addObject:model];
            [self.currentArr removeObject:model];
        }else{
            model.tagView.hidden = YES;
            model.lastDirection = _direction;
            [self.currentArr removeObject:model];
        }
    }
}

- (void)updataPoint:(TagModel *)model {
    model.tagView.hidden = NO;
    if (model.azimuth >= 0 && model.azimuth < 30) {
        CGFloat dir = _direction - model.lastDirection;
        if (dir > 0) {
            model.lastDirection = -1;
            CGFloat width = (ScreenWidth+model.width)/60.0;
            CGFloat baseX = 360-fabs(model.azimuth-30);
            CGFloat x;
            if (_direction >= baseX) {
                x = _direction-baseX;
            }else{
                x = (360-baseX)+_direction;
            }
            CGFloat pointX = x*width-(model.width/2.0);
            [self rightToLeftAnimation3D:pointX withTagModel:model];
        }else{
            model.lastDirection = 361;
            CGFloat width = (ScreenWidth+model.width)/60.0;
            CGFloat baseX = model.azimuth+30;
            CGFloat x;
            if (_direction > baseX) {
                x = baseX+(360-_direction);
            }else{
                x = baseX-_direction;
            }
            CGFloat pointX = x*width-(model.width/2.0);
            [self leftToRightAnimation3D:pointX withTagModel:model];
        }
    }else if (model.azimuth >= 30 && model.azimuth < 330) {
        CGFloat dir = _direction - model.lastDirection;
        if (dir > 0) {
            CGFloat width = (ScreenWidth+model.width)/60.0;
            CGFloat baseX = 30+(model.azimuth-60);
            CGFloat x = _direction-baseX;
            CGFloat pointX = x*width-(model.width/2.0);
            [self rightToLeftAnimation3D:pointX withTagModel:model];
        }else{
            CGFloat width = (ScreenWidth+model.width)/60.0;
            CGFloat baseX = 30+model.azimuth;
            CGFloat x = baseX-_direction;
            CGFloat pointX = x*width-(model.width/2.0);
            [self leftToRightAnimation3D:pointX withTagModel:model];
        }
    }else{
        CGFloat dir = _direction - model.lastDirection;
        if (dir > 0) {
            model.lastDirection = -1;
            CGFloat width = (ScreenWidth+model.width)/60.0;
            CGFloat baseX = model.azimuth-30;
            CGFloat x;
            if (_direction > baseX) {
                x = _direction-baseX;
            }else{
                x = 360-baseX+_direction;
            }
            CGFloat pointX = x*width-(model.width/2.0);
            [self rightToLeftAnimation3D:pointX withTagModel:model];
        }else{
            model.lastDirection = 361;
            CGFloat width = (ScreenWidth+model.width)/60.0;
            CGFloat baseX = 30-fabs(model.azimuth-360);
            CGFloat x;
            if (_direction < baseX) {
                x = baseX-_direction;
            }else{
                x = baseX+360-_direction;
            }
            CGFloat pointX = x*width-(model.width/2.0);
            [self leftToRightAnimation3D:pointX withTagModel:model];
        }
    }
}

#pragma mark - 3D动画
// 右进左出
- (void)rightToLeftAnimation3D:(CGFloat)pointX withTagModel:(TagModel *)model {
    CGPoint center = model.tagView.center;
    center.x = ScreenWidth-pointX;
    model.tagView.center = center;
    if (pointX < (model.width/2.0)) {
        CGFloat tx = 60-((60/model.width)*(pointX+(model.width/2.0)));
        CGFloat tz = 30-((30/model.width)*(pointX+(model.width/2.0)));
        CATransform3D transForm1 = CATransform3DIdentity;
        transForm1.m34 = -1.0 / 500.0;
        transForm1 = CATransform3DRotate(transForm1, degreesToRadians(-tz), 0, 0, 1);
        transForm1 = CATransform3DRotate(transForm1, degreesToRadians(-tx), 1, 0, 0);
        model.tagView.layer.transform = transForm1;
    }else if (pointX > ScreenWidth-(model.width/2.0)) {
        CGFloat tx = 60-((60/model.width)*(ScreenWidth-pointX+(model.width/2.0)));
        CGFloat tz = 30-((30/model.width)*(ScreenWidth-pointX+(model.width/2.0)));
        CATransform3D transForm1 = CATransform3DIdentity;
        transForm1.m34 = -1.0 / 500.0;
        transForm1 = CATransform3DRotate(transForm1, degreesToRadians(tz), 0, 0, 1);
        transForm1 = CATransform3DRotate(transForm1, degreesToRadians(tx), 1, 0, 0);
        model.tagView.layer.transform = transForm1;
    }else{}
}
//左进右出
- (void)leftToRightAnimation3D:(CGFloat)pointX withTagModel:(TagModel *)model {
    CGPoint center = model.tagView.center;
    center.x = pointX;
    model.tagView.center = center;
    if (pointX < (model.width/2.0)) {
        CGFloat tx = 60-((60/model.width)*(pointX+(model.width/2.0)));
        CGFloat tz = 30-((30/model.width)*(pointX+(model.width/2.0)));
        CATransform3D transForm1 = CATransform3DIdentity;
        transForm1.m34 = -1.0 / 500.0;
        transForm1 = CATransform3DRotate(transForm1, degreesToRadians(tz), 0, 0, 1);
        transForm1 = CATransform3DRotate(transForm1, degreesToRadians(tx), 1, 0, 0);
        model.tagView.layer.transform = transForm1;
    }else if (pointX > ScreenWidth-(model.width/2.0)) {
        CGFloat tx = 60-((60/model.width)*(ScreenWidth-pointX+(model.width/2.0)));
        CGFloat tz = 30-((30/model.width)*(ScreenWidth-pointX+(model.width/2.0)));
        CATransform3D transForm1 = CATransform3DIdentity;
        transForm1.m34 = -1.0 / 500.0;
        transForm1 = CATransform3DRotate(transForm1, degreesToRadians(-tz), 0, 0, 1);
        transForm1 = CATransform3DRotate(transForm1, degreesToRadians(-tx), 1, 0, 0);
        model.tagView.layer.transform = transForm1;
    }else{ }
}

- (void)initAVCaptureSession {
    
    self.session = [[AVCaptureSession alloc] init];
    NSError *error;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    self.previewLayer.frame = CGRectMake(0, 0,ScreenWidth, ScreenHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResize;
    self.view.layer.masksToBounds = YES;
    [self.view.layer addSublayer:self.previewLayer];
}

- (void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(10+60, 20+60);
    float angle_start1 = degreesToRadians(240);
    float angle_end1 = degreesToRadians(300);

    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [path1 moveToPoint:center];
    [path1 addArcWithCenter:center radius:60 startAngle:angle_start1 endAngle:angle_end1 clockwise:YES];
    CAShapeLayer *shaplayer1 = [CAShapeLayer layer];
    [shaplayer1 setPath:path1.CGPath];
    [shaplayer1 setFillColor:[UIColor yellowColor].CGColor];
    [shaplayer1 setZPosition:center.x];
    shaplayer1.opacity = 0.6;
    [self.view.layer addSublayer:shaplayer1];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 懒加载
- (NSMutableArray *)tagArray {
    if (!_tagArray) {
        _tagArray = [NSMutableArray array];
    }
    return _tagArray;
}

- (NSMutableArray *)currentArr {
    if (!_currentArr) {
        _currentArr = [NSMutableArray array];
    }
    return _currentArr;
}

@end
