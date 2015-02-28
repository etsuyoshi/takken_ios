//
//  ETCSVModel.m
//  GetLicense
//
//  Created by EndoTsuyoshi on 2015/01/14.
//  Copyright (c) 2015年 com.endo. All rights reserved.
//

#import "ETCSVModel.h"
#import "ETQuestionModel.h"
#import "CHCSVParser.h"
#import "ETCommon.h"
@implementation ETCSVModel

//self.arrQuestionModelsにデータを格納する
-(id)initWithCSVName:(NSString *)strFileName
      includingLabel:(BOOL)isFileIncludingLabel{//ファイルがラベルを含む場合はyes(最初の行を取り込まない)
    self = [super init];
    
    if([ETCommon isNull:strFileName]){
        return self;
    }
    
    NSURL *path =
    [NSURL fileURLWithPath:
     [[NSBundle mainBundle]
      pathForResource:strFileName//@"fp3_mod"
      ofType:@"csv"]];
    NSLog(@"path = %@", path);
    //    CHCSVParserOptions options = CHCSVParserOptionsSanitizesFields;
    
    
    
    NSArray *rows =
    [NSArray
     arrayWithContentsOfCSVURL:path
     options:CHCSVParserOptionsSanitizesFields];
    
    if(isFileIncludingLabel){
        if(rows.count>0){
            self.arrLabels = rows[0];//最初の行はラベル配列
        }else{
            self.arrLabels = [NSArray array];//要素数ゼロ配列
        }
    }

    //ファイルにラベルが入っているなら1行目から、そうでなければ0行目から取得する
    BOOL isSuccess =
    [self setArray:rows
          startRow:isFileIncludingLabel?1:0];
    if(isSuccess){
        NSLog(@"正常取り込み完了");
    }else{
        NSLog(@"取り込み時にエラー");
    }
    return self;
    
}

//initWithCSVNameにおいて配列をセットするモジュール
-(BOOL)setArray:(NSArray *)arr
       startRow:(int)startRow{
    NSError *error = nil;
    if (arr == nil) {
        //something went wrong; log the error and exit
        NSLog(@"error parsing file: %@", error);
        return false;
    }else{
        NSMutableArray *arrMutableTmp = [NSMutableArray array];
        ETQuestionModel *questionModel;
        NSRange range;
        for(int i = startRow;i < arr.count;i++){
            NSLog(@"trying to add row(%d) = %@", i, arr[i]);
            
            questionModel = [[ETQuestionModel alloc]initWithArray:arr[i]];
            
            range = [questionModel.strSector rangeOfString:@"SECT"];
            //最初の列がeof(end of file)でなければ配列追加する
//            if([questionModel.strSector isEqualToString:@"[EOF]"]){
            
            //一列目がsectを含む場合にのみ
            if(range.location != NSNotFound){//見つからなくない＝見つかった
                [arrMutableTmp addObject:questionModel];
                NSLog(@"%d行目はsectなので追加します", i);
            }
        }
        
        //mutableじゃなくする
        self.arrQuestionModels = (NSArray *)arrMutableTmp;
        return YES;
    }
}

//異なるカテゴリ名を格納した配列を返す
-(NSArray *)getArrCategories{
    
    NSMutableArray *arrSectNames = [NSMutableArray array];
    ETQuestionModel *questionModelNow;
    ETQuestionModel *questionModelNext;
    
    //最初に問題文が格納されている行=startRowを取得する
    //setArrayによって最初(index:0)に格納されているデータは問題文であることが担保されている(ラベルではない)
    int startRow = 0;
    [arrSectNames addObject:((ETQuestionModel *)self.arrQuestionModels[startRow]).strCategory];
    //次行以降で異なるセクター名があれば追加する
    for(int i = startRow+1;i < self.arrQuestionModels.count-1;i++){
        questionModelNow = self.arrQuestionModels[i];
        questionModelNext = self.arrQuestionModels[i+1];
        //i行がi+1行を比較して異なればi行のカテゴリをarrSectNamesに格納する
        if(![questionModelNext.strSector isEqualToString:questionModelNow.strSector]){
            [arrSectNames addObject:questionModelNow.strCategory];
        }
    }
    
    return (NSArray *)arrSectNames;
}
//指定したstrSectのみ格納する
-(NSArray *)getArrLimitedRangeWithSect:(NSString *)strSect{
    NSLog(@"%s : %@", __func__, strSect);
    NSMutableArray *arrMOld = [self.arrQuestionModels mutableCopy];
    NSMutableArray *arrMNew = [NSMutableArray array];
    ETQuestionModel *questionModel;
    for(int i =0;i < arrMOld.count;i++){
        questionModel = arrMOld[i];
        NSLog(@"add %d : %@", i, questionModel.strSector);
        
        if([questionModel.strSector isEqualToString:strSect]){
            //追加する
            [arrMNew addObject:questionModel];
        }else{
//            //strSectと異なるセクター番号であれば削除する
//            [arrMOld removeObjectAtIndex:i];
        }
    }
    
//    self.arrQuestionModels = (NSArray *)arrMNew;
    return (NSArray *)arrMNew;
}

@end
