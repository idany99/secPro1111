//
//  AlBMViewController.m
//  erweimaTool
//
//  Created by siecom-mac on 16/9/22.
//  Copyright © 2016年 siecom-mac. All rights reserved.
//

#import "AlBMViewController.h"

@interface AlBMViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>
- (IBAction)fromAluburmAction:(id)sender;
- (IBAction)saveImageAction:(id)sender;

@end

@implementation AlBMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)fromAluburmAction:(id)sender {
    //调用相册
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
//选中图片的回调
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *content = @"" ;
    //取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(pickImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];

    //创建探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    NSArray *feature = [detector featuresInImage:ciImage];

    if (feature.count==0) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"检测结果" message:@"检测失败或者图片不是二维码原图!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        //取出探测到的数据
        for (CIQRCodeFeature *result in feature) {
            content = result.messageString;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"二维码扫描"
                                                            message:content
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles: @"复制",@"在浏览器",nil];
            [alert show];
        }
        
        //进行处理(音效、网址分析、页面跳转等)
    }


}
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
