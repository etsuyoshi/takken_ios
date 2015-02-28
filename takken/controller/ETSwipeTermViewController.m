//
//  ETSwipeTermViewController.m
//  GetLicense
//
//  Created by EndoTsuyoshi on 2015/01/13.
//  Copyright (c) 2015年 com.endo. All rights reserved.
// 問題オブジェクトに正解率、正解数、誤答回数を格納
// 最後まで行ったら、deviceに保存する

#import "ETSwipeTermViewController.h"
#import <UICKeyChainStore.h>

#import "ETCommon.h"
#define HEIGHT_MENU_BUTTON 70
#define SIZE_IMVJUDGE_MAX 200
#define POINT_QUESTION_TEXT_FONT 15.f
#define POINT_QUESTION_TEXT_FONT_SMALL 11.f

#define STRING_DISPLAY_COMMENT @"解説表示"
#define STRING_NOT_DISPLAY_COMMENT @"解説非表示"

@interface ETSwipeTermViewController ()

@end

@implementation ETSwipeTermViewController{
    int currentQuestionNo;
    UIImageView *imvJudge;
    PNPieChart *pieChart;
    UILabel *lblResult;
    
    
    UIButton *btnReturn;
    UIButton *btnDisplay;
    
    MDCSwipeToChooseViewOptions *options;
    
    CGPoint pointInitialCard;
    CGPoint pointInitialComment;
    BOOL isDisplayComment;
    
    UIImageView *imvComment;
    UILabel *lblComment;
    
    int sumRight;
    int sumWrong;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%s", __func__);
    // Do any additional setup after loading the view.

    //[UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.000 green:0.f blue:0.f alpha:1.000];
    sumRight = 0;
    sumWrong = 0;
    self.title = [NSString stringWithFormat:@"第%d章", (int)[self.strSector integerValue] + 1];
    isDisplayComment = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"%s, self.arr.count=%d",
          __func__, (int)self.arrQuestionModels.count);
    
    
    pointInitialCard = CGPointMake(self.view.center.x,
                               self.view.center.y - 10);
    pointInitialComment = CGPointMake(self.view.center.x,
                                      self.view.bounds.size.height + 400);//フレームの下３００pt
    
    int marginMenu = 20;
    //左上に一枚戻るボタン
    btnReturn =
    [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame =
     CGRectMake(marginMenu,marginMenu*3.5,
                self.view.bounds.size.width/2-marginMenu*2,
                HEIGHT_MENU_BUTTON);
    [btnReturn setTitle:@"一枚戻る" forState:UIControlStateNormal];
//    [btnReturn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [btnReturn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
    [btnReturn setTitleColor:PNFreshGreen forState:UIControlStateNormal];
    btnReturn.backgroundColor = [UIColor clearColor];
    btnReturn.layer.borderColor = PNFreshGreen.CGColor;
    btnReturn.layer.borderWidth = 8.f;
    btnReturn.layer.cornerRadius = 15.f;
    [btnReturn addTarget:self action:@selector(tappedReturn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    
    //右上に解説を表示するボタン
    btnDisplay =
    [UIButton buttonWithType:UIButtonTypeCustom];
    btnDisplay.frame =
    CGRectMake(self.view.bounds.size.width/2 + marginMenu,
               btnReturn.frame.origin.y,
               self.view.bounds.size.width/2 - marginMenu*2,
               HEIGHT_MENU_BUTTON);
//    [btnDisplay.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [btnDisplay.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
    [self setBtnDisplay];
    btnDisplay.layer.borderWidth = 8.f;
    btnDisplay.layer.cornerRadius = 15.f;
    [btnDisplay addTarget:self action:@selector(tappedDisplayComment:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDisplay];
    
    
    options = [MDCSwipeToChooseViewOptions new];
//    MDCSwipeOptions *options = [MDCSwipeOptions new];
    options.delegate = self;
    options.likedText = @"正しい";
    options.likedColor = [UIColor blueColor];
    options.nopeText = @"誤り";
    options.nopeColor = [UIColor orangeColor];
    options.onPan = ^(MDCPanState *state){
        if (state.thresholdRatio == 1.f && state.direction == MDCSwipeDirectionLeft) {
            NSLog(@"Let go now to delete the photo!");
        }
    };
    
    //正誤判定のまるばつ
    imvJudge = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SIZE_IMVJUDGE_MAX, SIZE_IMVJUDGE_MAX)];
    imvJudge.center =
//    CGPointMake(self.view.bounds.size.width/2,
//                self.view.bounds.size.height/2 - 250);
    self.view.center;
//    imvJudge.center = CGPointMake(self.view.bounds.size.width/2,200);
    imvJudge.alpha = 0.f;
    [self.view addSubview:imvJudge];
    
    
//    UIView *cardView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
//    cardView.center = self.view.center;
//    [cardView mdc_swipeToChooseSetup:options];
    
    
    MDCSwipeToChooseView *viewCard = nil;
    UILabel *lblQuestionOnView;
    UILabel *lblUpperLeftOnView;
    ETQuestionModel *questionModel;
    for(int i = 0;i < self.arrQuestionModels.count;i++){
        questionModel = self.arrQuestionModels[i];
        viewCard =
        [[MDCSwipeToChooseView alloc]
         initWithFrame:CGRectMake(0, 0, 300, self.view.bounds.size.height>500?250:150)
         options:options];
//        viewCard.center = self.view.center;
        viewCard.center = pointInitialCard;
        
        viewCard.layer.cornerRadius = 10.f;
        viewCard.layer.masksToBounds = YES;
        viewCard.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"card%d.jpg", i%20]];//19以下
        viewCard.imageView.contentMode = UIViewContentModeScaleAspectFill;
        viewCard.imageView.clipsToBounds = YES;
        viewCard.imageView.alpha = .5f;
        viewCard.backgroundColor = [UIColor blackColor];
        
        
        //問題番号
        lblUpperLeftOnView = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, viewCard.bounds.size.width-20, 40)];
        [lblUpperLeftOnView setFont:[UIFont systemFontOfSize:9.f]];
        [lblUpperLeftOnView setText:
         [NSString stringWithFormat:@"第%d章 第%d問 : %@",
          (int)[self.strSector integerValue] + 1,
          i + 1,
          questionModel.strCategory]];
//        [lblUpperLeftOnView setText:
//         [NSString stringWithFormat:@"#%@ %@(%@)",
//          questionModel.strSector,
//          questionModel.strNo,
//          questionModel.strCategory]];
        [lblUpperLeftOnView setTextColor:[UIColor whiteColor]];
        [viewCard addSubview:lblUpperLeftOnView];
        
        
        
        //質問文章
        lblQuestionOnView =
        [[UILabel alloc]initWithFrame:
         CGRectMake(20, 20, viewCard.bounds.size.width-40,
                    viewCard.bounds.size.height-40)];
        if(self.view.bounds.size.height > 500){
            [lblQuestionOnView setFont:[UIFont systemFontOfSize:POINT_QUESTION_TEXT_FONT]];
        }else{
            [lblQuestionOnView setFont:[UIFont systemFontOfSize:POINT_QUESTION_TEXT_FONT_SMALL]];
        }
        [lblQuestionOnView setText:questionModel.strQuestion];
        NSLog(@"question(%d) = %@", i, questionModel.strQuestion);
        [lblQuestionOnView setTextColor:[UIColor whiteColor]];
//        [lblQuestionOnView setTextColor:[UIColor colorWithRed:78.f/255.f
//                                                 green:78.f/255.f
//                                                  blue:78.f/255.f
//                                                  alpha:1.f]];
        lblQuestionOnView.numberOfLines = 0;
        [lblQuestionOnView sizeToFit];
        lblQuestionOnView.center =
        CGPointMake(viewCard.bounds.size.width/2,
                    viewCard.bounds.size.height/2);
        [viewCard addSubview:lblQuestionOnView];
        
        
        
        
        [self.view addSubview:viewCard];
        [self.view sendSubviewToBack:viewCard];
    }
    
    lblResult =
    [[UILabel alloc]
     initWithFrame:
     CGRectMake(self.view.bounds.size.width/2,
//                viewCard.frame.origin.x,
                viewCard.frame.origin.y + viewCard.bounds.size.height,
                self.view.bounds.size.width/2-40,
                self.view.bounds.size.height-(viewCard.frame.origin.y + viewCard.bounds.size.height))];
    
    [lblResult setText:@"データ取得中..."];
    [lblResult setFont:[UIFont systemFontOfSize:11.f]];
    [lblResult setTextColor:PNLightGreen];
    lblResult.numberOfLines = 0;
    [self.view addSubview:lblResult];
    
    
    
    //コメント用ビュー
    imvComment = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"card14.jpg"]];
    imvComment.frame = CGRectMake(0, 0, self.view.bounds.size.width-10,self.view.bounds.size.height-10);//サイズのみ定義
    imvComment.center = pointInitialComment;
    imvComment.layer.cornerRadius = 10.f;
    imvComment.layer.masksToBounds = YES;
    imvComment.contentMode = UIViewContentModeScaleAspectFill;
    imvComment.clipsToBounds = YES;
    imvComment.alpha = .95f;
    imvComment.backgroundColor = [UIColor blueColor];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedComment:)];
    gesture.delegate = self;
    [imvComment addGestureRecognizer:gesture];
    imvComment.userInteractionEnabled = YES;
    [self.view addSubview:imvComment];
    
    lblComment = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-20, 1)];
    [lblComment setText:@"data acquiring..."];
    [lblComment setTextColor:[UIColor whiteColor]];
    [lblComment setFont:[UIFont systemFontOfSize:20.f]];
    [lblComment sizeToFit];
    lblComment.numberOfLines = 0;
    lblComment.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:.5f];
    lblComment.center = CGPointMake(imvComment.bounds.size.width/2,
                                    imvComment.bounds.size.height/2);
    [imvComment addSubview:lblComment];
    
    
    
    [self initPieChart];
}

//コメント文のジェスチャ
-(void)tappedComment:(id)sender{//senderはgesture
    NSLog(@"%s", __func__);
    
    [UIView
     animateWithDuration:.5f
     animations:^{
         imvComment.center = pointInitialComment;
     }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSLog(@"%s", __func__);
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


- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"Couldn't decide, huh?");
}

// Sent before a choice is made. Cancel the choice by returning `NO`. Otherwise return `YES`.
- (BOOL)view:(UIView *)view shouldBeChosenWithDirection:(MDCSwipeDirection)direction {
    NSLog(@"%s", __func__);
    if (direction == MDCSwipeDirectionLeft) {
        return YES;
    } else {
        // Snap the view back and cancel the choice.
        [UIView animateWithDuration:0.16 animations:^{
            view.transform = CGAffineTransformIdentity;
//            view.center = self.view.center;
            view.center = pointInitialCard;
//            CGPointMake(self.view.center.x,
//            self.view.center.y - 20);
        }];
        return YES;//ドラッグをキャンセルする場合はNO
    }
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    NSLog(@"%s", __func__);
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"Photo deleted!");
    }else{
        NSLog(@"Photo saved!");
    }
    
    
    if(isDisplayComment){
        //解説表示
        [self displayComment];
    }
    
    //右正しい、左誤り
    [self
     judge:currentQuestionNo
     answer:(direction==MDCSwipeDirectionLeft)?2:1];//正しい1,正しくない2
    
    pieChart.alpha = 0.f;
    lblResult.alpha = 0.f;
    
    
    
    //次の問題へ
    currentQuestionNo++;
    
    if(currentQuestionNo < self.arrQuestionModels.count){
        
        [self animateWithAppearPieChart];//次の問題の成績表示
    }else{
        
        //最後の処理
        [self finalProcess];
        [UIView
         animateWithDuration:.5f
         animations:^{
             pieChart.alpha = 0.f;
             lblResult.alpha = 0.f;
         }];
    }
    
    //解説モードの場合、グラフが解説よりも前に来ないようにするため
    [self.view bringSubviewToFront:imvComment];
    
}

-(void)displayComment{
    //解説表示モードなら表示する
    
    ETQuestionModel *questionModel = self.arrQuestionModels[currentQuestionNo];
    NSLog(@"questionModel = %@(%@)", questionModel, questionModel.strComment);
    [lblComment setText:questionModel.strComment];
    lblComment.frame = CGRectMake(0, 0, self.view.bounds.size.width-20,
                                  self.view.bounds.size.height);
    [lblComment sizeToFit];
    lblComment.center = CGPointMake(imvComment.bounds.size.width/2,
                                    imvComment.bounds.size.height/2);
    [self.view bringSubviewToFront:imvComment];
    //下から上へのアニメーション（フレームイン→センター)
    [UIView
     animateWithDuration:.5f
     animations:^{
         imvComment.center = self.view.center;
     }];
}

-(BOOL)judge:(int)noOfQuestion
      answer:(int)answer{//番号0-5(２択なら)
    
    ETQuestionModel *questionModel =
    self.arrQuestionModels[noOfQuestion];
    
    NSLog(@"%s, q=%d, ans = %d, correct = %@, other = %@",
          __func__, noOfQuestion, answer, questionModel.strAnswerNo,
          questionModel.strOther);
//    imvJudge.frame = CGRectMake(imvJudge.center.x, imvJudge.center.y,
//                                10, 10);
    imvJudge.alpha = 1.f;
    [self.view bringSubviewToFront:imvJudge];
    [self setImvAnimateAlpha:0];//最初１にしてその後ゼロにする
    
    if([questionModel.strAnswerNo integerValue] == answer){
        imvJudge.image = [UIImage imageNamed:@"circle"];
        sumRight++;
//        imvJudge.alpha = 1.f;
//        [self.view bringSubviewToFront:imvJudge];
//        [self setGradationAlpha:0];
        
        [self saveDataWithNo:currentQuestionNo isRight:YES];
        return YES;
    }
    
    imvJudge.image = [UIImage imageNamed:@"cross"];
    sumWrong++;
    [self saveDataWithNo:currentQuestionNo isRight:NO];
    return false;
}

-(void)setImvAnimateAlpha:(int)intAlpha{
    [UIView
     animateWithDuration:.9f
     animations:^{
         //上二つは位置とサイズを変更した時のために元の位置にセットする
         imvJudge.frame = CGRectMake(0, 0, SIZE_IMVJUDGE_MAX, SIZE_IMVJUDGE_MAX);
         imvJudge.center = self.view.center;
         //指定した透過度に設定
         imvJudge.alpha = intAlpha;
     }
     completion:^(BOOL isFinished){
         if(isFinished){
             imvJudge.alpha = intAlpha;
//             if(intAlpha == 1){
//                 //最初の指示で１になったら次はゼロにして終了
//                 [self setImvAnimateAlpha:0];
//             }
         }
     }];
}



-(void)initPieChart{
    //Add pie chart
    UILabel * pieChartLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, 100, 30)];
    pieChartLabel.text = @"正解率";
    pieChartLabel.textColor = PNFreshGreen;
    pieChartLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:13.0];
    pieChartLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:pieChartLabel];
    
    [self setPieChartData];
    
    pieChartLabel.center =
    CGPointMake(pieChart.center.x,
                pieChart.center.y - pieChart.bounds.size.height/2 - pieChartLabel.bounds.size.height/2);//10は微調整
    
}

-(void)setPieChartData{
    
    
    NSArray *items = @[[PNPieChartDataItem
                        dataItemWithValue:(int)[[self getNumberWith:currentQuestionNo isRight:YES] integerValue]
                        color:PNLightGreen
                        description:@""],
                       [PNPieChartDataItem
                        dataItemWithValue:(int)[[self getNumberWith:currentQuestionNo isRight:NO] integerValue]
                        color:PNDeepGreen
                        description:@""]];
    
    for(int i = 0;i < items.count;i++){
        NSLog(@"item(%d) = %@", i, items[i]);
    }
    
    [pieChart removeFromSuperview];
    pieChart = nil;
    pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(40.0, 440.0, 100.0, 100.0)
                                           items:items];
    pieChart.descriptionTextColor = [UIColor clearColor];
    pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
    pieChart.descriptionTextShadowColor = [UIColor clearColor];
    pieChart.center = CGPointMake(pieChart.center.x,
                                  self.view.bounds.size.height-40-pieChart.bounds.size.height/2);
    [self.view addSubview:pieChart];
    [self.view bringSubviewToFront:pieChart];
    [pieChart strokeChart];
    
    float flNumRight = [[self getNumberWith:currentQuestionNo isRight:YES] floatValue];
    float flNumWrong = [[self getNumberWith:currentQuestionNo isRight:NO] floatValue];
    float flRightRate = 0;
    if(flNumRight + flNumWrong != 0){
        flRightRate = flNumRight / (flNumRight + flNumWrong);
    }
    
    NSString *strLabel =
    [NSString stringWithFormat:@"正解数:%d回\n不正解:%d回\n正解率%.1f％",
     (int)flNumRight,
     (int)flNumWrong,
     flRightRate * 100.f];
    
    NSLog(@"strLabel = %@", strLabel);
    
    //label update
    [lblResult setText:strLabel];
     
}

-(void)animateWithAppearPieChart{
    
    
    
    [self setPieChartData];
    
    
    [UIView
     animateWithDuration:1.5f
     animations:^{
         pieChart.alpha = 1.f;
         lblResult.alpha = 1.f;
     }
     completion:^(BOOL finished){
         if(finished){
             pieChart.alpha = 1.f;
             lblResult.alpha = 1.f;
         }
     }];
}


//戻る場所がないときに
//http://stackoverflow.com/questions/1713123/best-way-to-vibrate-a-ui-item
-(void)rejectReturn{
    btnReturn.transform = CGAffineTransformMakeTranslation(2.0, -2.0);
    [UIView animateWithDuration:0.07
                          delay:0.0
                        options:UIViewAnimationOptionAutoreverse
                     animations:^{
                         UIView.animationRepeatCount = 4;
                         btnReturn.transform = CGAffineTransformMakeTranslation(-2.0, 2.0);
                     }
                     completion:^(BOOL finished){
                         btnReturn.transform = CGAffineTransformIdentity;
                     }];
}

-(void)tappedReturn:(id)sender{
    NSLog(@"%s", __func__);
    
    if(currentQuestionNo == 0
       //|| currentQuestionNo >= self.arrQuestionModels.count
       ){
        [self rejectReturn];
        return;
    }
    currentQuestionNo --;
    
    MDCSwipeToChooseView *viewCardReturn = nil;
    UILabel *lblQuestionOnView;
    UILabel *lblUpperLeftOnView;
    ETQuestionModel *questionModel;
    
    
    questionModel = self.arrQuestionModels[currentQuestionNo];
    viewCardReturn =
    [[MDCSwipeToChooseView alloc]
     initWithFrame:CGRectMake(0, 0, 300, self.view.bounds.size.height>500?250:150)
     options:options];
    viewCardReturn.center = pointInitialCard;
    viewCardReturn.layer.cornerRadius = 10.f;
    viewCardReturn.layer.masksToBounds = YES;
    viewCardReturn.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"card%d.jpg", currentQuestionNo%20]];//19以下
    viewCardReturn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    viewCardReturn.imageView.clipsToBounds = YES;
    viewCardReturn.imageView.alpha = .5f;
    viewCardReturn.backgroundColor = [UIColor blackColor];
    //        viewCard.layer.backgroundColor = [UIColor grayColor].CGColor;
    //    view.imageView.backgroundColor = [UIColor blueColor];
    
    
    //質問文章
    lblQuestionOnView =
    [[UILabel alloc]initWithFrame:
     CGRectMake(20, 20, viewCardReturn.bounds.size.width-40,
                viewCardReturn.bounds.size.height-40)];
    if(self.view.bounds.size.height > 500){
        [lblQuestionOnView setFont:[UIFont systemFontOfSize:POINT_QUESTION_TEXT_FONT]];
    }else{
        [lblQuestionOnView setFont:[UIFont systemFontOfSize:POINT_QUESTION_TEXT_FONT_SMALL]];
    }
    
    [lblQuestionOnView setText:questionModel.strQuestion];
    NSLog(@"question(%d) = %@", currentQuestionNo, questionModel.strQuestion);
    [lblQuestionOnView setTextColor:[UIColor whiteColor]];
    //        [lblQuestionOnView setTextColor:[UIColor colorWithRed:78.f/255.f
    //                                                 green:78.f/255.f
    //                                                  blue:78.f/255.f
    //                                                  alpha:1.f]];
    lblQuestionOnView.numberOfLines = 0;
    [lblQuestionOnView sizeToFit];
    lblQuestionOnView.center =
    CGPointMake(viewCardReturn.bounds.size.width/2,
                viewCardReturn.bounds.size.height/2);
    [viewCardReturn addSubview:lblQuestionOnView];
    
    
    
    //問題番号
    lblUpperLeftOnView = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, viewCardReturn.bounds.size.width-20, 40)];
    [lblUpperLeftOnView setFont:[UIFont systemFontOfSize:11.f]];
    [lblUpperLeftOnView setText:
     [NSString stringWithFormat:@"第%d章 第%d問",
      (int)[self.strSector integerValue] + 1,
      currentQuestionNo + 1]];
//      questionModel.strSector,
//      questionModel.strNo,
//      questionModel.strCategory]];
    [lblUpperLeftOnView setTextColor:[UIColor whiteColor]];
    [viewCardReturn addSubview:lblUpperLeftOnView];
    
    
    
    viewCardReturn.center = CGPointMake(viewCardReturn.center.x,
                                        viewCardReturn.center.y - 500);
    [UIView
     animateWithDuration:.5f
     animations:^{
         viewCardReturn.center = pointInitialCard;
     }];
    
    [self.view addSubview:viewCardReturn];
    [self.view bringSubviewToFront:viewCardReturn];
    
    
    [self setPieChartData];
}

//解説表示ボタン
-(void)tappedDisplayComment:(id)sender{
    NSLog(@"%s", __func__);
    
    isDisplayComment = isDisplayComment?NO:YES;
    [self setBtnDisplay];
}

-(NSString *)getKeyWith:(int)no
                isRight:(BOOL)isRight{
    return [NSString stringWithFormat:@"%@%@%@%d%@",
            STRING_KEYCHAIN_SECTOR,
            self.strSector,
            STRING_KEYCHAIN_NO,
            no,
            isRight?STRING_KEYCHAIN_RIGHT:STRING_KEYCHAIN_WRONG];
}

-(NSString *)getNumberWith:(int)no
                   isRight:(BOOL)isRight{
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:STRING_KEYCHAIN_ROOT];
    NSString *strKey = [self getKeyWith:no isRight:isRight];
    
    return [store stringForKey:strKey];
}

-(void)saveDataWithNo:(int)no
              isRight:(BOOL)isRight{
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:STRING_KEYCHAIN_ROOT];
    
    NSString *strKey = [self getKeyWith:no isRight:isRight];
    
    
    //正解した時はsectXnoYrightをインクリメント
    //不正解の時はsectXnoYwrongをインクリメント
    int numRightOrWrong = (int)[[store stringForKey:strKey] integerValue] + 1;
    NSLog(@"numRightOrWrong(%@) = %d", strKey, numRightOrWrong);
    [store setString:[NSString stringWithFormat:@"%d", numRightOrWrong] forKey:strKey];
    [store synchronize];
    store = nil;
}

-(void)setBtnDisplay{
    
    if(isDisplayComment){//green-tint-color, white-background
        [btnDisplay setTitle:STRING_DISPLAY_COMMENT forState:UIControlStateNormal];
        [btnDisplay setTitleColor:PNFreshGreen forState:UIControlStateNormal];
        btnDisplay.backgroundColor = [UIColor clearColor];
        btnDisplay.layer.borderColor = PNFreshGreen.CGColor;
    }else{//white-tint-color, green-background
        [btnDisplay setTitle:STRING_NOT_DISPLAY_COMMENT forState:UIControlStateNormal];
        [btnDisplay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnDisplay.backgroundColor = PNFreshGreen;
        btnDisplay.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

//一問ずつ格納
-(void)saveDataAtTheDay{
    //格納すべき最新の値
    int newSumRight;
    int newSumWrong;
    //最新のデータがあるかどうか
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:STRING_KEYCHAIN_ROOT];
    NSData *dataNewest = [store dataForKey:@"data0"];//
    NSString *strYYYYMMDDToday = [self getDateYYYYMMDD];//今日の日付
    NSLog(@"yyyymmdd = %@", strYYYYMMDDToday);
    
    NSDictionary *dictionaryNewest = nil;
    NSString *strYYYYMMDDAtNewest = nil;//格納されているデータの中の最新データ
    //最新データに何かしらのデータが入っていた場合
    if(![ETCommon isNull:dataNewest]){
        dictionaryNewest = [NSKeyedUnarchiver unarchiveObjectWithData:dataNewest];
        strYYYYMMDDAtNewest = dictionaryNewest[STRING_YYYYMMDD];
    }
    if([ETCommon isNull:dataNewest] ||
       ![strYYYYMMDDAtNewest isEqualToString:strYYYYMMDDToday]){
        //何も入っていない状態もしくは、最新データが別の日であれば
        NSLog(@"nothing -> create new data");
        //dataN(0,1,2,...)にデータが存在している場合は全て後ろにひとつずつずらす(そもそもdata0に値が入っていない場合はずらす処理のみ必要ない)
        
        NSString *strDataKey;
        NSData *dataTmp;
        //その日のデータがないので、すでに格納されているデータを後ろに追加していく(最後のs_t_d-1のみ)
        for (int i = SIZE_TIMESERIES_DATA-2; i >= 0; i--) {//最後がs_t_d-1、最後から２番目がs_t_d-2
            //nullでなければ後ろにずらしていく
            strDataKey = [NSString stringWithFormat:@"data%d", i];
            dataTmp = [store dataForKey:strDataKey];
            if([ETCommon isNull:dataTmp]){
                
            }else{
                [store setData:dataTmp forKey:[NSString stringWithFormat:@"data%d", i+1]];
                [store synchronize];
            }
            //
        }
        //data0に最新データを格納する
        
        newSumRight = sumRight;
        newSumWrong = sumWrong;
        
    }else{
        //最新データが入っていて、それが本日である場合
        NSLog(@"already-reserved-date = %@ equalToString: today = %@",
              strYYYYMMDDAtNewest, strYYYYMMDDToday);
        
        
        int alreadySumRight =
        (int)[dictionaryNewest[[NSString stringWithFormat:@"%@",
                                STRING_KEYCHAIN_RIGHT]]
              integerValue];
        int alreadySumWrong =
        (int)[dictionaryNewest[[NSString stringWithFormat:@"%@",
                                STRING_KEYCHAIN_WRONG]]
              integerValue];
        
        newSumRight = alreadySumRight + sumRight;
        newSumWrong = alreadySumWrong + sumWrong;
        
        NSLog(@"already-right = %d, wrong = %d",
              alreadySumRight, alreadySumWrong);
        NSLog(@"new-right = %d, wrong = %d",
              newSumRight, newSumWrong);
    }
    
    
    
    //最新データを作成(日付、正解数、不正回数の３点)
    NSMutableDictionary *dictionaryNew = [NSMutableDictionary dictionary];
    dictionaryNew[STRING_YYYYMMDD] = strYYYYMMDDToday;
    dictionaryNew[[NSString stringWithFormat:@"%@",
                   STRING_KEYCHAIN_RIGHT]] =
    [NSNumber numberWithInt:newSumRight];
    dictionaryNew[[NSString stringWithFormat:@"%@",
                   STRING_KEYCHAIN_WRONG]] =
    [NSNumber numberWithInt:newSumWrong];
    NSLog(@"new data = %@", dictionaryNew);
    
    
    //格納用にnsdataに変換する
    NSData *dataReserve = [NSKeyedArchiver archivedDataWithRootObject:dictionaryNew];
    [store setData:dataReserve forKey:@"data0"];//最新データとして格納する
    [store synchronize];
    
    store = nil;
}

-(void)finalProcess{
    
    [self saveDataAtTheDay];
    
    //最後のカードを回り終えてから戻る操作とカードめくりを再実行された時にrightとwrongをカウントし直せるように初期化
    sumRight = 0;
    sumWrong = 0;
    
    //testで確認
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:STRING_KEYCHAIN_ROOT];
    NSData *datatmp;
    NSDictionary *dictionarytmp;
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
        }
    }
    store = nil;
}
       
-(NSString *)getDateYYYYMMDD{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    //N日後のdateを取得する場合
//    date = [NSDate dateWithTimeIntervalSinceNow:3*24*60*60]; // 3日後
    NSLog(@"date = %@", [dateFormatter stringFromDate:date]);
    
    return [dateFormatter stringFromDate:date];
}

@end
