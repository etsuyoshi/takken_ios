//
//  ETResultProgressViewController.m
//  GetLicense
//
//  Created by EndoTsuyoshi on 2015/01/14.
//  Copyright (c) 2015年 com.endo. All rights reserved.
//

#import "ETResultProgressViewController.h"
#import "Header.h"
#import "ETCommon.h"
#import <UICKeyChainStore.h>

@interface ETResultProgressViewController ()

@end

@implementation ETResultProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"進捗率";
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self displayCircleChart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)displayCircleChart{
    
    //Add circle chart
    UILabel * circleChartLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, SCREEN_WIDTH, 30)];
    circleChartLabel.text = @"progress";
    circleChartLabel.textColor = PNFreshGreen;
    circleChartLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:23.0];
    circleChartLabel.textAlignment = NSTextAlignmentCenter;
    int progress = [self getProgress];
    PNCircleChart * circleChart =
    [[PNCircleChart alloc]
     initWithFrame:CGRectMake(0, 180.0, SCREEN_WIDTH, 100.0)
     total:@100
     current:[NSNumber numberWithInt:progress]
     clockwise:YES
     shadow:YES];
    
    circleChart.backgroundColor = [UIColor clearColor];
    [circleChart setStrokeColor:PNGreen];
    [circleChart setStrokeColorGradientStart:[UIColor blueColor]];
    [circleChart strokeChart];
    
    [self.view addSubview:circleChartLabel];
    [self.view addSubview:circleChart];
    
    
    
}

-(int)getProgress{
    if([ETCommon isNull:self.arrQuestionModels]){
        return 0;
    }
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:STRING_KEYCHAIN_ROOT];
    NSString *strNumRight;
    NSString *strNumWrong;
    int progress = 0;
    //第1問のみでもやっていれば、その章は実行済み→全章に対する進捗度合いを表示している
    //sect0no0が存在するかどうかで見極める→将来的にはいろいろ工夫できる
    for(int i = 0;i < self.arrQuestionModels.count;i++){
        strNumRight = nil;
        strNumWrong = nil;
        
        strNumRight = [store stringForKey:[NSString stringWithFormat:@"%@%d%@%d%@",
                                           STRING_KEYCHAIN_SECTOR,
                                           i,
                                           STRING_KEYCHAIN_NO,
                                           0,
                                           STRING_KEYCHAIN_RIGHT]];
        strNumWrong = [store stringForKey:[NSString stringWithFormat:@"%@%d%@%d%@",
                                           STRING_KEYCHAIN_SECTOR,
                                           i,
                                           STRING_KEYCHAIN_NO,
                                           0,
                                           STRING_KEYCHAIN_WRONG]];
        NSLog(@"right = %@, wrong = %@",
              strNumRight,
              strNumWrong);
        if([ETCommon isNull:strNumRight] && [ETCommon isNull:strNumWrong]){
            
        }else{
            progress ++;
        }
    }
    
    
    
    return 100.f * ((float)progress) / self.arrQuestionModels.count;
}
@end
