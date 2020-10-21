//
//  ViewController.m
//  VideoZipDemo
//
//  Created by XieHenry on 2020/8/6.
//  Copyright © 2020 XieHenry. All rights reserved.
//

#import "ViewController.h"
#import "ffmpeg.h"
#import <AVFoundation/AVFoundation.h>
#import "GetFilePath.h"



static inline NSString *SandboxCache() {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic,strong) AVPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIButton *paisheButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    paisheButton.frame = CGRectMake(100, 40, 300, 50);
    [paisheButton setTitle:@"拍摄" forState:(UIControlStateNormal)];
    [paisheButton setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [paisheButton addTarget:self action:@selector(addVideo) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:paisheButton];
}



-(void)zipClick :(NSString *)yuanshipinUrl {

    
    NSString *savePathUrl = [SandboxCache() stringByAppendingPathComponent:@"yasuoResult.MP4"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err;
    [fileManager removeItemAtPath:savePathUrl error:&err];
    
    //1.对命令行进行字符串拼接。使用 空格 分割
    NSMutableString *argumentStr = [NSMutableString string];
    //添加视频
    [argumentStr appendString:[NSString stringWithFormat:@"ffmpeg -i %@",yuanshipinUrl]];

    [argumentStr appendString:[NSString stringWithFormat:@" -b:v 2000k -r 25 -s 720*1280 %@",savePathUrl]];
    

    
    /*
    -s 分辨率
    -b:v  输出文件的码率
    -r  设置帧频 缺省25  一般帧率越高，视频画面越流畅。 （可以改，确认非标准桢率会导致音画不同步，所以只能设定为15或者29.97）
    -b 1500 视频数据流量，用-b xxxx的指令则使用固定码率，数字随便改，1500以上没效果；还可以用动态码率如：-qscale 4和-qscale 6，4的质量比6高  码率与体积成正比
    -c:a copy 复制音频码率等信息
    */
    
    
    NSLog(@"打印合成命令：%@",argumentStr);
    
    //2.根据 （空格）将指令分割为指令数组
    NSArray *argv_array = [argumentStr componentsSeparatedByString:@" "]; //分隔符
    
    //3.将OC对象转换为对应的C对象
    int argc = (int)argv_array.count;
    char **arguments = calloc(argc, sizeof(char*));
    
    for (int i=0; i<argc; i++) {
        arguments[i] = (char*)malloc(sizeof(char)*1024);
        strcpy(arguments[i],[[argv_array objectAtIndex:i] UTF8String]);
    }
    
    //4.压缩
    int result =  ffmpeg_main(argc, arguments);
    
    if (result == 0) { //压缩成功
        NSLog(@"压缩成功");
        
        NSLog(@"*********************************");
        NSDictionary *dic =  [self getVideoInfoWithSourcePath:yuanshipinUrl];
        NSLog(@"打印原视频信息：%@",dic);

        
        NSDictionary *dic1 =  [self getVideoInfoWithSourcePath:savePathUrl];
        NSLog(@"打印压缩后的视频信息：%@",dic1);
        NSLog(@"*********************************");
        
        
        
        //1 创建AVPlayerItem
        NSURL *localVideoUrl = [NSURL fileURLWithPath:savePathUrl];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:localVideoUrl];
        
        //2.把AVPlayerItem放在AVPlayer上
        _player = [[AVPlayer alloc]initWithPlayerItem:playerItem];
        
        //3 再把AVPlayer放到 AVPlayerLayer上
        AVPlayerLayer *avplayerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        avplayerLayer.frame = CGRectMake(10, 0, self.view.frame.size.width-20, self.view.frame.size.height);
        //4 最后把 AVPlayerLayer放到self.view.layer上(也就是需要放置的视图的layer层上)
        [self.view.layer addSublayer:avplayerLayer];
        
        
    } else {      //压缩失败
        NSLog(@"压缩失败");
    }
}

/**
 * @method
 *
 * @brief 根据路径获取视频时长和大小
 * @param path       视频路径
 * @return    字典    @"size"－－文件大小   @"duration"－－视频时长
 */
- (NSDictionary *)getVideoInfoWithSourcePath:(NSString *)path{
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    CMTime   time = [asset duration];
    int seconds = ceil(time.value/time.timescale);

    NSInteger   fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;

    return @{@"size" : @(fileSize/1000000),
             @"duration" : @(seconds)};
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_player play];

}


//触发事件：拍照
- (void)addCamera {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES; //可编辑
    //判断是否可以打开照相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //摄像头
        //UIImagePickerControllerSourceTypeSavedPhotosAlbum:相机胶卷
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else { //否则打开照片库
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:picker animated:YES completion:nil];
}


//触发事件：录像
- (void)addVideo {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        picker.videoQuality = UIImagePickerControllerQualityTypeHigh; //录像质量
        picker.videoMaximumDuration = 10.0f; //录像最长时间
        picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", nil];
        
    } else {
        NSLog(@"当前设备不支持录像功能");
    }
    //跳转到拍摄页面
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
//拍摄完成后要执行的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([mediaType isEqualToString:@"public.image"]) {
        //得到照片
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            //图片存入相册
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
        
        NSString *imagePath = [GetFilePath getSavePathWithFileSuffix:@"png"];
        success = [fileManager fileExistsAtPath:imagePath];
        if (success) {
            [fileManager removeItemAtPath:imagePath error:nil];
        }
        
        NSData *imageData = UIImagePNGRepresentation(image);
        [imageData writeToFile:imagePath atomically:YES]; //写入本地
        success = [fileManager fileExistsAtPath:imagePath];
        if (success) {
            NSLog(@"图片写入成功,image路径:%@",imagePath);
        }
    } else if ([mediaType isEqualToString:@"public.movie"]) { //MARK:1.可以使用tmp系统路径   2.也可以自己保存视频操作
        //1.获取视频路径
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];
        NSString *urlStr = [url path];
        [self zipClick:urlStr];
        
        
        //2.保存视频再操作
//        NSString *videoPath = [GetFilePath getSavePathWithFileSuffix:@"mov"];
//        success = [fileManager fileExistsAtPath:videoPath];
//        if (success) {
//            [fileManager removeItemAtPath:videoPath error:nil];
//        }
//
//        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
//        NSData *videlData = [NSData dataWithContentsOfURL:videoURL];
//        [videlData writeToFile:videoPath atomically:YES]; //写入本地
//        //存储数据
//        success = [fileManager fileExistsAtPath:videoPath];
//        if (success) {
//
//            [self zipClick:videoPath];
//        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}





//进入拍摄页面点击取消按钮
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
