//
//  GetFilePath.h
//  VideoZipDemo
//
//  Created by admin on 2020/8/6.
//  Copyright © 2020 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetFilePath : NSObject
//获取要保存的本地文件路径
+ (NSString *)getSavePathWithFileSuffix:(NSString *)suffix;

@end

NS_ASSUME_NONNULL_END
