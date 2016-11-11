//
//  AlbumViewController.swift
//  erweimaTool
//
//  Created by siecom-mac on 16/9/22.
//  Copyright © 2016年 siecom-mac. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class AlbumViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func fromAlburm(sender: AnyObject) {
        // 打开相册
        // 1.判断是否能够打开相册
        /*
         case PhotoLibrary  相册
         case Camera 相机
         case SavedPhotosAlbum 图片库
         */
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        {
            return
        }

        // 2.创建相册控制器
        let imagePickerVC = UIImagePickerController()

        imagePickerVC.delegate = self // 代理方法中识别照片中的二维码
        // 3.弹出相册控制器
        presentViewController(imagePickerVC, animated: true, completion: nil)

    }
    // 未过时的方法
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        // 1.取出选中的图片
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else
        {
            return
        }

        guard let ciImage = CIImage(image: image) else
        {
            return
        }

        // 2.从选中的图片中读取二维码数据
        // 2.1创建一个探测器
        // CIDetectorTypeFace -- 探测器还可以搞人脸识别
        let detector = CIDetector(ofType:CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
        // 2.2利用探测器探测数据
        let results = detector.featuresInImage(ciImage)
        // 2.3取出探测到的数据
        for result in results
        {
            //ChaosLog((result as! CIQRCodeFeature).messageString)
            print(result);
        }

        // 注意: 如果实现了该方法, 当选中一张图片时系统就不会自动关闭相册控制器
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
