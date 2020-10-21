//
//  GetFilePath.m
//  VideoZipDemo
//
//  Created by admin on 2020/8/6.
//  Copyright © 2020 admin. All rights reserved.
//


#import "GetFilePath.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@implementation GetFilePath

+ (NSString *)getSavePathWithFileSuffix:(NSString *)suffix
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    
    NSDate *date = [NSDate date];
    //获取当前时间
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *curretDateAndTime = [dateFormat stringFromDate:date];
    //命名文件
    NSString *fileName = [NSString stringWithFormat:@"%@.%@",curretDateAndTime,suffix];
    //指定文件存储路径
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    
    return filePath;
}



@end
