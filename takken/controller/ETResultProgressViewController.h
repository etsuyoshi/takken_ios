//
//  ETResultProgressViewController.h
//  GetLicense
//
//  Created by EndoTsuyoshi on 2015/01/14.
//  Copyright (c) 2015年 com.endo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNChartDelegate.h"
#import "PNChart.h"

@interface ETResultProgressViewController : UIViewController
<PNChartDelegate>

@property (nonatomic, strong) NSArray *arrQuestionModels;
@end
