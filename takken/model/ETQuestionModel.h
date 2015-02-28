//
//  ETQuestionModel.h
//  GetLicense
//
//  Created by EndoTsuyoshi on 2015/01/14.
//  Copyright (c) 2015年 com.endo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETQuestionModel : NSObject

@property (nonatomic ,strong) NSString *strSector;
@property (nonatomic ,strong) NSString *strNo;
@property (nonatomic, strong) NSString *strCategory;
@property (nonatomic ,strong) NSString *strQuestion;
@property (nonatomic ,strong) NSString *strAnswerNo;
@property (nonatomic ,strong) NSString *strAnswerText;
@property (nonatomic ,strong) NSString *strComment;

@property (nonatomic, strong) NSString *strOther;

//-(void)initWithArray:(NSArray *)arrArg;
-(id)initWithArray:(NSArray *)arrArg;

@end
