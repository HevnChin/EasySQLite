//
//  WSFObject.h
//  EasySQLite
//
//  Created by WangShengFeng on 2016/6/2.
//  Copyright © 2016年 WangShengFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+WSFExtends.h"
#import "NSString+WSFExtends.h"

@interface SQLTable : NSObject
//@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger dataId;
@property (nonatomic, copy) NSString * indent;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, assign) NSInteger aMapId;
@property (nonatomic, assign) NSInteger dataType;
@property (nonatomic, copy) NSString *dataTitle;
@property (nonatomic, copy) NSString *dataLandMark;
/*
 CREATE TABLE "Tables" ("indent" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, "userId" TEXT, "dataId" TEXT, "aMapId" TEXT, "dataType" TEXT, "dataTitle" TEXT, "dataLandMark" TEXT, "insertTime" TEXT NOT NULL DEFAULT 'M' REFERENCES "TableA" ("dataId") ON DELETE CASCADE ON UPDATE SET DEFAULT NOT DEFERRABLE INITIALLY IMMEDIATE)
 */
@end
