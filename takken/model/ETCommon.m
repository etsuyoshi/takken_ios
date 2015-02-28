//
//  ETCommon.m
//  GetLicense
//
//  Created by EndoTsuyoshi on 2015/01/14.
//  Copyright (c) 2015年 com.endo. All rights reserved.
//

#import "ETCommon.h"

@implementation ETCommon

+(BOOL)isNull:(id)obj{
    if([obj isEqual:[NSNull null]] ||
       obj == nil){
        return YES;
    }
    return NO;
}

@end
