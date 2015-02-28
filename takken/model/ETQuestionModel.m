//
//  ETQuestionModel.m
//  GetLicense
//
//  Created by EndoTsuyoshi on 2015/01/14.
//  Copyright (c) 2015年 com.endo. All rights reserved.
//

#import "ETQuestionModel.h"

@implementation ETQuestionModel
/*
 SECT046,
 Q0020,
 "\U4e0d\U52d5\U7523\U306e\U76f8\U7d9a\U5bfe\U7b56\U304a\U3088\U3073\U76f8\U7d9a\U3068\U4fdd\U967a\U306e\U6d3b\U7528",
 "\U88ab\U76f8\U7d9a\U4eba\U306e\U6b7b\U4ea1\U306b\U3088\U308a\U3001\U76f8\U7d9a\U4eba\U306b\U4fdd\U967a\U91d1\U304c\U652f\U6255\U308f\U308c\U308b\U751f\U547d\U4fdd\U967a\U306b\U52a0\U5165\U3059\U308b\U3053\U3068\U306f\U3001\U7d0d\U7a0e\U8cc7\U91d1\U5bfe\U7b56\U306e1\U3064\U306b\U306a\U308a\U3046\U308b\U3002",
 "-",
 "-",
 "-",
 "-",
 "-",
 1,
 "\U6b63\U3057\U3044",
 "\U4e0d\U52d5\U7523\U3084\U81ea\U793e\U682a\U306a\U3069\U3001\U5206\U5272\U3084\U63db\U91d1\U304c\U96e3\U3057\U3044\U8ca1\U7523\U3092\U6240\U6709\U3057\U3066\U3044\U308b\U5834\U5408\U3001\U88ab\U76f8\U7d9a\U4eba\U3092\U5951\U7d04\U8005(\U4fdd\U967a\U6599\U8ca0\U62c5\U8005)\U30fb\U88ab\U4fdd\U967a\U8005\U3068\U3057\U3001\U76f8\U7d9a\U4eba\U3092\U4fdd\U967a\U91d1\U53d7\U53d6\U4eba\U3068\U3059\U308b\U751f\U547d\U4fdd\U967a\U5951\U7d04\U3092\U6d3b\U7528\U3059\U308b\U3053\U3068\U306f\U3001\U6709\U52b9\U306a\U7d0d\U7a0e\U8cc7\U91d1\U5bfe\U7b56\U3068\U306a\U308b\U3002",
 ""
 )
 */
-(id)initWithArray:(NSArray *)arrArg{
    self = [super init];
    
    if(self){
        self.strSector = arrArg[0];
        self.strNo = arrArg[1];
        self.strCategory = arrArg[2];
        self.strQuestion = arrArg[3];
        //3-7は選択肢:今回は正誤の２択なので該当アイテムなし
        self.strAnswerNo = arrArg[9];
        self.strAnswerText = arrArg[10];
        self.strComment = arrArg[11];
        
        self.strOther =
        [NSString stringWithFormat:@"%@+%@+%@+%@+%@",
         arrArg[4],
         arrArg[5],
         arrArg[6],
         arrArg[7],
         arrArg[8]];
    }
    
    return self;
    
}

//SECT001,Q0010,ファイナンシャルプランニングと倫理及び関連法規,ファイナンシャル・プランナーとして業務を行う者は、「個人情報の保護に関する法律」で定める個人情報取り扱い事業者に該当しない場合であっても、職業倫理上、顧客の個人情報に関する守秘義務を遵守することが求められる。,-,-,-,-,-,1,正しい,個人情報取り扱い事業者に該当するのは5000人以上の個人情報を取り扱う者だが、ファイナンシャル・プランナー(FP)は職業倫理として、守秘義務の遵守が求められる。,

@end
