//
//  ETResultViewController.m
//  GetLicense
//
//  Created by EndoTsuyoshi on 2015/01/14.
//  Copyright (c) 2015年 com.endo. All rights reserved.
//

#import "ETResultTopViewController.h"
#import "ETResultProgressViewController.h"
#import "ETResultBarLineChartViewController.h"

@interface ETResultTopViewController ()

@end

@implementation ETResultTopViewController{
    UITableView *resultTableView;
    NSArray *arrTextsInCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrTextsInCell =
    [NSArray arrayWithObjects:
     @"進捗率",
     @"正解率",
//     @"統計（誤答）",
     nil];
    
    resultTableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    resultTableView.delegate = self;
    resultTableView.dataSource = self;
    [self.view addSubview:resultTableView];
    
    
    [self setNavigationBarAtResult];
    
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


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (int)arrTextsInCell.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return .1f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return .1f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = nil;
    if(CellIdentifier == nil)
        CellIdentifier =
        [NSString stringWithFormat:@"cell%d", (int)indexPath.row];//unique
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell.textLabel setText:arrTextsInCell[indexPath.row]];
    [cell.textLabel setTextColor:
     [UIColor colorWithRed:78.f/255.f
                     green:78.f/255.f
                      blue:78.f/255.f
                     alpha:1.f]];
    
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s", __func__);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0){
        ETResultProgressViewController *progressVC = [[ETResultProgressViewController alloc]init];
        progressVC.arrQuestionModels = self.arrQuestionModels;
        [self.navigationController pushViewController:progressVC animated:YES];
    }else if(indexPath.row == 1){
        ETResultBarLineChartViewController *barLineVC = [[ETResultBarLineChartViewController alloc]init];
        [self.navigationController pushViewController:barLineVC animated:YES];
    }
    
    
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


-(void)setNavigationBarAtResult{
    NSLog(@"%s", __func__);
    
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
     forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    self.navigationController.navigationBar.translucent = YES;
    
    img_mae = nil;
    img_ato = nil;
    
    
    
    
    //左右のボタン
    //右ボタン：不要？
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
    
    
    
    
    //左ボタン：戻る
    UIImage *image = [UIImage imageNamed:@"nav_icon_back"];
    //    CGRect buttonFrame = CGRectMake(0, 0, image.size.width*2/3, image.size.height*2/3);
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width, image.size.height);
    NSLog(@"nav_icon_back = %f, %f", image.size.width, image.size.height);
    
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    //    button.backgroundColor = [UIColor orangeColor];
    [button setContentEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
    [button addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = item;
    
    //スワイプで戻るを可能にする
    self.navigationController.interactivePopGestureRecognizer.delegate =
    (id<UIGestureRecognizerDelegate>)self;
    
    
    
    
    
    //長押しでルートへ戻る：認識器をnavigationBarに設置して位置で判定する（ナビバーアイテムを作ってそこにaddGestureしても良い）
    UILongPressGestureRecognizer *longPressGesture =
    [[UILongPressGestureRecognizer alloc]
     initWithTarget:self action:@selector(longPress:)];
    [self.navigationController.navigationBar addGestureRecognizer:longPressGesture];
}

-(void)popBack{
    NSLog(@"%s", __func__);
    
    [self.navigationController popViewControllerAnimated:YES];
}

//長押しで最初に戻る
-(void)backToRoot{
    NSLog(@"backToRoot");
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}



//バックボタンはreadOnlyなのでaddGestureを付与したカスタムビューを配置することはできない
//のでロングタップしてから離した時の位置を取得して該当範囲内であればルートビューに戻る
- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // set a default rectangle in case we don't find the back button for some reason
        CGRect rect = CGRectMake(0, 0, 100, 40);
        
        // iterate through the subviews looking for something that looks like it might be the right location to be the back button
        for (UIView *subview in self.navigationController.navigationBar.subviews){
            if (subview.frame.origin.x < 30){
                rect = subview.frame;
                break;
            }
        }
        
        // ok, let's get the point of the long press
        
        CGPoint longPressPoint = [sender locationInView:self.navigationController.navigationBar];
        
        // if the long press point in the rectangle then do whatever
        
        if (CGRectContainsPoint(rect, longPressPoint))
            [self backToRoot];
    }
}


@end
