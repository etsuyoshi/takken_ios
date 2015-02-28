//
//  ETCSVModel.h
//  GetLicense
//
//  Created by EndoTsuyoshi on 2015/01/14.
//  Copyright (c) 2015年 com.endo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETCSVModel : NSObject

@property (nonatomic, strong) NSArray *arrQuestionModels;//questionModel要素とする配列(2次元配列)
@property (nonatomic, strong) NSArray *arrLabels;//ラベルを何かに使う時→特に現状必要不可欠ではないので削除可能
-(id)initWithCSVName:(NSString *)strFileName
      includingLabel:(BOOL)isFileIncludingLabel;
-(NSArray *)getArrCategories;
-(NSArray *)getArrLimitedRangeWithSect:(NSString *)strSect;
@end
