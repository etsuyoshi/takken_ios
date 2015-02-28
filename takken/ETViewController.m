//
//  ViewController.m
//  takken
//
//  Created by EndoTsuyoshi on 2015/02/28.
//  Copyright (c) 2015年 com.endo. All rights reserved.
//

#import "ETViewController.h"
#import "ETTableViewCell.h"
#import "ETSwipeTermViewController.h"
#import "ETResultTopViewController.h"
//#import "YALSunnyRefreshControl.h"

#import "ETQuestionModel.h"
#import "ETCSVModel.h"
#define NUM_OF_TOP_CELL 20
#define FILE_NAME @"takken"


@interface ETViewController ()
//@property (nonatomic,strong) YALSunnyRefreshControl *sunnyRefreshControl;
@end

@implementation ETViewController{
    UITableView *myTableView;
    NSArray *arrStrImageName;
    ETCSVModel *csvModel;
    NSArray *arrCategories;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"宅地建物取引主任者試験";
    self.screenName = @"topView";
    
    csvModel =
    [[ETCSVModel alloc]
     initWithCSVName:FILE_NAME
     includingLabel:YES];
    arrCategories = [csvModel getArrCategories];
    
    NSLog(@"csvModel.arr.count = %d, arrCategories = %d",
          (int)csvModel.arrQuestionModels.count,
          (int)arrCategories.count);
    
    
    NSMutableArray *arrayTmp = [NSMutableArray array];
    for(int i = 0;i < 19;i++){
        [arrayTmp addObject:
         [NSString stringWithFormat:@"a%d.jpg", i]];
    }
    arrStrImageName = (NSArray *)arrayTmp;
    myTableView =
    [[UITableView alloc]
     initWithFrame:
     self.view.bounds
//     CGRectMake(0, 0, self.view.bounds.size.width,
//                self.view.bounds.size.height)
     style:UITableViewStylePlain];
    //    myTableView.backgroundColor=[UIColor redColor];
    myTableView.separatorColor = [UIColor clearColor];
    
    UINib *nib = [UINib nibWithNibName:@"ETTableViewCell"
                                bundle:nil];
    [myTableView
     registerNib:nib
     forCellReuseIdentifier:@"etTableViewCell"];
    
    
    
    //refresh control
    [self setupRefreshControl];
    
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    [self.view addSubview:myTableView];
    [self setNavigationBarAtTop];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"%s", __func__);
    
    [myTableView reloadData];
    NSLog(@"contentoffset = %f, %f", myTableView.contentOffset.x, myTableView.contentOffset.y);
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//リフレッシュコントローラの設置
-(void)setupRefreshControl{
    
    //    self.sunnyRefreshControl =
    //    [YALSunnyRefreshControl
    //     attachToScrollView:myTableView
    //     target:self
    //     refreshAction:@selector(sunnyControlDidStartAnimation)];
    
}

-(void)sunnyControlDidStartAnimation{
    
    // start loading something
    [self performSelector:@selector(endAnimationHandle) withObject:nil afterDelay:1.5f];
}

-(void)endAnimationHandle{
    [UIView
     animateWithDuration:.5f
     animations:^{
         [myTableView setContentInset:UIEdgeInsetsMake(-64, 0, 0, 0)];
     }
     completion:^(BOOL finished){
         if(finished){
             [myTableView reloadData];
             //             [self.sunnyRefreshControl endRefreshing];
         }
     }];
    
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"%s : return = %d", __func__, (int)arrCategories.count);
    //    return csvModel.arrQuestionModels.count;//NUM_OF_TOP_CELL;
    return arrCategories.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return .1f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return .1f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s", __func__);
    static NSString *CellIdentifier = nil;
    if(CellIdentifier == nil)
        CellIdentifier = @"etTableViewCell";//unique
    ETTableViewCell *cell =
    [tableView
     dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        cell = [[ETTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    //    ETQuestionModel *questionModel = csvModel.arrQuestionModels[indexPath.row];
    [cell.imvMain setImage:[UIImage imageNamed:arrStrImageName[indexPath.row % (int)arrStrImageName.count]]];
    [cell.lblTitle setText:[NSString stringWithFormat:@"第%d章", (int)indexPath.row+1]];
    [cell.lblSubTitle setText:arrCategories[indexPath.row]];
    //     questionModel.strCategory];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s", __func__);
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:
     [[GAIDictionaryBuilder
       createEventWithCategory:@"topView"     // Event category (required)
       action:@"selectSection"  // Event action (required)
       label:[NSString stringWithFormat:@"tapped:%d", (int)indexPath.row]          // Event label
       value:nil] build]];    // Event value
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ETSwipeTermViewController *swipeVC = [[ETSwipeTermViewController alloc]init];
    //    swipeVC.csvModel = csvModel;
    swipeVC.arrQuestionModels = [csvModel getArrLimitedRangeWithSect:
                                 [NSString stringWithFormat:@"SECT%03d", (int)indexPath.row+1]];
    swipeVC.strSector = [NSString stringWithFormat:@"%d", (int)indexPath.row];
    NSLog(@"%@", swipeVC);
    [self.navigationController pushViewController:swipeVC animated:YES];
}


//慣性スクロール完了時
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"%s", __func__);
    
    
}

//自動スクロール完了時にのみコール
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSLog(@"%s", __func__);
    
    
}

//手動スクロール完了時:フリック(decelerate=1)とドラッグ(decelerate=0)時にコール
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                 willDecelerate:(BOOL)decelerate{
    NSLog(@"%s decelerate=%d", __func__, decelerate);
    
    
}

//ドラッグ（フリック）し始めたタイミング
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    NSLog(@"%s : %f, %f", __func__, translation.x, translation.y);
    //    if(translation.x > 0)
    //    {
    //        // react to dragging right
    //    } else
    //    {
    //        // react to dragging left
    //    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}


-(void)setNavigationBarAtTop{
    //バックグラウンドイメージ
    UIImage *img_mae = [UIImage imageNamed:@"nav_back2"];  // リサイズ前UIImage
    UIImage *img_ato;  // リサイズ後UIImage
    CGFloat width = self.view.bounds.size.width;  // リサイズ後幅のサイズ
    CGFloat height = 64;  // リサイズ後高さのサイズ
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [img_mae drawInRect:CGRectMake(0, 0, width, height)];
    img_ato = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    [self.navigationController.navigationBar
     setBackgroundImage:img_ato//リサイズ後のイメージファイルを使用する場合
     //     setBackgroundImage:[UIImage imageNamed:@"nav_back1"]//画像貼付
     //     setBackgroundImage:[UIImage new]//透明
     forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    self.navigationController.navigationBar.translucent = YES;
    
    img_mae = nil;
    img_ato = nil;
    
    
    
    
    //左右のボタン
    
    //右ボタン:カート
    //    UIImage *imgCart = [UIImage imageNamed:@"nav_icon_cart"];
    //    UIButton *customView = [[UIButton alloc]
    //                            initWithFrame:
    //                            CGRectMake(0, 0, imgCart.size.width,
    //                                       imgCart.size.height)];
    //    [customView setBackgroundImage:imgCart//[UIImage imageNamed:@"nav_icon_cart"]
    //                          forState:UIControlStateNormal];
    //    [customView addTarget:self action:@selector(moveToCart:) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    //    self.navigationItem.rightBarButtonItem = buttonItem;
    
    
    
    //    UIImage *backImage =
    //    [[UIImage imageNamed:@"nav_icon_back"]
    //     resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12.0f, 0, 12.0f)];
    
    
    //    UIBarButtonItem *navLeftBarButton =
    //    [[UIBarButtonItem alloc]
    //     initWithImage:backImage
    //     style:UIBarButtonItemStylePlain
    //     target:self
    //     action:@selector(popBack)];
    //    self.navigationItem.leftBarButtonItem = navLeftBarButton;
    
    
    //左ボタン：メニュー
    UIImage *image = [UIImage imageNamed:@"nav_icon_menu"];
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width,
                                    image.size.height);
    //
    
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    //    button.backgroundColor = [UIColor orangeColor];
    [button setContentEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [button addTarget:self action:@selector(displayResult) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = item;
    
    //スワイプで戻るを可能にする
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    
}

-(void)displayResult{
    NSLog(@"%s", __func__);
    ETResultTopViewController *resultVC = [[ETResultTopViewController alloc]init];
    resultVC.arrQuestionModels = csvModel.arrQuestionModels;
    [self.navigationController pushViewController:resultVC animated:YES];
} 

@end
