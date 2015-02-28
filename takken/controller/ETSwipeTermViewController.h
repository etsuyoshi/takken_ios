//
//  ETSwipeTermViewController.h
//  GetLicense
//
//  Created by EndoTsuyoshi on 2015/01/13.
//  Copyright (c) 2015年 com.endo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "ETCSVModel.h"
#import "ETQuestionModel.h"
#import "PNChartDelegate.h"
#import "PNChart.h"
#import "Header.h"

@interface ETSwipeTermViewController : GAITrackedViewController//UIViewController
<MDCSwipeToChooseDelegate,
UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *strSector;
//@property (nonatomic, strong) ETCSVModel *csvModel;
@property (nonatomic, strong) NSArray *arrQuestionModels;
@end
