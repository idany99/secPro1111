//
//  ViewController.m
//  erweimaTool
//
//  Created by siecom-mac on 16/9/22.
//  Copyright © 2016年 siecom-mac. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

static const char *kScanQRCodeQueueName = "ScanQRCodeQueue";
@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *fromAlbum;

@property (strong, nonatomic) IBOutlet UIView *scanFrameView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *lightButton;
- (IBAction)lightClick:(id)sender;



@property (strong, nonatomic) IBOutlet UIButton *button;
- (IBAction)buttonClick:(id)sender;

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL lastResut;
@property (nonatomic)NSString *resultString;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [_button setTitle:@"开始" forState:UIControlStateNormal];
    //NSMutableDictionary *textAttrs=[NSMutableDictionary dictionary];
    //textAttrs[NSForegroundColorAttributeName]=[UIColor orangeColor];
    //[_lightButton setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    _lightButton.title = @"打开照明";
    //[_lightButton setTitle:@"打开照明" forState:UIControlStateNormal];
    _lastResut = YES;
}

- (void)dealloc
{
    [self stopReading];
}
- (BOOL)startReading
{
    [_button setTitle:@"停止" forState:UIControlStateNormal];
    // 获取 AVCaptureDevice 实例
    NSError * error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 初始化输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    // 创建会话
    _captureSession = [[AVCaptureSession alloc] init];
    // 添加输入流
    [_captureSession addInput:input];
    // 初始化输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // 添加输出流
    [_captureSession addOutput:captureMetadataOutput];

    // 创建dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create(kScanQRCodeQueueName, NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    // 设置元数据类型 AVMetadataObjectTypeQRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];

    // 创建输出对象
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_scanFrameView.layer.bounds];
    [_scanFrameView.layer addSublayer:_videoPreviewLayer];
    // 开始会话
    [_captureSession startRunning];

    return YES;
}

- (void)stopReading
{
    [_button setTitle:@"开始" forState:UIControlStateNormal];
    // 停止会话
    [_captureSession stopRunning];
    _captureSession = nil;
}

- (void)reportScanResult:(NSString *)result
{
    [self stopReading];
    if (!_lastResut) {
        return;
    }
    _lastResut = NO;
    //_resultString = result;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"二维码扫描"
                                                    message:result
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles: @"复制",@"在浏览器",nil];
    [alert show];
    // 以及处理了结果，下次扫描
    _lastResut = YES;
}

- (void)systemLightSwitch:(BOOL)open
{
    if (open) {
        //[_lightButton setTitle:@"关闭照明" forState:UIControlStateNormal];
        _lightButton.title = @"关闭照明";
    } else {
        _lightButton.title = @"打开照明";
        //[_lightButton setTitle:@"打开照明" forState:UIControlStateNormal];
    }
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (open) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}

#pragma AVCaptureMetadataOutputObjectsDelegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result;
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            result = metadataObj.stringValue;
        } else {
            NSLog(@"不是二维码");
        }
        [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:result waitUntilDone:NO];
    }
}
- (IBAction)buttonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:@"开始"]) {
        [self startReading];
    } else {
        [self stopReading];
    }
}

- (IBAction)lightClick:(id)sender {
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    if ([button.title isEqualToString:@"打开照明"]) {
        [self systemLightSwitch:YES];
    } else {
        [self systemLightSwitch:NO];
    }

}
//从相册中获取

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%ld",buttonIndex);
    switch (buttonIndex) {
        case 1:
        {
            //fuzhi
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = alertView.message;
        }
            break;
        case 2:
        {
            //dakai
            if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:alertView.message]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alertView.message]];
            }
        }
            break;

        default:
            break;
    }
}
@end
