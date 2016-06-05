//
//  WSFTable.h
//  EasySQLite
//
//  Created by WangShengFeng on 2016/6/2.
//  Copyright © 2016年 WangShengFeng. All rights reserved.
//

#import <Foundation/Foundation.h>


///字段类型
typedef NS_ENUM(NSInteger,ColumnType){
    ColumnType_Integer = 0,//INTEGER
    ColumnType_Text,//TEXT
    ColumnType_BLOB,//BLOB
    ColumnType_Real,//REAL
    ColumnType_Numeric,//NUMERIC
};

@interface WSFColumn : NSObject

///主线控制:--------------------------

///列名
#define TDName @"dataName"
///列类型
#define TDType @"dataType"
///列:主键
#define TDIsPKey @"dataIsPrimaryKey"
///列:自增
#define TDIsAuto @"dataIsAutoincrement"
///列:唯一
#define TDIsUnique @"dataIsUnique"
///列:默认值
#define TDDefault @"dataDefault"
///列:约束Check
#define TDCheck @"dataCheck"
///列:不许为空
#define TDIsNotNull @"dataIsNotNull"
///列:外键表
#define TDFTable @"dataForeignTable"
///列:外键表字段
#define TDFKey @"dataForeignKey"

///列名字
@property (nonatomic, copy) NSString *dataName;
///数据类型
@property (nonatomic, assign) ColumnType dataType;

///辅助控制:--------------------------

///是否自增
@property (nonatomic,assign) BOOL dataIsAutoincrement;
///是否不为空
@property (nonatomic, assign) BOOL dataIsNotNull;
///是否主键
@property (nonatomic, assign) BOOL dataIsPrimaryKey;
///是否唯一值
@property (nonatomic, assign) BOOL dataIsUnique;
///默认值 :DEFAULT
@property (nonatomic, copy) NSString *dataDefault;
///默认值 :Check
@property (nonatomic, copy) NSString *dataCheck;

///关联外键表-名字
@property (nonatomic, copy) NSString *dataForeignTable;
///关联外键表-字段
@property (nonatomic, copy) NSString *dataForeignKey;
@end


@interface WSFTable : NSObject
@property (nonatomic, copy) NSString *dataName;
@property (nonatomic, strong) NSArray *dataColumnArray; //WSFColumn
@end
