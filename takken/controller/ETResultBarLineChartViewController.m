//
//  ETBarLineChartViewController.m
//  GetLicense
//
//  Created by EndoTsuyoshi on 2015/01/14.
//  Copyright (c) 2015年 com.endo. All rights reserved.
//

#import "ETResultBarLineChartViewController.h"
#import "ETCommon.h"
#import "Header.h"
#import <UICKeyChainStore.h>
#define INIT_Y 90
#define HEIGHT_LABEL 40

#define HEIGHT_GRAPH 200
#define INTERVAL_GRAPH 30

#define MAX_DATA_NUM_IN_GRAPH 7



@interface ETResultBarLineChartViewController ()

@end

@implementation ETResultBarLineChartViewController{
    NSArray *arrResults;
    
    NSMutableArray *arrMForGraphData;
    
//    BOOL isTestMode;//何もデータが入ってない場合はダミーグラフにする
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //testで確認
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:STRING_KEYCHAIN_ROOT];
    NSData *datatmp;
    NSDictionary *dictionarytmp;
    arrMForGraphData = [NSMutableArray array];
    for(int i = 0;i < SIZE_TIMESERIES_DATA;i++){
        datatmp = [store dataForKey:[NSString stringWithFormat:@"data%d", i]];
        
        if(![ETCommon isNull:datatmp]){
            dictionarytmp = [NSKeyedUnarchiver unarchiveObjectWithData:datatmp];
            NSLog(@"ymd = %@, right = %@, wrong=%@",
                  dictionarytmp[STRING_YYYYMMDD],
                  dictionarytmp[[NSString stringWithFormat:@"%@",
                                 STRING_KEYCHAIN_RIGHT]],
                  dictionarytmp[[NSString stringWithFormat:@"%@",
                                 STRING_KEYCHAIN_WRONG]]);
            
            [arrMForGraphData addObject:dictionarytmp];
        }
    }
    //何もデータが入ってない場合はダミーグラフにする
//    isTestMode = (arrMForGraphData.count == 0)?YES:NO;
    store = nil;
    
    //arrMinutesCandleDataが格納されてから描画する
    [self displayLineChart];
    [self displayBarChart];
    
    //タッチした時のdelegateメソッドがすぐにわからないため、一応アンタッチャブルにする
//    UIView *viewAll = [[UIView alloc]initWithFrame:self.view.bounds];
//    viewAll.backgroundColor = [UIColor clearColor];
//    viewAll.userInteractionEnabled = NO;
//    [self.view addSubview:viewAll];
//    [self.view bringSubviewToFront:viewAll];
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

-(NSString *)getRightRate:(NSDictionary *)dictDataAtOneDay{
    if(![ETCommon isNull:dictDataAtOneDay]){
        int numRight = (int)[dictDataAtOneDay[STRING_KEYCHAIN_RIGHT] integerValue];
        int numWrong = (int)[dictDataAtOneDay[STRING_KEYCHAIN_WRONG] integerValue];
        float rate = (float)numRight / ((float)numRight + numWrong) * 100;

        return [NSString stringWithFormat:@"%.2f", rate];
    }else{
        return @"0";
    }
}
-(void)displayBarChart{
    NSLog(@"%s", __func__);
    //Add bar chart
    //    NSArray *arrayY = @[@1,@24,@12,@18,@30,@10,@21];
    //    NSArray *arrayX = @[@"sep 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7"];
    NSMutableArray *arrY = [NSMutableArray array];
    NSMutableArray *arrX = [NSMutableArray array];
    
    //    for(int i =0;i < arrMinutesCandleData.count;i++){
    for(int i =0;i < MAX_DATA_NUM_IN_GRAPH;i++){
        NSString* strData = nil;//
        if(i < arrMForGraphData.count){
            strData = [self getRightRate:arrMForGraphData[i]];
        }else{
            strData = [NSString stringWithFormat:@"%d", 0];//arrMinutesCandleData[i][@"closing_price"];
        }
        NSLog(@"class = %@, %f",
              [strData class], [strData floatValue]);//規格化
        //        [arrY addObject:arrMinutesCandleData[i][@"closing_price"]];
        [arrY addObject:[NSString stringWithFormat:@"%f", [strData floatValue]]];
        //        [arrX addObject:arrMinutesCandleData[i][@"id"]];
        if(i < arrMForGraphData.count){
            [arrX addObject:arrMForGraphData[i][STRING_YYYYMMDD]];
        }else{
            [arrX addObject:@""];
        }
        
        NSLog(@"i = %d, x = %@, y = %@", i, [arrX lastObject], [arrY lastObject]);
    }
    
    self.barChart = [[PNBarChart alloc]
                     initWithFrame:
                     CGRectMake(1.f / 10.f *SCREEN_WIDTH-10, INIT_Y + HEIGHT_LABEL + HEIGHT_GRAPH,
                                6.f / 7.f * SCREEN_WIDTH, HEIGHT_GRAPH)];
    self.barChart.backgroundColor = [UIColor clearColor];
    self.barChart.yLabelFormatter = ^(CGFloat yValue){
        CGFloat yValueParsed = yValue;
        NSString * labelText = [NSString stringWithFormat:@"%1.f",yValueParsed];
        return labelText;
    };
    self.barChart.labelMarginTop = 5.0;
    //    [self.barChart setXLabels:@[@"sep 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7"]];
    //
    ////    [self.barChart setYValues:@[@1,@24,@12,@18,@30,@10,@21]];
    //    [self.barChart setYValues:@[@"1",@"24",@"12",@"18",@"30",@"10",@"21"]];
    [self.barChart setXLabels:arrX];
    [self.barChart setYValues:arrY];
    NSLog(@"drawn = %@", arrY);
    [self.barChart setStrokeColors:@[PNGreen,PNGreen,PNRed,PNGreen,PNGreen,PNYellow,PNGreen]];
    // Adding gradient
    //    self.barChart.barColorGradientStart = [UIColor blueColor];
    
    [self.barChart strokeChart];
    
//    self.barChart.delegate = self;
    
    
    
    UILabel * barChartLabel =
    [[UILabel alloc]
     initWithFrame:
     CGRectMake(0, INIT_Y + HEIGHT_LABEL + HEIGHT_GRAPH*2, SCREEN_WIDTH, HEIGHT_LABEL)];
    barChartLabel.text = @"正解率";
    barChartLabel.textColor = PNFreshGreen;
    barChartLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:23.0];
    barChartLabel.textAlignment = NSTextAlignmentCenter;
    
    
    [self.view addSubview:barChartLabel];
    [self.view addSubview:self.barChart];
    
    [self drawAxisForBarChart];
    
}

-(void)drawAxisForBarChart{
    UIView *viewXaxis = [[UIView alloc]initWithFrame:CGRectMake(50, 495, 280, 1)];
    viewXaxis.backgroundColor = [UIColor blackColor];
    [self.view addSubview:viewXaxis];
    [self.view bringSubviewToFront:viewXaxis];
    
    UIView *viewYaxis = [[UIView alloc]initWithFrame:CGRectMake(50, 345, 1, 150)];
    viewYaxis.backgroundColor = [UIColor blackColor];
    [self.view addSubview:viewYaxis];
    [self.view bringSubviewToFront:viewYaxis];
}


-(NSArray *)getNumRightArray{
    NSMutableArray *arrReturn = [NSMutableArray array];
    for(int i = 0;i < MAX_DATA_NUM_IN_GRAPH;i++){
        if(i < arrMForGraphData.count){
            //正解数を格納
            [arrReturn addObject:arrMForGraphData[i][STRING_KEYCHAIN_RIGHT]];
        }else{
            //格納されていなければゼロ設定
            [arrReturn addObject:@"0"];
        }
    }
    return (NSArray *)arrReturn;
}
-(NSArray *)getRandomArray{
    NSMutableArray *arrReturn = [NSMutableArray array];
    for(int i = 0;i < MAX_DATA_NUM_IN_GRAPH;i++){
        
        //格納されていなければゼロ設定
        [arrReturn addObject:[NSNumber numberWithInt:arc4random() % 80]];
    }
    return (NSArray *)arrReturn;
}


-(void)drawAxisForLineChart{
    UIView *viewXaxis = [[UIView alloc]initWithFrame:CGRectMake(50, 270, 280, 1)];
    viewXaxis.backgroundColor = [UIColor blackColor];
    [self.view addSubview:viewXaxis];
    [self.view bringSubviewToFront:viewXaxis];
    
    UIView *viewYaxis = [[UIView alloc]initWithFrame:CGRectMake(50, 120, 1, 150)];
    viewYaxis.backgroundColor = [UIColor blackColor];
    [self.view addSubview:viewYaxis];
    [self.view bringSubviewToFront:viewYaxis];
}

-(void)displayLineChart{
    
    //Add line chart
    UILabel * lineChartLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, INIT_Y, SCREEN_WIDTH, HEIGHT_LABEL)];
    lineChartLabel.text = @"回答数";
    lineChartLabel.textColor = PNFreshGreen;
    lineChartLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:23.0];
    lineChartLabel.textAlignment = NSTextAlignmentCenter;
    
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(-20, 135.0, SCREEN_WIDTH, 200.0)];
    //    lineChart.yLabelFormat = @"%1.1f";
    lineChart.backgroundColor = [UIColor clearColor];
    //    [lineChart setXLabels:@[@"A",@"B",@"C",@"D",@"E",@"F",@"G"]];
    [lineChart setXLabels:@[@"",@"",@"",@"",@"",@"",@""]];
    //    lineChart.showCoordinateAxis = YES;
    
    // Line Chart #1
    NSArray * data01Array = [self getNumRightArray];//@[@60.1, @160.1, @126.4, @262.2, @186.2, @127.2, @176.2];
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = PNFreshGreen;
    data01.itemCount = lineChart.xLabels.count;
    //    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    // Line Chart #2
    NSArray * data02Array = [self getRandomArray];//@[@20.1, @180.1, @26.4, @202.2, @126.2, @167.2, @276.2];
    PNLineChartData *data02 = [PNLineChartData new];
    data02.color = PNTwitterColor;
    data02.itemCount = lineChart.xLabels.count;
    //    data02.inflexionPointStyle = PNLineChartPointStyleSquare;
    data02.getData = ^(NSUInteger index) {
        CGFloat yValue = [data02Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    lineChart.chartData = @[data01, data02];
    [lineChart strokeChart];
    
//    lineChart.delegate = self;
    
    [self.view addSubview:lineChartLabel];
    [self.view addSubview:lineChart];
    
    
    
    [self drawAxisForLineChart];
    
}


@end
