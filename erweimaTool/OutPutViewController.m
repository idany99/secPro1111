//
//  OutPutViewController.m
//  erweimaTool
//
//  Created by siecom-mac on 16/9/22.
//  Copyright © 2016年 siecom-mac. All rights reserved.
//

#import "OutPutViewController.h"

@interface OutPutViewController ()
@property (strong, nonatomic) IBOutlet UITextField *urlFiled;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
- (IBAction)saveToAlburmAction:(id)sender;

- (IBAction)outputAction:(id)sender;
@end

@implementation OutPutViewController
{
    UIImage *_myImage;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _myImage = [[UIImage alloc]init];
}

- (IBAction)saveToAlburmAction:(id)sender {
    if (_myImage) {
        //UIImage *image = [UIImage imageNamed:@"liantu-2.png"];
        
        [self writeToAlurm:_myImage];
    }
}
//输出二维码清晰的方法
-(void)outPutErWeiMaQing:(NSString*)string{
    // 1.创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.恢复默认
    [filter setDefaults];
    // 3.给过滤器添加数据(正则表达式/账号和密码)
    NSString *dataString = string;
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    // 5.将CIImage转换成UIImage，并放大显示

    _myImage = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:200];
    _imgView.image = _myImage;
}
/**
 * 根据CIImage生成指定大小的UIImage
 *
 * @param image CIImage
 * @param size 图片宽度
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}
- (IBAction)outputAction:(id)sender {
    if (_urlFiled.text) {
        [_urlFiled resignFirstResponder];
        [self outPutErWeiMaQing:_urlFiled.text];
    }else{
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"提示" message:@"输入为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}
-(void)outPutErWeiMa:(NSString*)string{
    // 1.实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];

    // 2.恢复滤镜的默认属性 (因为滤镜有可能保存上一次的属性)
    [filter setDefaults];

    // 3.将字符串转换成NSdata
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

    // 4.通过KVO设置滤镜, 传入data, 将来滤镜就知道要通过传入的数据生成二维码
    [filter setValue:data forKey:@"inputMessage"];

    // 5.生成二维码
    CIImage *outputImage = [filter outputImage];

    UIImage *image = [UIImage imageWithCIImage:outputImage];
    _imgView.image = image;
    _myImage = image;
}
-(void)writeToAlurm:(UIImage *)image{
    //UIImage *savedImage = [UIImage imageNamed:@"liantu-2.png"];
    [self saveImageToPhotos:image];
}
//实现该方法
- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    //因为需要知道该操作的完成情况，即保存成功与否，所以此处需要一个回调方法image:didFinishSavingWithError:contextInfo:
}
//回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if(error != NULL){
        //msg = @"保存图片失败" ;
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"保存结果" message:@"保存失败!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"保存结果" message:@"保存成功!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }

    //UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    //[self showViewController:alert sender:nil];
}
//注iOS9弃用了UIAlertView类。
@end
