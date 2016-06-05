//
//  WSFTable.m
//  EasySQLite
//
//  Created by WangShengFeng on 2016/6/2.
//  Copyright © 2016年 WangShengFeng. All rights reserved.
//

#import "WSFTable.h"

typedef NS_ENUM(NSInteger,ForeignKeyType){
    ///  not deferrable initially immediate
    ForeignKeyType_Not_Deferrable_Initially_Immediate = 0,//Default
    /// not deferrable initially deferred
    ForeignKeyType_Not_Deferrable_Initially_Deferred,
    /// not deferrable
    ForeignKeyType_Not_Deferrable,
    ///  deferrable initially immediate
    ForeignKeyType_Deferrable_Initially_Immediate,
    ///  deferrable
    ForeignKeyType_Deferrable,
};

@implementation WSFColumn
@end

@implementation WSFTable
@end
