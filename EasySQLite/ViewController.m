//
//  ViewController.m
//  EasySQLite
//
//  Created by WangShengFeng on 2016/6/2.
//  Copyright © 2016年 WangShengFeng. All rights reserved.
//

#import "ViewController.h"
#import "SQLTable.h"
#import "EasySQLite.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *tableName = NSStringFromClass([SQLTable class]);
    
    WSFTable *table = [[WSFTable alloc] init];
    table.dataName = tableName;
    
    NSMutableArray *columns = [NSMutableArray array];
    
    ///Standard format: All Config by Here
    /*
     WSFColumn *colum0 = [WSFColumn dataWithDictionary:
     @{TDName:@"id", TDType:@(ColumnType_Integer),//column name and type
     TDIsPKey:@(0), TDIsAuto:@(0),//primary key and auto increment
     TDIsUnique:@(0), TDIsNotNull:@(0),//unique value and not null
     TDDefault:@"", TDCheck:@"",//default value and constraint
     TDFTable:@"", TDFKey:@""//foreign key tables and fields
     }];
     */
    WSFColumn *colum2 = [WSFColumn dataWithDictionary:@{TDName:@"userId",               TDType:@(ColumnType_Integer),TDIsPKey:@(1),TDIsNotNull:@(1)}];
    WSFColumn *colum3 = [WSFColumn dataWithDictionary:@{TDName:@"dataId",               TDType:@(ColumnType_Integer),TDIsPKey:@(1),TDIsNotNull:@(1)}];
    WSFColumn *colum4 = [WSFColumn dataWithDictionary:@{TDName:@"aMapId",             TDType:@(ColumnType_Integer),TDIsPKey:@(1),TDIsNotNull:@(1)}];
    WSFColumn *colum5 = [WSFColumn dataWithDictionary:@{TDName:@"dataType",           TDType:@(ColumnType_Integer)}];
    WSFColumn *colum6 = [WSFColumn dataWithDictionary:@{TDName:@"dataTitle",            TDType:@(ColumnType_Text)}];
    WSFColumn *colum7 = [WSFColumn dataWithDictionary:@{TDName:@"indent",               TDType:@(ColumnType_Text)}];
    WSFColumn *colum8 = [WSFColumn dataWithDictionary:@{TDName:@"dataLandMark",   TDType:@(ColumnType_Text)}];
    
    
    //[columns addObject:colum0];
    [columns addObject:colum2];
    [columns addObject:colum3];
    [columns addObject:colum4];
    [columns addObject:colum5];
    [columns addObject:colum6];
    [columns addObject:colum7];
    [columns addObject:colum8];
    
    table.dataColumnArray = columns;
    NSLog(@"doc: ------ > %@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]);
    
    //0.Set You Sqlite File : Must First step *****
    [EasySQLite setDBName:@"db.sqlite"];
    
    //1.CreateTable
    [[EasySQLite sharedInstance] createTable:table callBackBlock:^(NSError *error) {
        NSLog(@"ok");
    }];
    
    
    //2.Insert Object To Table
    SQLTable *tableObj = [[SQLTable alloc] init];
    //tableObj.id = 1;
    //PK
    tableObj.dataId = 2;
    tableObj.userId = 10046;
    tableObj.aMapId = 1001;
    
    tableObj.indent = @"indent3.14";
    tableObj.dataType = 3.14;
    tableObj.dataTitle = @"dataTitle3.14";
    tableObj.dataLandMark = @"dataLandMark3.14";
    [[EasySQLite sharedInstance] replaceOrInsertTableName:tableName data:tableObj callBackBlock:^(NSError *error) {
        NSLog(@"-----------replaceOrInsertTableName");
    }];

    //3.Get Data
    [[EasySQLite sharedInstance] getDataListByTable:tableName className:[SQLTable class]
                            wherePropertyDictionary:@{@"userId":@(10046),@"dataId":@(2),@"aMapId":@"1001"} success:^(NSArray *resArray) {
                                NSLog(@"Array = %@",resArray);
    } error:^(NSError *msg) {
        NSLog(@"msg = %@",msg);
    }];
    
    [[EasySQLite sharedInstance] getDataListOfTable:tableName sql:@"select * from SQLTable" modelClass:[SQLTable class] success:^(NSArray *resArray) {
        NSLog(@"Array = %@",resArray);
    } error:^(NSError *msg) {
        NSLog(@"msg = %@",msg);
    }];
    
    [[EasySQLite sharedInstance] getDataListOfTable:tableName sql:@"select * from SQLTable" success:^(NSArray *resArray) {
        NSLog(@"Array = %@",resArray);
    } error:^(NSError *msg) {
        NSLog(@"msg = %@",msg);
    }];
    
#if 1
    [[EasySQLite sharedInstance] deleteDataForTable:tableName wherePropertyDictionary:@{@"userId":@(10046),@"dataId":@(2),@"aMapId":@"1001"} callBackBlock:^(NSError *error) {
         NSLog(@"-----------deleteDataForTable");
    }];
#else
    [[EasySQLite sharedInstance] submitSQL:@"Delete From SQLTable Where aMapId = 1001 And userId = 10046 And dataId = 2;" callBackBlock:^(NSError *error) {
        NSLog(@"Delete From SQLTable Where aMapId = 1001 And userId = 10046 And dataId = 2;");
    }];
#endif
}

@end
