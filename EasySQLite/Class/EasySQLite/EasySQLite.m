//
//  EasySQLite.m
//  EasySQLite
//
//  Created by WangShengFeng on 2016/6/2.
//  Copyright © 2016年 WangShengFeng. All rights reserved.
//

#import "EasySQLite.h"


NSString * const        WSFOpenErrorDomain = @"WSFOpenErrorDomain";
NSInteger const         WSFOpenErrorCode = 1986211;
#define                      WSFOpenErrorUserInfo  @{@"ErrorMsg":@"DB Open Failed!"}


NSString * const        WSFExecErrorDomain = @"WSFExecErrorDomain";
NSInteger const         WSFExecErrorCode = 1986212;
#define                      WSFExecErrorUserInfo  @{@"ErrorMsg":@"DB Exec Failed!"}


NSString * const WSFQueryErrorDomain = @"WSFQueryErrorDomain";
NSInteger const  WSFQueryErrorCode = 1986103;
#define               WSFQueryErrorUserInfo  @{@"ErrorMsg":@"DB Query Failed!"}

/*
typedef NS_ENUM(NSInteger,OnDelete){
    OnDelete_No_Action = 0,
    OnDelete_Restrict,//限定
    OnDelete_Set_Null,//设置为Null
    OnDelete_Set_Default,//设置默认值
    OnDelete_Cascade,//同步处理
};

typedef NS_ENUM(NSInteger,OnUpdate){
    OnUpdate_No_Action = 0,
    OnUpdate_Restrict,//限定
    OnUpdate_Set_Null,//设置为Null
    OnUpdate_Set_Default,//设置默认值
    OnUpdate_Cascade,//同步处理
};
*/

@interface EasySQLite (){
    sqlite3* _db;
}
@property (nonatomic,strong) NSOperationQueue *sqlQueue;
@property (nonatomic, strong)  dispatch_queue_t mainQueue;
@property (nonatomic, copy) NSString *dataSQLDB;
@end

static EasySQLite *_sharedInstance;

@implementation EasySQLite

#pragma mark -
#pragma mark - private
- (void)executeSQL:(NSString*)sqlString callBack:(callBackBlock)callback{
    if ([self dbOpen]) {
        char *error;
        BOOL isOK = (SQLITE_OK == sqlite3_exec(_db, [sqlString UTF8String], NULL, NULL, &error));
        if(NULL != error || !isOK){
            NSDictionary *userInfo = WSFExecErrorUserInfo;
            if(NULL != error){
                userInfo = @{@"ErrorMsg":[NSString stringWithCString:error encoding:NSUTF8StringEncoding]};
            }
            NSError *error = [NSError errorWithDomain:WSFExecErrorDomain code:WSFExecErrorCode userInfo:userInfo];
            NSLog(@"--------------executeSQL:%@",error);
            if(callback)callback(error);
        }else{
            if(callback)callback(nil);
        }
        sqlite3_free(error);
    }
}

- (BOOL)dbOpen{
    return (sqlite3_open([_dataSQLDB UTF8String], &_db) == SQLITE_OK);
}
- (BOOL)dbClose{
    return (sqlite3_close(_db) == SQLITE_OK);
}
-(NSString *)getSQLType:(ColumnType)type{
    NSString *cType = @"TEXT";
    switch (type) {
        case ColumnType_Integer:
            cType = @"INTEGER";
            break;
        case ColumnType_BLOB:
            cType = @"BLOB";
            break;
        case ColumnType_Real:
            cType = @"REAL";
            break;
        case ColumnType_Numeric:
            cType = @"NUMERIC";
            break;
        default: break;
    }
    return cType;
}
#pragma mark -
#pragma mark - LifeCyle
+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super allocWithZone:zone];

        NSOperationQueue *sqlQueue = [[NSOperationQueue alloc] init];
        sqlQueue.maxConcurrentOperationCount = 10;
        sqlQueue.name = @"EasySqlite";
        
        _sharedInstance.sqlQueue = sqlQueue;
        _sharedInstance.mainQueue = dispatch_queue_create("EasySqlite",DISPATCH_QUEUE_SERIAL);
    });
    return _sharedInstance;
}
+(id)sharedInstance{
    return  [self setDBName:nil];
}
+(id)setDBName:(NSString *)dbName{
    BOOL isFirst = nil == _sharedInstance;
    EasySQLite *sqlM = [[self alloc] init];
    if(isFirst && dbName.length>0)[sqlM setUpDBFileName:dbName];
    return sqlM;
}
-(void)setUpDBFileName:(NSString *)dbName{
    self.dataSQLDB = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:dbName];
    
    [self submitSQL:@"PRAGMA FOREIGN_KEYS = ON;" callBackBlock:nil];
}
#pragma mark -
#pragma mark - Methods

-(void)submitSQL:(NSString *)sql callBackBlock:(callBackBlock)callBack{
    NSLog(@"submitSQL: %@",sql);
    dispatch_sync(self.mainQueue, ^{
        [self executeSQL:sql callBack:^(NSError *error) {
            if(callBack)callBack(error);
        }];
    });
}
-(void)createTable:(WSFTable *)table callBackBlock:(callBackBlock)callBack{
    if(nil == table || ![table isKindOfClass:[WSFTable class]]){
        return;
    }
    /*
      CREATE TABLE "Tables" ("indent" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, "userId" TEXT, "dataId" TEXT, "aMapId" TEXT, "dataType" TEXT, "dataTitle" TEXT, "dataLandMark" TEXT, "insertTime" TEXT NOT NULL DEFAULT 'M' REFERENCES "TableA" ("dataId") ON DELETE CASCADE ON UPDATE SET DEFAULT NOT DEFERRABLE INITIALLY IMMEDIATE)
     */
    NSString *tableName = table.dataName;
    NSArray *columnArray = table.dataColumnArray;
    
    NSMutableString *sqlTable = [NSMutableString string];
    [sqlTable appendFormat:@"CREATE TABLE IF NOT EXISTS \"%@\" ( ",tableName];
    
    NSMutableArray *pkArray = [NSMutableArray array];
    
    NSInteger index = 0;
    NSInteger count = columnArray.count;
    
    for (WSFColumn *c in columnArray) {
        
        NSString *columnName = c.dataName;
        ColumnType cType = c.dataType;
        
        NSString *cName = [NSString stringWithFormat:@"\"%@\" ",columnName];
        [sqlTable appendStringBlank:cName];
        [sqlTable appendStringBlank:[self getSQLType:cType]];
        if(c.dataIsPrimaryKey){
            [pkArray addObject:cName];
            //[sqlTable appendStringBlank:@"PRIMARY KEY"];
        }
        if(c.dataIsAutoincrement){
            if(ColumnType_Integer == cType){
                [sqlTable appendStringBlank: @"AUTOINCREMENT"];
            }
        }
        if(c.dataIsNotNull){
            [sqlTable appendStringBlank: @"NOT NULL"];
        }
        if(c.dataIsUnique){
            [sqlTable appendStringBlank: @"UNIQUE"];
        }
        NSString *check = c.dataCheck;
        if(check.length>0){
            [sqlTable appendFormat: @"CHECK (%@) ",check];
        }
        //DEFAULT 'M'
        NSString *defaults = c.dataDefault;
        if(defaults.length>0){
            [sqlTable appendStringBlank:defaults];
        }
        
        //外键
        NSString *ft = c.dataForeignTable;
        NSString *fk = c.dataForeignKey;
        if(nil != ft && ft.length>=1 && nil != fk && fk.length>=1 ){
            //外键:References "tablea" ("dataid") On Delete Cascade On Update Set Default Not Deferrable Initially Immediate)
            [sqlTable appendStringBlank:@"REFERENCES"];
            [sqlTable appendFormat:@"\"%@\" (\"%@\") ",ft,fk];
            [sqlTable appendStringBlank:@"ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE INITIALLY IMMEDIATE"];
        }
        
        if(count != ++index){
            [sqlTable appendString: @","];
        }
    }
    if([pkArray count] > 0){
        [sqlTable appendString: @","];
        NSString *columNs = [pkArray componentsJoinedByString: @","];
        [sqlTable appendFormat: @"PRIMARY KEY (%@)",columNs];
    }
    
    [sqlTable appendString:@");"];
    
    [self submitSQL:sqlTable callBackBlock:^(NSError *error) {
        if(callBack)callBack(error);
    }];
}


- (void)getDataListOfTable:(NSString*)tableName sql:(NSString *)sql success:(void(^)(NSArray* resArray))success error:(void(^)(NSError* msg))error{
    dispatch_async(self.mainQueue, ^{
        if (![self dbOpen] || tableName.length<=0 || sql.length<=0 ) {
            NSError* msg = [NSError errorWithDomain:WSFOpenErrorDomain code:WSFOpenErrorCode userInfo:WSFOpenErrorUserInfo];
            error(msg);
            return;
        }
        sqlite3_stmt * statement;
        NSMutableArray* successArray = [NSMutableArray array];
        NSMutableArray* allKeyArray = [NSMutableArray array];
        //
        NSString* keyString = [NSString stringWithFormat:@"Pragma table_info(%@)",tableName];
        if (sqlite3_prepare_v2(_db, [keyString UTF8String], -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                [allKeyArray addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
            }
        }
        NSString *allKeys = [allKeyArray componentsJoinedByString:@","];
        NSString *sqlString = [NSString stringWithFormat:@"Select %@ From %@",allKeys,tableName];
        if(sql.length >= 1){
            sqlString = [NSMutableString stringWithString:sql];
        }
        if (sqlite3_prepare_v2(_db, [sqlString UTF8String], -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSMutableDictionary* dic = [NSMutableDictionary dictionary];
                for (int i=0;i<allKeyArray.count;i++) {
                    NSString* key = allKeyArray[i];
                    char *value = (char *)sqlite3_column_text(statement, i);
                    NSString *valueStr = [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
                    [dic setValue:valueStr forProperty:key];
                }
                [successArray addObject:dic];
            }
            success(successArray);
        }else{
            NSError* msg = [NSError errorWithDomain:WSFQueryErrorDomain code:WSFQueryErrorCode userInfo:WSFQueryErrorUserInfo];
            error(msg);
        }
        [self dbClose];
    });
}


- (void)getDataListOfTable:(NSString*)tableName sql:(NSString *)sql modelClass:(Class)class success:(void(^)(NSArray* resArray))success error:(void(^)(NSError* msg))error{
    dispatch_async(self.mainQueue, ^{
        [self getDataListOfTable:tableName sql:sql success:^(NSArray *resArray) {
            NSMutableArray *dataArray = [NSMutableArray array];
            for (NSInteger i = 0; i<resArray.count; i++) {
                [dataArray addObject:[class dataWithDictionary:resArray[i]]];
            }
            if(success)success(dataArray);
        } error:^(NSError *msg) {
            if(error)error(msg);
        }];
    });
}
#pragma mark -
#pragma mark - Methods
-(void)replaceOrInsertTableName:(NSString*)tableName data:(NSObject *)tableObj callBackBlock:(callBackBlock)callBack{
    
   NSArray *pvArray = [[tableObj class] getPropertyList];
    NSInteger count = pvArray.count;
    NSMutableString *subSqlString = [NSMutableString stringWithString:@"("];
    
    for (NSInteger i=0; i < count; i++) {
        NSString *pName = pvArray[i];
        [subSqlString appendFormat:@"\"%@\"",pName];
        
        if(i<count-1){
            [subSqlString appendStrings:@" ,"];
        }else{
            [subSqlString appendString:@")"];
        }
    }
    
//    if([subSqlString hasSuffix:@","]){
//        NSRange range = [subSqlString rangeOfString:@"," options:NSBackwardsSearch];
//        if(range.location != NSNotFound){
//            [subSqlString substringToIndex:range.location];
//        }
//    }
    
    //values
    [subSqlString appendString:@"values("];
    for (NSInteger i=0; i < count; i++) {
        NSString *pName = pvArray[i];
        id value= [tableObj valueForProperty:pName];
        [subSqlString appendFormat:@"\"%@\"",value];
        
        if(i<count-1){
            [subSqlString appendStrings:@" ,"];
        }else{
            [subSqlString appendString:@")"];
        }
    }
    
    NSString *insertOrUpdate = [NSString stringWithFormat:@"Replace Into %@%@",tableName,subSqlString];
    [self submitSQL:insertOrUpdate callBackBlock:^(NSError *error) {
        if(callBack)callBack(error);
    }];
}
-(void)getDataListByTable:(NSString*)tableName className:(Class )class wherePropertyDictionary:(NSDictionary *)propertyDictionary success:(void(^)(NSArray* resArray))success error:(void(^)(NSError* msg))error{
    NSMutableString *whereSQL = [NSMutableString string];
    NSInteger count = propertyDictionary.count;
    NSArray *propertyList = [propertyDictionary allKeys];
    
    for (int i=0; i < count; i++) {
        if(whereSQL.length<=0){
            [whereSQL appendString:@" Where "];
        }
        NSString *pName = propertyList[i];
        NSString *value = [NSString stringWithFormat:@"%@",[propertyDictionary valueForKey:pName]];
        [[[whereSQL appendStrings:pName] appendStrings:@" = "] appendStrings:value];
        if(i<count-1){
            [whereSQL appendStrings:@" And "];
        }
    }
    NSString *selectSql = [NSString stringWithFormat:@"Select * From %@%@;",tableName,whereSQL];
    
    dispatch_async(self.mainQueue, ^{
        [self getDataListOfTable:tableName sql:selectSql modelClass:class success:^(NSArray *resArray) {
            if(success)success(resArray);
        } error:^(NSError *msg) {
            if(error)error(msg);
        }];
    });
}
-(void)deleteDataForTable:(NSString*)tableName wherePropertyDictionary:(NSDictionary *)propertyDictionary callBackBlock:(callBackBlock)callBack{
    NSMutableString *whereSQL = [NSMutableString string];
    NSInteger count = propertyDictionary.count;
    NSArray *propertyList = [propertyDictionary allKeys];
    
    for (int i=0; i < count; i++) {
        if(whereSQL.length<=0){
            [whereSQL appendString:@" Where "];
        }
        NSString *pName = propertyList[i];
        NSString *value = [NSString stringWithFormat:@"%@",[propertyDictionary valueForKey:pName]];
        [[[whereSQL appendStrings:pName] appendStrings:@" = "] appendStrings:value];
        if(i<count-1){
            [whereSQL appendStrings:@" And "];
        }
    }
    NSString *submitSql = [NSString stringWithFormat:@"Delete From %@%@;",tableName,whereSQL];
    [self submitSQL:submitSql callBackBlock:^(NSError *error) {
        if(callBack)callBack(error);
    }];
}

@end
