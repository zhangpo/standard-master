//
//  BSDataProvider.m
//  BookSystem
//
//  Created by Dream on 11-3-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSDataProvider.h"
#import "FMDatabase.h"
#import "Singleton.h"
#import "AKsNetAccessClass.h"
#import "AKsCanDanListClass.h"
#import "AKsYouHuiListClass.h"
#import "AKsCanDanListClass.h"
//#import "AKsNetAccessClass.h"
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonCrypto.h>
#import <AdSupport/AdSupport.h>
#import "OpenUDID.h"
#import "UIKitUtil.h"
#import "CardJuanClass.h"
#import "CVLocalizationSetting.h"
#import "NSObject+SBJSON.h"
#import "SBJSON.h"
//#import "PaymentSelect.h"


@implementation BSDataProvider

-(id)init
{
    self = [super init];
    if (self) {
        // Initialization cod
    }
    return self;
}
//PadId
-(NSString *)padID{
    NSString *deviceID=[[NSUserDefaults standardUserDefaults] objectForKey:@"PDAID"];
    AKsNetAccessClass *netaccess=[AKsNetAccessClass sharedNetAccess];
    netaccess.UserId=deviceID;
    return deviceID;
}
/**
 *  查询菜品类别
 *
 *  @return
 */
-(NSArray *)getClassById
{
    NSArray *array = [BSDataProvider getDataFromSQLByCommand:@"select * from class order by GRP asc"];
    
    return array;
}
//预定台位----可不用
-(void)reserveCache:(NSArray *)ary
{
    for (int i=0; i<ary.count; i++) {
        
        AKsCanDanListClass *caiList=[ary objectAtIndex:i];
        
        FMDatabase *db=[[FMDatabase alloc] initWithPath:[BSDataProvider sqlitePath]];
        if(![db open])
        {
            NSLog(@"数据库打开失败");
        }
        else
        {
            NSLog(@"数据库打开成功");
        }
        FMResultSet *rs = [db executeQuery:@"select * from food where itcode=?",caiList.pcode];
        NSString *class;
        while ([rs next]){
            class=[rs stringForColumn:@"class"];
        }
        NSString *qqq;
        if ([caiList.istc intValue]==1) {
            qqq=[NSString stringWithFormat:@"insert into AllCheck ('tableNum','orderId','Time','PKID','Pcode','PCname','Tpcode','TPNAME','TPNUM','pcount','promonum','fujiacode','fujianame','price','fujiaprice','Weight','Weightflg','unit','ISTC','Over','Urge' ,'man','woman' ,'Send','CLASS','CNT') values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum,[Singleton sharedSingleton].Time,caiList.pkid,caiList.pcode,caiList.pcname,caiList.tpcode,caiList.tpname,caiList.tpnum,@"1",caiList.promonum,caiList.fujiacode,caiList.fujianame,caiList.eachPrice,caiList.fujiaprice,caiList.weight,caiList.weightflag,caiList.unit,caiList.istc,caiList.pcount,@"0",[Singleton sharedSingleton].man,[Singleton sharedSingleton].woman,@"1",@"1",caiList.pcount];
        }
        else
        {
            qqq=[NSString stringWithFormat:@"insert into AllCheck ('tableNum','orderId','Time','PKID','Pcode','PCname','Tpcode','TPNAME','TPNUM','pcount','promonum','fujiacode','fujianame','price','fujiaprice','Weight','Weightflg','unit','ISTC','Over','Urge' ,'man','woman' ,'Send','CLASS','CNT') values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum,[Singleton sharedSingleton].Time,caiList.pkid,caiList.pcode,caiList.pcname,caiList.tpcode,caiList.tpname,caiList.tpnum,caiList.pcount,caiList.promonum,caiList.fujiacode,caiList.fujianame,caiList.eachPrice,caiList.fujiaprice,caiList.weight,caiList.weightflag,caiList.unit,caiList.istc,caiList.pcount,@"0",[Singleton sharedSingleton].man,[Singleton sharedSingleton].woman,@"1",@"1",@""];
        }
        [db executeUpdate:qqq];
        [db close];
    }
    
}
/**
 *  删除保存的套餐数据
 *
 *  @param tpcode 套餐编码
 *  @param num    套餐唯一标示
 */
-(void)delectcombo:(NSString *)tpcode andNUM:(NSString *)num
{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    NSMutableArray *array=[cacheDict objectForKey:[Singleton sharedSingleton].Time];
    for (NSDictionary *orderDic in array) {
        if ([[orderDic objectForKey:@"seat"] isEqualToString:[Singleton sharedSingleton].Seat]&&[[orderDic objectForKey:@"order"] isEqualToString:[Singleton sharedSingleton].CheckNum]) {
            NSMutableArray *food=[orderDic objectForKey:@"food"];
            if (food) {
            A:
                for (NSDictionary *dict in food) {
                    if ([[dict objectForKey:@"ITCODE"] isEqualToString:tpcode]&&[[dict objectForKey:@"TPNUM"]isEqualToString:num]) {
                        [food removeObject:dict];
                        goto A;
                        break;
                    }
                }
                NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:food,@"food",[Singleton sharedSingleton].CheckNum,@"order",[Singleton sharedSingleton].Seat,@"seat", nil];
                [array addObject:dict];
                [cacheDict setObject:array forKey:[Singleton sharedSingleton].Time];
                [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
                return;
            }
        }
    }
}
/**
 *  删除保存的单个菜品
 *
 *  @param code
 */
-(void)delectdish:(NSString *)code
{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    NSMutableArray *array=[cacheDict objectForKey:[Singleton sharedSingleton].Time];
    for (NSDictionary *orderDic in array) {
        if ([[orderDic objectForKey:@"seat"] isEqualToString:[Singleton sharedSingleton].Seat]&&[[orderDic objectForKey:@"order"] isEqualToString:[Singleton sharedSingleton].CheckNum]) {
            NSMutableArray *food=[orderDic objectForKey:@"food"];
            if (food) {
            A:
                for (NSDictionary *dict in food) {
                    if ([[dict objectForKey:@"ITCODE"] isEqualToString:code]) {
                        [food removeObject:dict];
                        goto A;
                        break;
                    }
                }
                NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:food,@"food",[Singleton sharedSingleton].CheckNum,@"order",[Singleton sharedSingleton].Seat,@"seat", nil];
                [array addObject:dict];
                [cacheDict setObject:array forKey:[Singleton sharedSingleton].Time];
                [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
                return;
            }
        }
    }
    
}
/**
 *  缓存菜品信息
 *
 *  @param ary 菜品
 */
-(void)cache:(NSArray *)ary
{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    NSMutableArray *array=nil;
    if ([cacheDict objectForKey:[Singleton sharedSingleton].Time]) {
        array=[NSMutableArray arrayWithArray:[cacheDict objectForKey:[Singleton sharedSingleton].Time]];
    }else
    {
        array=[[NSMutableArray alloc] init];
        [cacheDict setObject:array forKey:[Singleton sharedSingleton].Time];
    }
    NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:ary,@"food",[Singleton sharedSingleton].CheckNum,@"order",[Singleton sharedSingleton].Seat,@"seat", nil];
    [array addObject:dict];
    [cacheDict setObject:array forKey:[Singleton sharedSingleton].Time];
    [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
}
/**
 *  查询缓存的菜品
 *
 *  @return
 */
-(NSMutableArray *)selectCache
{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    NSMutableArray *array=[cacheDict objectForKey:[Singleton sharedSingleton].Time];
    for (NSDictionary *dict in array) {
        if ([[dict objectForKey:@"seat"] isEqualToString:[Singleton sharedSingleton].Seat]&&[[dict objectForKey:@"order"] isEqualToString:[Singleton sharedSingleton].CheckNum]) {
            return [dict objectForKey:@"food"];
        }
    }
    return nil;
}
/**
 *  删除缓存
 */
-(void)delectCache
{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
     NSMutableArray *array=[cacheDict objectForKey:[Singleton sharedSingleton].Time];
    for (NSDictionary *dict in array) {
        if ([[dict objectForKey:@"seat"] isEqualToString:[Singleton sharedSingleton].Seat]&&[[dict objectForKey:@"order"] isEqualToString:[Singleton sharedSingleton].CheckNum]) {
            [array removeObject:dict];
            [cacheDict setObject:array forKey:[Singleton sharedSingleton].Time];
            [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
            break;
        }
    }
    
}
/**
 *  附加项
 *
 *  @param pcode 菜品编码
 *
 *  @return
 */
- (NSArray *)getAdditions:(NSString *)pcode{
    NSMutableArray *ary = [BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from FoodFuJia where pcode=%@",pcode]];
    if ([ary count]==0) {
        ary=[BSDataProvider getDataFromSQLByCommand:@"select * from FoodFuJia where length(PCODE)=0 OR pcode like '%PCODE%'"];
    }
    return [NSArray arrayWithArray:ary];
}
/**
 *  webPos查询公共附加项
 *
 *  @return
 */
-(NSArray *)getAdditionsAndClass
{
    NSMutableArray * ary=[NSMutableArray array];
    NSArray *array=[BSDataProvider getDataFromSQLByCommand:@"select pk_redefine_type from redefine_type"];
    for (NSDictionary * dict in array) {
        NSArray *arry=[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"SELECT * FROM redefine_type a LEFT JOIN FoodFuJia b WHERE a.pk_redefine_type=b.rgrp and b.rgrp='%@' AND (b.PCODE ='' or b.PCODE='~_PCODE_~')",[dict objectForKey:@"pk_redefine_type"]]];
        [ary addObject:arry];
    }
    return ary;
}
-(NSArray *)SelectPrivateAddition:(NSString *)pcode
{
    NSMutableArray * ary=[NSMutableArray array];
    NSArray *array=[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select PRODUCTTC_ORDER from foodfujia where pcode='%@'  GROUP BY PRODUCTTC_ORDER",pcode]];
    for (NSDictionary * dict in array) {
        NSMutableArray *arry=[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from foodfujia where PRODUCTTC_ORDER='%@' and pcode ='%@' ORDER BY DEFUALTS ASC",[dict objectForKey:@"PRODUCTTC_ORDER"],pcode]];
        [ary addObject:arry];
    }
    return ary;
}
/**
 *  退菜原因
 *
 *  @return
 */
-(NSArray *)chkCodesql{
    NSMutableArray *ary = [BSDataProvider getDataFromSQLByCommand:@"select * from ERRORCUSTOM where STATE=1"];
    return ary;
}

/**
 *  估清接口
 *
 *  @return 估清的菜品编码
 */
-(NSArray *)soldOut
{
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@",[self padID],[NSString stringWithFormat:@"%@",[[Singleton sharedSingleton].userInfo objectForKey:@"user"]]];
    NSDictionary *dict = [self bsService:@"soldOut" arg:strParam];
    NSMutableArray *array=[NSMutableArray array];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:soldOutResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary=[result componentsSeparatedByString:@"@"];
        if ([[ary objectAtIndex:0] intValue]==0) {
            for (int i=1; i<[ary count]; i++) {
                [array addObject:[ary objectAtIndex:i]];
            }
        }
    }
    return array;
}
/**
 *  预打印接口
 *
 *  @return
 */
-(NSDictionary *)priPrintOrder:(NSDictionary *)info
{
    
    NSString *pdanum = [NSString stringWithFormat:@"%@",[self padID]];
    NSString *user=[NSString stringWithFormat:@"%@",[[Singleton sharedSingleton].userInfo objectForKey:@"user"]];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@&json=%@",pdanum,user,[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum,[info JSONRepresentation]];
    
    NSDictionary *dict = [self bsService:@"PrintOrder" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:priPrintOrderResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        if ([[ary objectAtIndex:0] intValue]==0) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }else
        {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }

    }else
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"打印失败",@"Message", nil];
    }
}

/**
 *  并台修改数据库
 *
 *  @param dict
 *  @param cheak
 */
-(void)updatecombineTable:(NSDictionary *)dict :(NSString *)cheak
{
    NSMutableArray *array=[NSMutableArray array];
    [array addObject:[dict objectForKey:@"newtable"]];
    [array addObject:[dict objectForKey:@"oldtable"]];
    for (int i=0; i<[array count]; i++) {
        FMDatabase *db=[[FMDatabase alloc] initWithPath:[BSDataProvider sqlitePath]];
        if(![db open])
        {
            return;
        }
        
        //    NSString *str1=[NSString stringWithFormat:@"select * from AllCheck where tableNum='%@' and Time='%@'"
        NSString *str=[NSString stringWithFormat:@"UPDATE AllCheck SET orderId = '%@' WHERE tableNum = '%@' and Time='%@'",cheak,[array objectAtIndex:i],[Singleton sharedSingleton].Time];
        NSLog(@"%@",str);
        [db executeUpdate:str];
        [db close];
    }
}
/**
 *  换台修改数据库
 *
 *  @param info
 *  @param cheak
 */
-(void)updateChangTable:(NSDictionary *)info :(NSString *)cheak
{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    NSMutableArray *array=[cacheDict objectForKey:[Singleton sharedSingleton].Time];
    for (NSDictionary *orderDic in array) {
        if ([[orderDic objectForKey:@"seat"] isEqualToString:[info objectForKey:@"oldtable"]]&&[[orderDic objectForKey:@"order"] isEqualToString:cheak]) {
            [orderDic setValue:[info objectForKey:@"newtable"] forKey:@"seat"];
//            NSMutableArray *food=[orderDic objectForKey:@"food"];
//            if (food) {
//            A:
//                for (NSDictionary *dict in food) {
//                    if ([[dict objectForKey:@"ITCODE"] isEqualToString:code]) {
//                        [food removeObject:dict];
//                        goto A;
//                        break;
//                    }
//                }
//                NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:food,@"food",[Singleton sharedSingleton].CheckNum,@"order",[Singleton sharedSingleton].Seat,@"seat", nil];
//                [array addObject:dict];
                [cacheDict setObject:array forKey:[Singleton sharedSingleton].Time];
                [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
//                return;
//            }
        }
    }
//    FMDatabase *db=[[FMDatabase alloc] initWithPath:[BSDataProvider sqlitePath]];
//    if(![db open])
//    {
//    }
//    NSString *str=[NSString stringWithFormat:@"UPDATE AllCheck SET tableNum = '%@' WHERE tableNum = '%@' and orderId='%@'",[info objectForKey:@"newtable"],[info objectForKey:@"oldtable"],cheak];
//    NSLog(@"%@",str);
//    [db executeUpdate:str];
//    [db close];
}
/**
 *  手势划菜
 *
 *  @param info
 *  @param tag
 *
 *  @return
 */
-(NSString *)scratch:(NSDictionary *)info andtag:(int)tag
{
    NSMutableString *fanfood=[NSMutableString string];
    if ([info objectForKey:@"fujiacode"]==nil) {
        [info setValue:@"" forKey:@"fujiacode"];
    }
    if ([info objectForKey:@"Weightflg"]==nil) {
        [info setValue:@"" forKey:@"Weightflg"];
    }
    [fanfood appendFormat:@"%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@",[info objectForKey:@"Pcode"],[info objectForKey:@"Tpcode"],[info objectForKey:@"TPNUM"],[info objectForKey:@"fujiacode"],[info objectForKey:@"Weightflg"],[info objectForKey:@"ISTC"],[info objectForKey:@"count"],[info objectForKey:@"PKID"],[info objectForKey:@"Sublistid"],[info objectForKey:@"UnitCode"],[info objectForKey:@"istemp"]];
    [fanfood appendString:@";"];
    if (tag==0) {
        //        if ([[info objectForKey:@"Over"] intValue]==[[info objectForKey:@"pcount"] intValue]) {
        //        NSString *str2;
        NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&orderId=%@&tableNum=%@&productList=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[Singleton sharedSingleton].CheckNum,[Singleton sharedSingleton].Seat,fanfood];
        NSDictionary *dict = [self bsService:@"reCallElide" arg:strParam];
        NSString *result = [[[dict objectForKey:@"ns:reCallElideResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        return result;
    }else
    {
        //        NSString *str;
        NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&orderId=%@&tableNum=%@&productList=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[Singleton sharedSingleton].CheckNum,[Singleton sharedSingleton].Seat,fanfood];
        NSDictionary *dict = [self bsService:@"callElide" arg:strParam];
        NSString *result = [[[dict objectForKey:@"ns:callElideResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        return result;
    }
}
/**
 *  划菜按钮
 *
 *  @param dish
 *
 *  @return
 */
-(NSString *)scratch:(NSArray *)dish
{
    //    NSString *pdaid = [NSString stringWithFormat:@"%@",[self padID]];
    //    user = [NSString stringWithFormat:@"%@",[[Singleton sharedSingleton].userInfo objectForKey:@"user"]];
    NSMutableString *mutfood = [NSMutableString string];
    NSMutableString *fanfood=[NSMutableString string];
//    http://192.168.0.63:8080/ChoiceWebService/services/HHTSocket?/reCallElide?&deviceId=24&userCode=5&orderId=H000004&tableNum=23&productList=1119@@0@@@0@1@10011H00000420150413181500364271@@@1;
//    http://192.168.0.63:8080/ChoiceWebService/services/HHTSocket?/callElide?&deviceId=24&userCode=5&orderId=H000004&tableNum=23&productList=1119@@0@@@0@1@10011H00000420150413181500364271@@1;
    for (NSDictionary *info in dish) {
        if ([[info objectForKey:@"Over"] intValue]==[[info objectForKey:@"pcount"] intValue]) {
            if ([info objectForKey:@"fujiacode"]==nil) {
                [info setValue:@"" forKey:@"fujiacode"];
            }
            if ([info objectForKey:@"Weightflg"]==nil) {
                [info setValue:@"" forKey:@"Weightflg"];
            }
            [fanfood appendFormat:@"%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@",[info objectForKey:@"Pcode"],[info objectForKey:@"Tpcode"],[info objectForKey:@"TPNUM"],[info objectForKey:@"fujiacode"],[info objectForKey:@"Weightflg"],[info objectForKey:@"ISTC"],[info objectForKey:@"pcount"],[info objectForKey:@"PKID"],[info objectForKey:@"Sublistid"],[info objectForKey:@"UnitCode"],[info objectForKey:@"istemp"]];
//            [mutDic setValue:[itemAry objectAtIndex:24] forKey:@"fujiaCount"];
//            [mutDic setValue:[itemAry objectAtIndex:25] forKey:@"Sublistid"];
//            [mutDic setValue:[itemAry objectAtIndex:26] forKey:@"UnitCode"];
//            [mutDic setValue:[itemAry objectAtIndex:27] forKey:@"unitName"];
//            [mutDic setValue:[itemAry objectAtIndex:28] forKey:@"istemp"];
            [fanfood appendString:@";"];
        }
        else
        {
            if ([info objectForKey:@"fujiacode"]==nil) {
                [info setValue:@"" forKey:@"fujiacode"];
            }
            if ([info objectForKey:@"Weightflg"]==nil) {
                [info setValue:@"" forKey:@"Weightflg"];
            }
            [mutfood appendFormat:@"%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@",[info objectForKey:@"Pcode"],[info objectForKey:@"Tpcode"],[info objectForKey:@"TPNUM"],[info objectForKey:@"fujiacode"],[info objectForKey:@"Weightflg"],[info objectForKey:@"ISTC"],[info objectForKey:@"pcount"],[info objectForKey:@"PKID"],[info objectForKey:@"Sublistid"],[info objectForKey:@"UnitCode"],[info objectForKey:@"istemp"]];
            [mutfood appendString:@";"];
        }
    }
    NSLog(@"%@",mutfood);
    NSString *str1;
    if (![mutfood isEqualToString:@""]) {
        NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&orderId=%@&tableNum=%@&productList=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[Singleton sharedSingleton].CheckNum,[Singleton sharedSingleton].Seat,mutfood];
        NSDictionary *dict = [self bsService:@"callElide" arg:strParam];
        NSString *result = [[[dict objectForKey:@"ns:callElideResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        str1=result;
    }
    if (![fanfood isEqualToString:@""]) {
        NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&orderId=%@&tableNum=%@&productList=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[Singleton sharedSingleton].CheckNum,[Singleton sharedSingleton].Seat,fanfood];
        NSDictionary *dict = [self bsService:@"reCallElide" arg:strParam];
        NSString *result = [[[dict objectForKey:@"ns:reCallElideResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        //        NSArray *ary = [result componentsSeparatedByString:@"@"];
        if (str1==nil) {
            str1=result;
        }
    }
    return str1;
}
/**
 *  查询全单附加项
 *
 *  @return
 */
-(NSArray *)specialremark//查询全单附加项
{
    NSMutableArray *ary = [BSDataProvider getDataFromSQLByCommand:@"select * from specialremark"];
    return [NSArray arrayWithArray:ary];
}
/**
 *  查询赠菜原因
 *
 *  @return
 */
-(NSArray *)presentreason
{
    NSMutableArray *ary = [BSDataProvider getDataFromSQLByCommand:@"select * from presentreason"];
    return [NSArray arrayWithArray:ary];
}
/**
 *  数据库划菜
 *
 *  @param table 台位号
 *  @param order 账单号
 *  @param pkid  菜品标示
 *  @param code  编码
 *  @param over  划菜数量
 *
 *  @return
 */
+(int)updata:(NSString *)table orderID:(NSString *)order pkid:(NSString *)pkid code:(NSString *)code Over:(NSString *)over;{
    FMDatabase *db=[[FMDatabase alloc] initWithPath:[BSDataProvider sqlitePath]];
    if(![db open])
    {
    }
    if ([over isEqualToString:@"0"]) {
        [db executeUpdate:@"UPDATE AllCheck SET Over = ? WHERE tableNum = ? and orderId=? and PKID=? and Pcode=?",@"1",table,order,pkid,code];
    }
    else
    {
        [db executeUpdate:@"UPDATE AllCheck SET Over = ? WHERE tableNum = ? and orderId=? and PKID=? and Pcode=?",@"0",table,order,pkid,code];
    }
    FMResultSet *rs=[db executeQuery:@"select * from AllCheck where Over=0 and tableNum = ? and orderId=?",table,order];
    int i=0;
    while ([rs next]) {
        i++;
    }
    [db close];
    return i;
}
/**
 *  改变台位状态
 *
 *  @param info
 *
 *  @return
 */
-(NSDictionary *)changTableState:(NSDictionary *)info
{
    NSString *pdanum = [NSString stringWithFormat:@"%@",[self padID]];
    //    NSString *tableNum=[info objectForKey:@"tableNum"];
    NSString *currentState=[info objectForKey:@"currentState"];
    NSString *nextState=[info objectForKey:@"nextState"];
    NSString *api=[NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&currentState=%@&nextState=%@",pdanum,[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[Singleton sharedSingleton].Seat,currentState,nextState];
    NSDictionary *dict = [self bsService:@"changTableState" arg:api];
    NSLog(@"%@",dict);
    return dict;
}
/**
 *  换台
 *
 *  @param info 换台信息
 *
 *  @return
 */
- (NSDictionary *)pChangeTable:(NSDictionary *)info{
    //+changetable<pdaid:%s;user:%s;oldtable:%s;newtable:%s;>\r\n")},//6.换台changetable
    //+changetable<pdaid:%s;user:%s;oldtable:%s;newtable:%s;>\r\n
    NSString *pdaid,*user,*oldtable,*newtable,*pwd,*orderId;
    pdaid = [NSString stringWithFormat:@"%@",[self padID]];
    user = [[Singleton sharedSingleton].userInfo objectForKey:@"user"];
    NSLog(@"%@",user);
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@%@",user,pwd];
    oldtable = [info objectForKey:@"oldtable"];
    newtable = [info objectForKey:@"newtable"];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tablenumSource=%@&tablenumDest=%@",pdaid,user,oldtable,newtable];
    NSDictionary *dict = [self bsService:@"pSignTeb" arg:strParam];
    return dict;
}

/**
 *  并台
 *
 *  @param info 并台信息
 *
 *  @return
 */
-(NSDictionary *)combineTable:(NSDictionary *)info
{
    NSString *pdaid,*user,*oldtable,*newtable,*pwd;
    pdaid = [NSString stringWithFormat:@"%@",[self padID]];
    user = [[Singleton sharedSingleton].userInfo objectForKey:@"user"];
    NSLog(@"%@",user);
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@%@",user,pwd];
    oldtable = [info objectForKey:@"oldtable"];
    newtable = [info objectForKey:@"newtable"];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableList=%@@%@",pdaid,user,oldtable,newtable];
    NSDictionary *dict = [self bsService:@"combineTable" arg:strParam];
    NSLog(@"%@",dict);
    return dict;
}

//查询台位菜品
-(NSMutableArray *)queryProduct1:(NSString *)seat
{
    NSString *pdanum = [NSString stringWithFormat:@"%@",[self padID]];
    NSString *user=[NSString stringWithFormat:@"%@",[[Singleton sharedSingleton].userInfo objectForKey:@"user"]];
    NSString *tableNum=seat;
    NSString *api=[NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=&manCounts=%@&womanCounts=%@&orderId=%@&chkCode=%@&comOrDetach=%@",pdanum,user,@"",@"",seat,@"",@"0"];
    NSDictionary *dict = [self bsService:@"queryProduct" arg:api];
    NSString *result = [[[dict objectForKey:@"ns:queryProductResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
    if ([[[result componentsSeparatedByString:@"@"] objectAtIndex:0] intValue]==0) {
        [Singleton sharedSingleton].CheckNum=[[result componentsSeparatedByString:@"@"] objectAtIndex:1];
        
    }
    NSMutableArray *array1=[[NSMutableArray alloc] init];
    NSArray *ary1 = [result componentsSeparatedByString:@"#"];
    NSLog(@"%@",ary1);
    for (int i=0;i<[ary1 count];i++) {
        if (i==0) {
            NSArray *ary2=[[ary1 objectAtIndex:0] componentsSeparatedByString:@";"];
            NSMutableArray *array2=[[NSMutableArray alloc] initWithArray:ary2];
            [array2 removeLastObject];
            NSMutableArray *array=[[NSMutableArray alloc] init];
            for (NSString *result2 in array2) {
                NSLog(@"%@",result2);
                
                NSArray *ary3=[result2 componentsSeparatedByString:@"@"];
                NSLog(@"%@",ary3);
                if ([[ary3 objectAtIndex:0] intValue]==0) {
                    AKsCanDanListClass *candan=[[AKsCanDanListClass alloc] init];
                    if ([[ary3 objectAtIndex:3] isEqualToString:[ary3 objectAtIndex:5]]||[[ary3 objectAtIndex:5]isEqualToString:@""]) {
                        candan.pcname=[ary3 objectAtIndex:4];
                    }
                    else
                    {
                        candan.pcname=[NSString stringWithFormat:@"--%@",[ary3 objectAtIndex:4]];
                    }
                    [Singleton sharedSingleton].CheckNum=[ary3 objectAtIndex:1];
                    candan.tpname=[ary3 objectAtIndex:6];
                    candan.pcount=[ary3 objectAtIndex:8];
                    candan.fujianame=[ary3 objectAtIndex:7];
                    candan.pcount=[ary3 objectAtIndex:8];
                    candan.promonum=[ary3 objectAtIndex:9];
                    NSArray *ary4=[[ary3 objectAtIndex:11] componentsSeparatedByString:@"!"];
                    NSMutableString *FujiaName =[NSMutableString string];
                    for (NSString *str in ary4) {
                        [FujiaName appendFormat:@"%@ ",str];
                    }
                    float addtition=0.0f;
                    NSArray *ary5=[[ary3 objectAtIndex:13] componentsSeparatedByString:@"!"];
                    for (NSString *str in ary5) {
                        addtition+=[str floatValue];
                    }
                    if (addtition==0) {
                        candan.fujiaprice=@"";
                    }else
                    {
                    candan.fujiaprice=[NSString stringWithFormat:@"%.2f",addtition];
                    }
                    candan.fujianame=FujiaName;
                    candan.price=[ary3 objectAtIndex:12];
                    candan.unit=[ary3 objectAtIndex:16];
                    candan.istc=[ary3 objectAtIndex:17];
                    [array addObject:candan];
                    NSLog(@"%@",array);
                }
                else
                {
                    return nil;
                }
                
            }
            [array1 addObject:array];
        }
        else if(i==1)
        {
            NSArray *ary2=[[ary1 objectAtIndex:1] componentsSeparatedByString:@";"];
            NSMutableArray *array2=[[NSMutableArray alloc] initWithArray:ary2];
            [array2 removeLastObject];
            NSMutableArray *ary=[[NSMutableArray alloc] init];
            NSLog(@"%@",ary);
            for (NSString *result2 in array2) {
                NSArray *ary3=[result2 componentsSeparatedByString:@"@"];
                if ([[ary3 objectAtIndex:0] intValue]==0) {
                    AKsYouHuiListClass *youhui=[[AKsYouHuiListClass alloc] init];
                    youhui.youName=[ary3 objectAtIndex:2];
                    youhui.youMoney=[ary3 objectAtIndex:3];
                    [ary addObject:youhui];
                }
            }
            [array1 addObject:ary];
        }
        else if(i==2)
        {
            NSArray *ary2=[[ary1 objectAtIndex:2] componentsSeparatedByString:@"@"];
            if ([[ary2 objectAtIndex:0] intValue]==0) {
                [Singleton sharedSingleton].man=[ary2 objectAtIndex:1];
                [Singleton sharedSingleton].woman=[ary2 objectAtIndex:2];
            }
        }
        else{
            NSArray *ary2=[[ary1 objectAtIndex:3] componentsSeparatedByString:@";"];
            NSMutableArray *ary=[[NSMutableArray alloc] init];
            NSMutableString *str=[NSMutableString string];
            NSLog(@"%@",ary);
            for (NSString *result2 in ary2) {
                NSArray *ary3=[result2 componentsSeparatedByString:@"@"];
                if ([ary3 count]==2) {
                    //                    [ary stringByAppendingString:[ary3 objectAtIndex:1]];
                    [str appendFormat:@"%@ ",[ary3 objectAtIndex:1]];
                }
                //                [ary addObject:[ary3 objectAtIndex:1]];
            }
            [ary addObject:str];
            [array1 addObject:ary];
        }
    }
    if ([array1 count]==3) {
        [array1 exchangeObjectAtIndex:1 withObjectAtIndex:2];
    }
    NSLog(@"%@",array1);
    return array1;
}
/**
 *  根据台位号查询账单
 *
 *  @param str 台位号
 *
 *  @return
 */
-(NSDictionary *)getOrdersBytabNum1:(NSString *)str{
    NSString *pdanum = [NSString stringWithFormat:@"%@",[self padID]];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@",pdanum,[[Singleton sharedSingleton].userInfo objectForKey:@"user"],str];
    NSDictionary *dict = [self bsService:@"getOrdersBytabNum" arg:strParam];
    NSLog(@"%@",dict);
    NSString *str1=[[[dict objectForKey:@"ns:getOrdersBytabNumResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
    NSArray *ary = [str1 componentsSeparatedByString:@"@"];
    NSMutableDictionary *dataDic=[NSMutableDictionary dictionary];
    if ([ary count]==1) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:[ary lastObject] delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
        return  nil;
    }
    else
    {
        [dataDic setValue:[ary objectAtIndex:0] forKey:@"Result"];
        if ([[ary objectAtIndex:0] intValue]==0) {
            NSArray *ary2 = [str1 componentsSeparatedByString:@"&"];
            NSMutableArray *returnArray=[[NSMutableArray alloc] init];
            for (NSString *string in ary2) {
                NSArray *valuearray=[string componentsSeparatedByString:@"#"];
                if([[valuearray objectAtIndex:1]isEqualToString:@"1"])
                {
                    AKsNetAccessClass *netAccess =[AKsNetAccessClass sharedNetAccess];
                    NSArray *cardValue=[[valuearray objectAtIndex:2]componentsSeparatedByString:@"@"];
                    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
                    
                    
                    [dict setObject:@"" forKey:@"zhangdanId"];
                    [dict setObject:[cardValue objectAtIndex:0] forKey:@"phoneNum"];
                    [dict setObject:[Singleton sharedSingleton].Time forKey:@"dateTime"];
                    [dict setObject:[cardValue objectAtIndex:1] forKey:@"cardNum"];
                    [dict setObject:[cardValue objectAtIndex:4] forKey:@"IntegralOverall"];
                    netAccess.JiFenKeYongMoney=[cardValue objectAtIndex:4];
                    netAccess.ChuZhiKeYongMoney=[cardValue objectAtIndex:3];
                    netAccess.VipCardNum=[cardValue objectAtIndex:1];
                    
                    NSArray *VipJuan=[[NSArray alloc]initWithArray:[[cardValue objectAtIndex:7]componentsSeparatedByString:@";" ]];
                    NSMutableArray *cardJuanArray=[[NSMutableArray alloc]init];
                    for (int i=0; i<[VipJuan count]-1; i++)
                    {
                        NSArray *values=[[VipJuan objectAtIndex:i] componentsSeparatedByString:@","];
                        CardJuanClass *cardJuan=[[CardJuanClass alloc]init];
                        cardJuan.JuanId=[values objectAtIndex:0];
                        cardJuan.JuanMoney=[NSString stringWithFormat:@"%.2f",[[values objectAtIndex:1]floatValue]/100.0];
                        cardJuan.JuanName=[values objectAtIndex:2];
                        cardJuan.JuanNum=[values objectAtIndex:3];
                        [cardJuanArray addObject:cardJuan];
                        
                    }
                    netAccess.CardJuanArray=cardJuanArray;
                    netAccess.showVipMessageDict=dict;
                }
                NSArray *array=[[valuearray objectAtIndex:0] componentsSeparatedByString:@";"];
                NSMutableDictionary *dictV=[[NSMutableDictionary alloc] init];
                [dictV setObject:[[[array objectAtIndex:0] componentsSeparatedByString:@"@"] lastObject] forKey:@"CheckNum"];
                [dictV setObject:[array objectAtIndex:1] forKey:@"man"];
                [dictV setObject:[array objectAtIndex:2] forKey:@"woman"];
                [dictV setObject:[array objectAtIndex:3] forKey:@"people"];
                [dictV setObject:[array objectAtIndex:4] forKey:@"state"];
                [dictV setObject:[array objectAtIndex:5] forKey:@"tableName"];
                [dictV setObject:[array objectAtIndex:6] forKey:@"ISFENGTAI"];
                [returnArray addObject:dictV];
            }
            [dataDic setValue:returnArray forKey:@"message"];
            return [NSDictionary dictionaryWithDictionary:dataDic];
        }
        else
        {
            [dataDic setValue:[ary objectAtIndex:1] forKey:@"message"];
            return [NSDictionary dictionaryWithDictionary:dataDic];
        }
    }
}
/**
 *  注销登录
 *
 *  @return
 */
-(NSArray *)logout
{
    NSString *strParam=[NSString stringWithFormat:@"?&deviceId=%@&userCode=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"]];
    NSDictionary *dict=[self bsService:@"logout" arg:strParam];
    NSString *result = [[[dict objectForKey:@"ns:loginOutResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
    NSArray *ary1 = [result componentsSeparatedByString:@"@"];
    return ary1;
}
/**
 *  POS注册
 *
 *  @param str
 *
 *  @return
 */
-(NSString *)registerDeviceId:(NSString *)str
{
    NSString *strParam =[NSString stringWithFormat:@"?&handvId=%@",str];
    NSDictionary *dict = [self bsService:@"registerDeviceId" arg:strParam];
    NSString *result = [[[dict objectForKey:@"ns:registerDeviceIdResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
    NSArray *ary1 = [result componentsSeparatedByString:@"@"];
    return [ary1 objectAtIndex:1];
}
/**
 *  授权
 *
 *  @param info 授权信息
 *
 *  @return
 */
-(NSDictionary *)checkAuth1:(NSDictionary *)info
{
    NSString *pdanum = [NSString stringWithFormat:@"%@",[self padID]];
    NSString *user=[info objectForKey:@"user"];
    NSString *pass=[info objectForKey:@"pwd"];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&userPass=%@",pdanum,user,pass];
    NSDictionary *dict = [self bsService:@"checkAuth" arg:strParam];
    return dict;
    
}
/**
 *  全单附加项
 *
 *  @param ary
 *
 *  @return
 */
-(NSDictionary *)specialRemark:(NSArray *)ary
{
    NSString *pdanum = [NSString stringWithFormat:@"%@",[self padID]];
    NSString *userCode=[NSString stringWithFormat:@"%@",[[Singleton sharedSingleton].userInfo objectForKey:@"user"]];
    NSString *orderId=[Singleton sharedSingleton].CheckNum;
    NSLog(@"%@",ary);
    NSMutableString *remarkId=[NSMutableString string];
    NSMutableString *remark=[NSMutableString string];
    for (NSDictionary *dict in ary) {
        [remarkId appendFormat:@"%@",[dict objectForKey:@"Id"]];
        [remarkId appendString:@"!"];
        [remark appendFormat:@"%@",[dict objectForKey:@"DES"]];
        [remark appendString:@"!"];
    }
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&orderId=%@&remarkIdList=%@&remarkList=%@&flag=%@",pdanum,userCode,orderId,remarkId,remark,@"1"];
    NSDictionary *dict1 = [self bsService:@"specialRemark" arg:strParam];
    return dict1;
}
/**
 *  全单界面
 *
 *  @return
 */
- (NSDictionary *)queryCompletely{
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum];
    NSDictionary *dict = [self bsService:@"queryWholeProducts" arg:strParam];
    
    if (dict) {
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        NSString *result = [[[dict objectForKey:@"ns:queryWholeProductsResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSMutableArray *aryResult = [NSMutableArray array];
        if ([[ary objectAtIndex:0] isEqualToString:@"0"]) {
            //获取男人数、女人数、账单号、台位等基本信息
            NSArray *aryInfo = [result componentsSeparatedByString:@"#"];
            NSArray *aryInfoRes =[[aryInfo objectAtIndex:[aryInfo count]-2] componentsSeparatedByString:@"@"];
            [Singleton sharedSingleton].man=[aryInfoRes objectAtIndex:1];
            [Singleton sharedSingleton].woman=[aryInfoRes objectAtIndex:2];
            NSArray *ary = [[aryInfo objectAtIndex:0] componentsSeparatedByString:@";"];
            NSArray *array=[[aryInfo lastObject] componentsSeparatedByString:@";"];
            NSMutableString *Common=[NSMutableString string];
            for (int i=0; i<[array count]-1; i++) {
                NSString *str=[array objectAtIndex:i];
                NSArray *itemAry = [str componentsSeparatedByString:@"@"];
                [Common appendFormat:@"%@ ",[itemAry objectAtIndex:1]];
            }
            [dic setValue:Common forKey:@"Common"];
            //            NSMutableDictionary *dicResult = [NSMutableDictionary dictionary];
            
            int c = [ary count];
            for (int z=0; z<c-1; z++) {
                NSString *str = [ary objectAtIndex:z];
                NSArray *itemAry = [str componentsSeparatedByString:@"@"];
                NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
                [mutDic setValue:[itemAry objectAtIndex:1]   forKey:@"orderId"];
                [mutDic setValue:[itemAry objectAtIndex:2]   forKey:@"PKID"];
                [mutDic setValue:[itemAry objectAtIndex:3]   forKey:@"Pcode"];
                [mutDic setValue:[itemAry objectAtIndex:4]   forKey:@"PCname"];
                [mutDic setValue:[itemAry objectAtIndex:5]   forKey:@"Tpcode"];
                [mutDic setValue:[itemAry objectAtIndex:6]   forKey:@"TPNAME"];
                [mutDic setValue:[itemAry objectAtIndex:7]   forKey:@"TPNUM"];
                [mutDic setValue:[itemAry objectAtIndex:8]   forKey:@"pcount"];
                [mutDic setValue:[itemAry objectAtIndex:9]   forKey:@"promonum"];
                [mutDic setValue:[itemAry objectAtIndex:10]  forKey:@"fujiacode"];
                [mutDic setValue:[itemAry objectAtIndex:11]  forKey:@"fujianame"];
                [mutDic setValue:[itemAry objectAtIndex:12]  forKey:@"talPreice"];
                [mutDic setValue:[itemAry objectAtIndex:13]  forKey:@"fujiaPrice"];
                [mutDic setValue:[itemAry objectAtIndex:14]  forKey:@"weight"];
                [mutDic setValue:[itemAry objectAtIndex:15]  forKey:@"weightflg"];
                [mutDic setValue:[itemAry objectAtIndex:16]  forKey:@"unit"];
                [mutDic setValue:[itemAry objectAtIndex:17]  forKey:@"ISTC"];
                [mutDic setValue:[itemAry objectAtIndex:18]  forKey:@"Urge"];//催菜次数
                [mutDic setValue:[itemAry objectAtIndex:19]  forKey:@"Over"];//划菜数量
                [mutDic setValue:[itemAry objectAtIndex:20]  forKey:@"IsQuit"];//推菜标志（0为退菜，1为正常）
                [mutDic setValue:[itemAry objectAtIndex:21]  forKey:@"QuitCause"];//退菜原因
                [mutDic setValue:[itemAry objectAtIndex:22]  forKey:@"CLASS"];
                [mutDic setValue:[itemAry objectAtIndex:23]  forKey:@"price"];
                if ([itemAry count]>24) {
                    [mutDic setValue:[itemAry objectAtIndex:24] forKey:@"fujiaCount"];
                    [mutDic setValue:[itemAry objectAtIndex:25] forKey:@"Sublistid"];
                    [mutDic setValue:[itemAry objectAtIndex:26] forKey:@"UnitCode"];
                    [mutDic setValue:[itemAry objectAtIndex:27] forKey:@"unitName"];
                    [mutDic setValue:[itemAry objectAtIndex:28] forKey:@"istemp"];
                    [mutDic setValue:[itemAry objectAtIndex:29] forKey:@"tempCode"];
                    [mutDic setValue:[itemAry objectAtIndex:30] forKey:@"tempName"];
                    if ([[itemAry objectAtIndex:28] intValue]==1) {
                        [mutDic setValue:[NSString stringWithFormat:@"%@-%@",[itemAry objectAtIndex:4],[itemAry objectAtIndex:30]] forKey:@"PCname"];
                    }
                }
                [aryResult addObject:mutDic];
            }
            
        }
        [dic setValue:aryResult forKey:@"data"];
        return dic;
    }else
    {
        return nil;
    }
}
/**
 *  退菜    --------不使用
 *
 *  @param array 退菜列表
 *  @param info  退菜信息
 *
 *  @return
 */
-(NSDictionary *)chkCode:(NSArray *)array info:(NSDictionary *)info{
    NSLog(@"%@",array);
    NSArray *dataArray=array;
    NSString *pdanum = [NSString stringWithFormat:@"%@",[self padID]];
    NSMutableString *mutfood = [NSMutableString string];
    for (NSDictionary *info in array) {
        int count=[[info objectForKey:@"pcount"] intValue]-[[info objectForKey:@"Over"] intValue];
        if([[info objectForKey:@"ISTC"] intValue]==1&&![[info objectForKey:@"Pcode"] isEqualToString:[info objectForKey:@"Tpcode"]]){
            [mutfood appendFormat:@"%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@",[info objectForKey:@"PKID"],[info objectForKey:@"Pcode"],[info objectForKey:@"PCname"],[info objectForKey:@"Tpcode"],[info objectForKey:@"TPNAME"],@"0",[NSString stringWithFormat:@"-%@",[info objectForKey:@"CNT"]] ,[info objectForKey:@"promonum"],[info objectForKey:@"fujiacode"],[info objectForKey:@"fujianame"],[info objectForKey:@"price"],[info objectForKey:@"fujiaprice"],[info objectForKey:@"Weight"],[info objectForKey:@"Weightflg"],[info objectForKey:@"unit"],[info objectForKey:@"ISTC"]];
            [mutfood appendString:@";"];
        }
        else
        {
            [mutfood appendFormat:@"%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@",[info objectForKey:@"PKID"],[info objectForKey:@"Pcode"],[info objectForKey:@"PCname"],[info objectForKey:@"Tpcode"],[info objectForKey:@"TPNAME"],@"0",[NSString stringWithFormat:@"-%d",count],[info objectForKey:@"promonum"],[info objectForKey:@"fujiacode"],[info objectForKey:@"fujianame"],[info objectForKey:@"price"],[info objectForKey:@"fujiaprice"],[info objectForKey:@"Weight"],[info objectForKey:@"Weightflg"],[info objectForKey:@"unit"],[info objectForKey:@"ISTC"]];
            [mutfood appendString:@";"];
        }
    }
    NSLog(@"%@",mutfood);
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&chkCode=%@&tableNum=%@&orderId=%@&productList=%@&rebackReason=%@",pdanum,[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[info objectForKey:@"user"],[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum,mutfood,[info objectForKey:@"INIT"]];
    NSDictionary *dict1 = [self bsService:@"checkFoodAvailable" arg:strParam];
    NSLog(@"%@",dict1);
    if (dict1) {
        NSString *result = [[[dict1 objectForKey:@"ns:sendcResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary1 = [result componentsSeparatedByString:@"@"];
        NSLog(@"%@",ary1);
        if ([[ary1 objectAtIndex:0] intValue]==0) {
            for (NSDictionary *dict in dataArray) {
                FMDatabase *db=[[FMDatabase alloc] initWithPath:[BSDataProvider sqlitePath]];
                if(![db open])
                {
                    NSLog(@"数据库打开失败");
                    return nil;
                }
                else
                {
                    NSLog(@"数据库打开成功");
                }
                FMResultSet *rs=[db executeQuery:@"select * from AllCheck where PKID=?",[dict objectForKey:@"PKID"]];
                NSString *pcount,*over;
                while ([rs next]) {
                    pcount=[rs stringForColumn:@"pcount"];
                    over=[rs stringForColumn:@"Over"];
                }
                NSLog(@"%@",dict);
                int count=[pcount intValue]-[[dict objectForKey:@"pcount"] intValue]-[[dict objectForKey:@"Over"] intValue];
                int count1=[over intValue]-[[dict objectForKey:@"pcount"] intValue];
                if (count<1) {
                    NSString *qqq=[NSString stringWithFormat:@"delete from AllCheck WHERE PKID='%@'",[dict objectForKey:@"PKID"]];
                    NSLog(@"%@",qqq);
                    [db executeUpdate:qqq];
                }
                else
                {
                    NSLog(@"------%d   %d",count,count1);
                    NSString *str=[NSString stringWithFormat:@"UPDATE AllCheck SET pcount = '%d',Over='%d' WHERE PKID = '%@'",count,count1,[dict objectForKey:@"PKID"]];
                    NSLog(@"%@",str);
                    [db executeUpdate:str];
                }
                
                
                NSLog(@"%d",[db commit]);
                [db close];
                
            }
        }
    }
    return dict1;
}
/**
 *  菜齐-----------不使用
 */
-(void)suppProductsFinish
{
    NSString *pdanum = [NSString stringWithFormat:@"%@",[self padID]];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@",pdanum,[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum];
    
    NSDictionary *dict = [self bsService:@"ProductsFinish" arg:strParam];
    NSLog(@"%@",dict);
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:suppProductsFinishResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary1 = [result componentsSeparatedByString:@"@"];
        NSLog(@"%@",[ary1 lastObject]);
    }
    
}
//请求连接
- (NSDictionary *)bsService:(NSString *)api arg:(NSString *)arg{
    BSWebServiceAgent *agent = [[BSWebServiceAgent alloc] init];
    NSDictionary *dict = [agent GetData:api arg:arg];
    return dict;
}
/**
 *  查询台位列表
 *
 *  @param info
 *
 *  @return
 */
- (NSDictionary *)pListTable:(NSDictionary *)info{
    NSString *user,*pdanum,*floor,*area,*status,*tableNum;
    user = [NSString stringWithFormat:@"%@",[[Singleton sharedSingleton].userInfo objectForKey:@"user"]];
    pdanum = [NSString stringWithFormat:@"%@",[self padID]];
    floor = [info objectForKey:@"floor"];
    if (!floor)
        floor = @"";
    area = [info objectForKey:@"area"];
    if (!area)
        area = @"";
    status = [info objectForKey:@"state"];
    if (!status)
        status = @"";
    tableNum = [info objectForKey:@"tableNum"];
    if (!tableNum)
        tableNum = @"";
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&area=%@&floor=%@&state=%@&tableNum=%@",pdanum,user,area,floor,status,tableNum];
    NSLog(@"%@",strParam);
    NSDictionary *dict = [self bsService:@"pListTable" arg:strParam];
    return dict;
}

/**
 *  发送菜品
 *
 *  @param ary  菜品信息
 *  @param info 发生信息
 *  @param tag  标示
 *
 *  @return
 */
- (NSDictionary *)checkFoodAvailable:(NSArray *)ary info:(NSDictionary *)info tag:(int)tag{
    NSString *pdanum = [NSString stringWithFormat:@"%@",[self padID]];
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.f",a];//时间戳
    NSMutableString *mutfood = [NSMutableString string];
    int x = 0;
//    PLUSD
    for (int i=0; i<ary.count; i++) {
        NSDictionary *dict=[ary objectAtIndex:i];
        NSString *PKID=@"",*Pcode=@"",*Tpcode=@"",*TPNUM=@"",*pcount=@"",*Price=@"",*Weight=@"",*Weightflg=@"",*isTC=@"",*promonum=@"",*UNIT=@"",*promoReason=@"",*unitKay=@"",*istemp=@"0",*DES=@"";
        NSMutableString *Fujiacode,*FujiaName,*FujiaPrice,*FujiaCount;
        Fujiacode=[NSMutableString string];
        FujiaName=[NSMutableString string];
        FujiaPrice=[NSMutableString string];
        FujiaCount=[NSMutableString string];
        Price=[dict objectForKey:@"PRICE"];//价格
        pcount=[dict objectForKey:@"total"];//数量
        Weight=[dict objectForKey:@"Weight"];//第二单位重量
        Weightflg=[dict objectForKey:@"UNITCUR"];//第二单位标示
        promonum=[dict objectForKey:@"promonum"];//赠送数量
        promoReason=[dict objectForKey:@"promoReason"]==nil?@"":[dict objectForKey:@"promoReason"];//赠送原因
        isTC=[dict objectForKey:@"ISTC"];//套餐
        TPNUM=[dict objectForKey:@"TPNUM"];//套餐标示
        UNIT=[dict objectForKey:@"UNIT"];//单位
        NSArray *array=[dict objectForKey:@"addition"];//附加项
        for (NSDictionary *dict1 in array) {
            [Fujiacode appendFormat:@"%@",[dict1 objectForKey:@"FCODE"]];//附加项编码
            [Fujiacode appendString:@"!"];
            [FujiaName appendFormat:@"%@",[dict1 objectForKey:@"FNAME"]];//附加项名称
            [FujiaName appendString:@"!"];
            [FujiaPrice appendFormat:@"%@",[dict1 objectForKey:@"FPRICE"]];//附加项价格
            [FujiaPrice appendString:@"!"];
            [FujiaCount appendFormat:@"%@",[dict1 objectForKey:@"total"]];//附加项价格
            [FujiaCount appendString:@"!"];
            
        }
        /**
         *  判断是套餐名称
         */
        if ([[dict objectForKey:@"ISTC"] intValue]==1&&![dict objectForKey:@"CNT"]) {
            PKID=[NSString stringWithFormat:@"%@%@%@%@%@%d",pdanum,[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[Singleton sharedSingleton].CheckNum,[Singleton sharedSingleton].Seat,timeString,x];
            Pcode=[dict objectForKey:@"ITCODE"];
            Tpcode=Pcode;//菜品编码与套餐编码相同
            x++;
        }
        else
        {
            /**
             *  判断是否是套餐明细
             */
            if ([dict objectForKey:@"CNT"])
            {
                PKID=[NSString stringWithFormat:@"%@%@%@%@%@%d",pdanum,[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[Singleton sharedSingleton].CheckNum,[Singleton sharedSingleton].Seat,timeString,x-1];
                Pcode=[dict objectForKey:@"PCODE1"];//菜品编码
                Tpcode=[dict objectForKey:@"PCODE"];//套餐编码
                pcount=[dict objectForKey:@"total"];//菜品数量
            }
            else
            {
                PKID=[NSString stringWithFormat:@"%@%@%@%@%@%d",pdanum,[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[Singleton sharedSingleton].CheckNum,[Singleton sharedSingleton].Seat,timeString,i];
                Pcode=[dict objectForKey:@"ITCODE"];
                x++;
            }
        }
    
        if ([isTC intValue]!=1) {
            unitKay=[dict objectForKey:[dict objectForKey:@"UNITKAY"]==nil?@"UNIT1":[dict objectForKey:@"UNITKAY"]];
        }
        
        istemp=[dict objectForKey:@"ISTEMP"];
        DES=[[dict objectForKey:@"ISTEMP"] intValue]==1?[dict objectForKey:@"DES"]:@"";
        [mutfood appendFormat:@"%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@",PKID,Pcode,@"",Tpcode,@"",TPNUM,pcount,promonum,Fujiacode,FujiaName,Price,FujiaPrice,Weight,Weightflg,UNIT,isTC,promoReason,FujiaCount,unitKay,istemp,DES];
        [mutfood appendString:@";"];
    }
    
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&chkCode=%@&tableNum=%@&orderId=%@&productList=%@&rebackReason=&immediateOrWait=%@",pdanum,[[Singleton sharedSingleton].userInfo objectForKey:@"user"],@"",[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum,mutfood,[info objectForKey:@"immediateOrWait"]];
    
    NSDictionary *dict3 = [self bsService:@"checkFoodAvailable" arg:strParam];
    if (dict3 && [Singleton sharedSingleton].isYudian==NO) {
        NSString *result = [[[dict3 objectForKey:@"ns:sendcResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary1 = [result componentsSeparatedByString:@"@"];
        NSString *str=[ary1 objectAtIndex:0];
        if ([str isEqualToString:@"0"]) {
            [self delectCache];
        }
    }
    return dict3;
}
/**
 *  获取数据库路径
 *
 *  @return
 */
+ (NSString *)sqlitePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"BookSystem.sqlite"];
    return path;
}
/**
 *  查询已发送的菜品
 *
 *  @param table 台位号
 *  @param order 账单号
 *
 *  @return
 */
+(NSArray *)tableNum:(NSString *)table orderID:(NSString *)order
{
    NSMutableArray *ary = [BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from AllCheck where tableNum = '%@'and orderId='%@' and send='%@'",table,order,@"1"]];
    return ary;
}

/**
 *  获取唯一标示
 *
 *  @return
 */
-(NSString *)UUIDString{
    NSString *uuid = nil;
    uuid =[OpenUDID value];
    return uuid;
}
/**
 *  调用登录接口
 *
 *  @param info 登录信息
 *
 *  @return
 */
- (NSDictionary *)pLoginUser:(NSDictionary *)info{
    NSString *user,*pwd;
    user = [info objectForKey:@"userCode"];
    pwd = [info objectForKey:@"usePass"];
    NSString *pdaid = [NSString stringWithFormat:@"%@",[self padID]];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&handvId=%@&userCode=%@&userPass=%@",pdaid,[self UUIDString],user,pwd];
    NSDictionary *dict = [[self bsService:@"pLoginUser" arg:strParam] objectForKey:@"ns:loginResponse"];
    
    return dict;
}
/**
 *  开台接口调用
 *
 *  @param info 开台信息
 *
 *  @return
 */
- (NSDictionary *)pStart:(NSDictionary *)info{
    NSString *pdaid,*user,*table,*mancount,*womancounts,*openTag;
    pdaid = [NSString stringWithFormat:@"%@",[self padID]];
    user = [[Singleton sharedSingleton].userInfo objectForKey:@"user"];
    table = [info objectForKey:@"name"];//台位号
    mancount = [info objectForKey:@"man"];//男人数
    womancounts = [info objectForKey:@"woman"];//女人数
    openTag=[info objectForKey:@"openTag"];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&manCounts=%@&womanCounts=%@&ktKind=%@&openTablemwyn=%@",pdaid,user,table,mancount,womancounts,openTag,[info objectForKey:@"tag"]];
    NSDictionary *dict = [[self bsService:@"pStart" arg:strParam] objectForKey:@"ns:startcResponse"];
    return dict;
}
#pragma mark 计算服务费
-(NSDictionary *)ComputingServicefee:(NSString *)type
{
    /*
    deviceId：设备编号
    
    userCode：用户编码
    
    type: 操作类型  0 取消服务费  1 计算服务费
    
    tableNum：桌号
    
    ordered   账单号
    
    lclass    账单类型： 1 堂食  2 外带  3 外送 ….
     */
    NSString *pdaid,*user;
    pdaid = [NSString stringWithFormat:@"%@",[self padID]];
    user = [[Singleton sharedSingleton].userInfo objectForKey:@"user"];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&type=%@&orderId=%@&lclass=%@",pdaid,user,[Singleton sharedSingleton].Seat,type,[Singleton sharedSingleton].CheckNum,@"1"];
    NSDictionary *dict = [[self bsService:@"ComputingServicefee" arg:strParam] objectForKey:@"ns:ComputingServicefeeResponse"];
    return dict;
}
/**
 *  查询所有区域
 *
 *  @return
 */
- (NSArray *)getArea{//根据区域区分
    NSMutableArray *ary = [BSDataProvider getDataFromSQLByCommand:@"select * from storearear_mis"];
    return ary;
}
/**
 *  查询楼层
 *
 *  @return
 */
- (NSArray *)getFloor{//根据楼层区分
    NSMutableArray *ary = [BSDataProvider getDataFromSQLByCommand: @"select * from codedesc where code = 'LC'"];
    return ary;
}
/**
 *  查询状态
 *
 *  @return
 */
- (NSArray *)getStatus{//根据状态区分
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    
    NSString *langCode = [langSetting localizedString:@"LangCode"];
    
    if ([langCode isEqualToString:@"en"])
        return [NSArray arrayWithObjects:@"Idle",@"Ordered",@"No order",nil];
    else if ([langCode isEqualToString:@"cn"])
        return [NSArray arrayWithObjects:@"空闲",@"开台未点",@"开台点餐",@"结账",@"已封台",@"换台",@"子台位",@"挂单",@"菜齐",nil];
    else
        return [NSArray arrayWithObjects:@"空閒",@"開台點菜",@"開台未點",nil];
    
}

- (NSDictionary *)dictFromSQL{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    NSMutableArray *mutAds = [NSMutableArray array];
    NSMutableArray *mutFileList = [NSMutableArray array];
    
    NSMutableArray *mutClass = [NSMutableArray array];
    
    NSString *path = [BSDataProvider sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    //   char *errorMsg;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        //Generate Ads & FileList
        //1 Ads
        sqlcmd = @"select * from ads";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                char *name = (char *)sqlite3_column_text(stat, 0);
                [mutAds addObject:[NSString stringWithUTF8String:name]];
            }
        }
        sqlite3_finalize(stat);
        [ret setObject:mutAds forKey:@"Ads"];
        //2 FileList
        sqlcmd = @"select * from imageFile";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                char *name = (char *)sqlite3_column_text(stat, 0);
                [mutFileList addObject:[NSString stringWithUTF8String:name]];
            }
        }
        sqlite3_finalize(stat);
        [ret setObject:mutFileList forKey:@"FileList"];
        
        
        //Generate Main Menu
        //1. Get image,name of MainMenu
        sqlcmd = @"select * from class";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                char *background = (char *)sqlite3_column_text(stat,0);
                int type = sqlite3_column_int(stat, 1);
                char *image = (char *)sqlite3_column_text(stat,2);
                char *name = (char *)sqlite3_column_text(stat, 3);
                char *recommend = (char *)sqlite3_column_text(stat, 4);
                
                NSMutableDictionary *mut = [NSMutableDictionary dictionary];
                [mut setObject:[NSNumber numberWithInt:type] forKey:@"type"];
                if (background)
                    [mut setObject:[NSString stringWithUTF8String:background] forKey:@"background"];
                if (image)
                    [mut setObject:[NSString stringWithUTF8String:image] forKey:@"image"];
                if (name)
                    [mut setObject:[NSString stringWithUTF8String:name] forKey:@"name"];
                if (recommend)
                    [mut setObject:[NSString stringWithUTF8String:recommend] forKey:@"recommend"];
                
                [mutClass addObject:mut];
            }
        }
        sqlite3_finalize(stat);
        
        //2. Genereate by Food
        for (int i=0;i<[mutClass count];i++){
            NSMutableDictionary *mutC = [mutClass objectAtIndex:i];
            NSString *strOrder;
            NSString *strPrice = [[NSUserDefaults standardUserDefaults] stringForKey:@"price"];
            if ([strPrice isEqualToString:@"PRICE"])
                strOrder = @"ITEMNO";
            else if ([strPrice isEqualToString:@"PRICE"])
                strOrder = @"ITEMNO2";
            else
                strOrder = @"ITEMNO3";
            sqlcmd = [NSString stringWithFormat:@"select * from food where GRPTYP = %d and HSTA = 'Y' order by %@",[[[mutClass objectAtIndex:i] objectForKey:@"type"] intValue],strOrder];
            NSMutableArray *foods = [NSMutableArray array];
            if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
                while (sqlite3_step(stat)==SQLITE_ROW) {
                    int count = sqlite3_column_count(stat);
                    NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                    for (int i=0;i<count;i++){
                        char *foodKey = (char *)sqlite3_column_name(stat, i);
                        char *foodValue = (char *)sqlite3_column_text(stat, i);
                        NSString *strKey = nil,*strValue = nil;
                        strKey = nil;
                        strValue = nil;
                        if (foodKey)
                            strKey = [NSString stringWithUTF8String:foodKey];
                        if (foodValue)
                            strValue = [NSString stringWithUTF8String:foodValue];
                        if (strKey && strValue)
                            [mutDC setObject:strValue forKey:strKey];
                    }
                    [foods addObject:mutDC];
                }
            }
            sqlite3_finalize(stat);
            
            if (foods && [foods count]>0)
                [mutC setObject:foods forKey:@"SubMenu"];
        }
        
        if (mutClass && [mutClass count]>0)
            [ret setObject:mutClass forKey:@"MainMenu"];
    }
    sqlite3_close(db);
    return ret;
}

/**
 *  根据类别查询所有的菜品
 *
 *  @param cmd 类别编码
 *
 *  @return
 */
+ (NSMutableArray *)getFoodList:(NSString *)cmd{
    
    NSMutableArray *ary = [BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from food where %@",cmd]];
    NSArray *unitArray=[BSDataProvider getDataFromSQLByCommand:@"select * from measdoc"];
    for (NSDictionary *dict in ary) {
        NSLog(@"%@",[dict objectForKey:@"DES"]);
        for (int i=0; i<6; i++) {
            if ([[dict objectForKey:[NSString stringWithFormat:@"UNIT%d",i+1]] length]>0&&![[dict objectForKey:[NSString stringWithFormat:@"UNIT%d",i+1]] isEqualToString:[NSString stringWithFormat:@"~_UNIT%d_~",i+1]]) {
                for (NSDictionary *unit in unitArray) {
                    if ([[dict objectForKey:[NSString stringWithFormat:@"UNIT%d",i+1]] isEqualToString:[unit objectForKey:@"code"]]) {
                        [dict setValue:[unit objectForKey:@"name"] forKey:[NSString stringWithFormat:@"UNITS%d",i+1]];
                        if (i>=1) {
                            //多规格加标识
                            [dict setValue:@"1" forKey:@"ISUNITS"];
                        }
                        break;
                    }
                }
                
            }
        }
    }
    return [NSMutableArray arrayWithArray:ary];
}

/**
 *  根据套餐编码查询套餐明细
 *
 *  @param tag 套餐编码
 *
 *  @return
 */
-(NSMutableArray *)combo:(NSDictionary *)tag{
    
    /**
     *  根据套餐编码查询组
     */
    NSArray *groupArray=[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"SELECT PNAME,PRICE1,PCODE1,PRODUCTTC_ORDER,MAXCNT,MINCNT FROM products_sub a WHERE defualtS = '0' and pcode='%@' GROUP BY PRODUCTTC_ORDER ORDER BY PRODUCTTC_ORDER  ASC",[tag objectForKey:@"ITCODE"]]];
    NSMutableArray *returnGroupArray=[NSMutableArray array];
    for (NSDictionary *groupDic in groupArray) {
        /**
         *  套餐明细
         */
        NSMutableArray *productArray;
        if ([[tag objectForKey:@"TCMONEYMODE"] intValue]==2) {
            productArray=[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"SELECT c.FUJIAMODE,c.ISTEMP,c.PRICE,b.SUBID,b.PNAME,b.CNT,c.DES,b.PRODUCTTC_ORDER,b.NADJUSTPRICE,b.GROUPTITLE,b.MAXCNT,b.MINCNT,b.PCODE,b.PCODE1,b.defualtS,a.ISTC,a.TCMONEYMODE,c.UNIT FROM food a,food c LEFT JOIN products_sub b ON a.itcode = b.pcode WHERE b.pcode = '%@' AND b.PRODUCTTC_ORDER = '%@' AND c.itcode in (b.pcode1) ORDER BY defualtS ASC",[tag objectForKey:@"ITCODE"],[groupDic objectForKey:@"PRODUCTTC_ORDER"]]];
        }else
        {
            productArray=[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"SELECT a.*, b.*,c.FUJIAMODE AS FUJIAMODE,c.ISTEMP as ISTEMP,b.PNAME FROM food a,food c LEFT JOIN products_sub b ON a.itcode = b.pcode WHERE b.pcode = '%@' AND b.PRODUCTTC_ORDER = '%@' AND c.itcode in (b.pcode1) ORDER BY defualtS ASC",[tag objectForKey:@"ITCODE"],[groupDic objectForKey:@"PRODUCTTC_ORDER"]]];
        }
        
        /**
         *  将改组的最大最小数量放入数据中
         */
        for (NSDictionary *dict in productArray) {
            [dict setValue:[groupDic objectForKey:@"MAXCNT"] forKey:@"TYPMAXCNT"];
            [dict setValue:[groupDic objectForKey:@"MINCNT"] forKey:@"TYPMINCNT"];
            
        }
        /**
         *  删除 defualtS=0的数据
         */
        if ([productArray count]>1) {
            [productArray removeObjectAtIndex:0];
        }
        /**
         *  将菜品放在分组的数组中
         */
        [returnGroupArray addObject:productArray];
    }
    return returnGroupArray;
}
/**
 *  查询全部的套餐明细
 *
 *  @return
 */

-(NSMutableArray *)allCombo{
    /**
     *  获取套餐编码
     */
    NSArray *pcodeArray=[BSDataProvider getDataFromSQLByCommand:@"SELECT PCODE from products_sub where defualtS = '0' AND PRODUCTTC_ORDER=1 ORDER BY pcode ASC"];
    /**
     *  返回的数组
     */
    NSMutableArray *returnArray=[NSMutableArray array];
    for (NSDictionary *pcodeDic in pcodeArray) {
        /**
         *  根据套餐编码查询组
         */
        NSArray *groupArray=[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"SELECT PNAME,PRICE1,PCODE1,PRODUCTTC_ORDER,MAXCNT,MINCNT FROM products_sub a WHERE defualtS = '0' and pcode='%@' GROUP BY PRODUCTTC_ORDER ORDER BY PRODUCTTC_ORDER  ASC",[pcodeDic objectForKey:@"PCODE"]]];
        NSMutableArray *returnGroupArray=[NSMutableArray array];
        for (NSDictionary *groupDic in groupArray) {
            /**
             *  套餐明细
             */
            NSMutableArray *productArray=[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"SELECT a.*,b.*,c.PRICE AS FPRICE FROM food a left JOIN products_sub b on a.ITCODE=b.pcode left JOIN food c ON b.PCODE1=c.ITCODE WHERE b.pcode='%@' and PRODUCTTC_ORDER='%@' ORDER BY defualtS ASC",[pcodeDic objectForKey:@"PCODE"],[groupDic objectForKey:@"PRODUCTTC_ORDER"]]];
            /**
             *  将改组的最大最小数量放入数据中
             */
            for (NSDictionary *dict in productArray) {
                [dict setValue:[groupDic objectForKey:@"MAXCNT"] forKey:@"TYPMAXCNT"];
                [dict setValue:[groupDic objectForKey:@"MINCNT"] forKey:@"TYPMINCNT"];
            }
            /**
             *  删除 defualtS=0的数据
             */
            if ([productArray count]>1) {
                [productArray removeObjectAtIndex:0];
            }
            /**
             *  将菜品放在分组的数组中
             */
            [returnGroupArray addObject:productArray];
        }
        /**
         *  将组数组放在返回的数组中
         */
        [returnArray addObject:returnGroupArray];
    }
    return returnArray;
}
+ (id)getDataFromSQLByCommand:(NSString *)cmd{
    NSMutableArray *ary = [NSMutableArray array];
    NSString *path = [self sqlitePath];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd = cmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

/**
 *  催菜
 *
 *  @param array 催的菜品列表
 *
 *  @return
 */
- (NSDictionary *)pGogo:(NSArray *)array{
    NSString *user;
    NSString *pdaid = [NSString stringWithFormat:@"%@",[self padID]];
    user = [NSString stringWithFormat:@"%@",[[Singleton sharedSingleton].userInfo objectForKey:@"user"]];
    NSMutableString *mutfood = [NSMutableString string];
    for (NSDictionary *info in array) {
        [mutfood appendFormat:@"%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@",[info objectForKey:@"PKID"],[info objectForKey:@"Pcode"],@"",[info objectForKey:@"Tpcode"],@"",[info objectForKey:@"TPNUM"],[info objectForKey:@"pcount"],[info objectForKey:@"promonum"],[info objectForKey:@"fujiacode"],@"",[info objectForKey:@"price"],[info objectForKey:@"fujiaprice"],[info objectForKey:@"Weight"],[info objectForKey:@"Weightflg"],[info objectForKey:@"UnitCode"],[info objectForKey:@"ISTC"],[info objectForKey:@"Sublistid"],[info objectForKey:@"istemp"]];
        [mutfood appendString:@";"];
    }
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&orderId=%@&tableNum=%@&productList=%@",pdaid,user,[Singleton sharedSingleton].CheckNum,[Singleton sharedSingleton].Seat,mutfood];
    
    NSDictionary *dict = [self bsService:@"pGogo" arg:strParam];
    return dict;
}

#pragma mark -  激活
- (BOOL)checkActivated{
    BOOL bActivated = [[NSUserDefaults standardUserDefaults] boolForKey:@"Activated"];
    
    if (bActivated)
        return YES;
    BOOL bSuceed = NO;
    
    NSString *strRegNo = [NSString UUIDString];
    
    NSArray *urls = [NSArray arrayWithObjects:@"61.174.28.122",@"60.12.218.91",nil];
    for (int i=0;i<2;i++){
        NSString *strUrl = [NSString stringWithFormat:@"http://%@:9100/choicereg.asmx/choicereg?uuid=%@",[urls objectAtIndex:i],strRegNo];
        //        NSLog(@"strUrl = %@",strUrl);
        NSURL *url = [NSURL URLWithString:strUrl];
        
        NSMutableURLRequest *request = nil;
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        NSData *serviceData = nil;
        
        request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3];
        [request setHTTPMethod:@"GET"];
        
        serviceData = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:&response
                                                        error:&error];
        
        
        
        if (!error){
            NSString *str = [[NSString stringWithCString:[serviceData bytes]
                                                encoding:NSUTF8StringEncoding] lowercaseString];
            NSRange range = [str rangeOfString:@"true"];
            if (range.location!=NSNotFound && str){
                bSuceed = YES;
                break;
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setBool:bSuceed forKey:@"Activated"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    return bSuceed;
}

/**
 *  团购验证
 *
 *  @param info 信息
 *
 *  @return
 */
-(NSString *)consumerCouponCode:(NSDictionary *)info
{
    NSString *vcCode=[[NSUserDefaults standardUserDefaults] objectForKey:@"DianPuId"];
    NSString *strParam = [NSString stringWithFormat:@"?&type=%@&code=%@&vscode=%@&vsname=&sqnum=%@&userName=%@&token=%@&userEmail=%@&voperator=%@",[info objectForKey:@"CONPONCODE"],[info objectForKey:@"num"],vcCode,[Singleton sharedSingleton].CheckNum,[info objectForKey:@"USERNAME"],[info objectForKey:@"TOKEN"],[info objectForKey:@"USEREMAIL"],[[Singleton sharedSingleton].userInfo objectForKey:@"user"]];
    NSDictionary *dict = [self bsService:@"consumerCouponCode" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:consumerCouponCodeResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        return result;
    }else
    {
        return [NSString stringWithFormat:@"%@",dict];
    }
}
-(NSArray *)productEstimate:(NSString *)classid
{
    //    NSString *result = @"0@pcode;菜品名称;实际销售量;预估销售量;百分比@pcode;菜品名称;实际销售量;预估销售量;百分比";
    //    NSArray *array=[result componentsSeparatedByString:@"@"];
    //    return array;
    
    NSString *strParam = [NSString stringWithFormat:@"?&deviceid=%@&usercode=%@&classid=%@&pagenum=",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user" ],classid];
    NSDictionary *dict = [self bsService:@"productEstimate" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:productEstimateResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *array=[result componentsSeparatedByString:@"@"];
        return array;
    }else
    {
        return nil;
    }
}
#pragma mark - 退菜
-(NSDictionary *)cancleProducts:(NSDictionary *)info
{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:[Singleton sharedSingleton].CheckNum forKey:@"orderid"];
    [dic setObject:[[info objectForKey:@"info"] objectForKey:@"user"] forKey:@"accreditcode"];
    [dic setObject:[[info objectForKey:@"info"] objectForKey:@"INIT"] forKey:@"backreason"];
    NSMutableArray *foodArray=[[NSMutableArray alloc] init];
    for (NSDictionary *dict in [info objectForKey:@"dataArray"]) {
        NSMutableDictionary *food=[[NSMutableDictionary alloc] init];
        [food setObject:[dict objectForKey:@"Pcode"] forKey:@"pcode"];
        [food setObject:[dict objectForKey:@"pcount"] forKey:@"canclecount"];
        [food setObject:[dict objectForKey:@"PKID"] forKey:@"pkid"];
        [food setObject:[dict objectForKey:@"weightflg"] forKey:@"weightflg"];
        [food setObject:[dict objectForKey:@"ISTC"] forKey:@"istc"];
        [food setObject:[dict objectForKey:@"UnitCode"] forKey:@"unitcode"];
        [food setObject:[dict objectForKey:@"istemp"] forKey:@"istemp"];
        [food setObject:[dict objectForKey:@"CLASS"] forKey:@"jiorjiao"];
        [food setObject:[dict objectForKey:@"fujiacode"] forKey:@"fujiacode "];
        [foodArray addObject:food];
    }
    [dic setObject:foodArray forKey:@"dishList"];
    
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&json=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user" ],[dic JSONRepresentation]];
    NSDictionary *returnDic = [self bsService:@"cancleProducts" arg:strParam];
    if (returnDic) {
        SBJsonParser * parser = [[SBJsonParser alloc]init];
        NSMutableString *strResponser=[[[returnDic objectForKey:@"ns:cancleProductsResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSMutableDictionary *dicMessageInfo = [parser objectWithString:strResponser];
        return dicMessageInfo;
    }
    return returnDic;
}
-(NSDictionary *)queryAllOrders
{
    //    NSString *result = @"0@pcode;菜品名称;实际销售量;预估销售量;百分比@pcode;菜品名称;实际销售量;预估销售量;百分比";
    //    NSArray *array=[result componentsSeparatedByString:@"@"];
    //    return array;
    
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user" ]];
    NSDictionary *dict = [self bsService:@"queryAllOrders" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:queryAllOrdersResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *array=[result componentsSeparatedByString:@"@"];
        if ([[array objectAtIndex:0] intValue]==0) {
            NSMutableArray *array1=[[array objectAtIndex:1] componentsSeparatedByString:@"&"];
            if ([array1 count]>1) {
                [array1 removeLastObject];
            }
            
            NSMutableArray *returnArray=[[NSMutableArray alloc] init];
            for (NSString *str in array1) {
                NSArray *array2=[str componentsSeparatedByString:@";"];
                NSMutableDictionary *dict1=[[NSMutableDictionary alloc] init];
                [dict1 setObject:[array2 objectAtIndex:0] forKey:@"orderid"];
                [dict1 setObject:[array2 objectAtIndex:1] forKey:@"Tablename"];
                [dict1 setObject:[array2 objectAtIndex:2] forKey:@"Orderstate"];
                [returnArray addObject:dict1];
            }
            return [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"tag",returnArray,@"message", nil];
        }else
        {
            return [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"tag",[array objectAtIndex:1],@"message", nil];
        }
    }else
    {
        return nil;
    }
}
- (BOOL)activated{
    return [self checkActivated];
}
#pragma mark - 在线会员
//string onelineQueryCardByMobTel(string deviceId,QString userCode,QString telNum );
/**
 *  @author ZhangPo, 15-05-07 14:05:03
 *
 *  @brief  根据手机号查询卡号
 *
 *  @param telNum 手机号
 *
 *  @return 手机号
 *
 *  @since
 */
-(NSDictionary *)onelineQueryCardByMobTel:(NSString *)telNum
{
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&telNum=%@&orderid=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],telNum,[Singleton sharedSingleton].CheckNum];
    NSDictionary *dict = [self bsService:@"onelineQueryCardByMobTel" arg:strParam];
    if (dict) {
         NSString *jsonStr=[[[dict objectForKey:@"ns:onelineQueryCardByMobTelResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        SBJsonParser * parser = [[SBJsonParser alloc]init];
        NSMutableDictionary *dicMessageInfo = [parser objectWithString:jsonStr];
        return dicMessageInfo;
    }
   
    return dict;
}
/**
 *  @author ZhangPo, 15-05-07 14:05:10
 *
 *  @brief  根据卡号查询卡信息
 *
 *  @param cardNum 卡号
 *
 *  @return 卡信息
 *
 *  @since
 */
-(NSDictionary *)onelineQueryCardByCardNo:(NSString *)cardNum
{
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&cardNum=%@&orderid=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],cardNum,[Singleton sharedSingleton].CheckNum];
    NSDictionary *dict = [self bsService:@"onelineQueryCardByCardNo" arg:strParam];
    if (dict) {
        NSString *jsonStr=[[[dict objectForKey:@"ns:onelineQueryCardByCardNoResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        SBJsonParser * parser = [[SBJsonParser alloc]init];
        NSMutableDictionary *dicMessageInfo = [parser objectWithString:jsonStr];
        return dicMessageInfo;
    }
    
    return dict;
}
#pragma mark - 活动使用
-(NSDictionary *)activityUserCounp:(NSDictionary *)info{
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"jmtyp",@"0",@"ryzktyp", nil];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@&counpId=%@&counpCnt=%@&counpMoney=%@&json=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum,[info objectForKey:@"CODE"],@"1",[info objectForKey:@"OPERATEVALUE"],[dic JSONRepresentation]];
    NSDictionary *dict = [self bsService:@"userCounp" arg:strParam];
    if (dict) {
        NSString *returnStr=[[[dict objectForKey:@"ns:userCounpResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *array=[returnStr componentsSeparatedByString:@"@"];
        if ([[array objectAtIndex:0] intValue]==0) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",@"成功",@"Message", nil];
        }else
        {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[array objectAtIndex:1],@"Message", nil];
        }
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"查询失败",@"Message", nil];
}
#pragma mark - 预结算账单查询
-(NSDictionary *)paymentViewQueryProduct
{
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@&comOrDetach=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum,@"1"];
    NSDictionary *dict = [self bsService:@"queryProduct" arg:strParam];
    if (dict) {
        float foodPrice,paymentPrice;
        NSMutableDictionary *returnDict=[[NSMutableDictionary alloc] init];
        NSString *returnStr=[[[dict objectForKey:@"ns:queryProductResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *array=[returnStr componentsSeparatedByString:@"#"];
        //菜品解析
        if ([array count]==1) {
            NSArray *foodAry=[[array objectAtIndex:0] componentsSeparatedByString:@"@"];
            if ([[foodAry objectAtIndex:0] intValue]!=0) {
                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"查询失败",@"Message", nil];
            }
        }
        NSMutableArray *foodArrayC=[[array objectAtIndex:0] componentsSeparatedByString:@";"];
        [foodArrayC removeLastObject];
        NSMutableArray *foodArray=[[NSMutableArray alloc] init];
        for (NSString *foodStr in foodArrayC) {
            NSArray *foodAry=[foodStr componentsSeparatedByString:@"@"];
            if ([[foodAry objectAtIndex:0] intValue]!=0) {
                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"查询失败",@"Message", nil];
            }
            NSMutableDictionary *foodDic=[[NSMutableDictionary alloc] init];
            [foodDic setObject:[foodAry objectAtIndex:2] forKey:@"PKID"];
            [foodDic setObject:[foodAry objectAtIndex:3] forKey:@"pcode"];
            [foodDic setObject:[foodAry objectAtIndex:4] forKey:@"PCname"];
            [foodDic setObject:[foodAry objectAtIndex:5] forKey:@"tpcode"];
            [foodDic setObject:[foodAry objectAtIndex:6] forKey:@"TPNAME"];
            [foodDic setObject:[foodAry objectAtIndex:7] forKey:@"TPNUM"];
            [foodDic setObject:[foodAry objectAtIndex:8] forKey:@"pcount"];
            [foodDic setObject:[foodAry objectAtIndex:9] forKey:@"promonum"];
            [foodDic setObject:[foodAry objectAtIndex:10] forKey:@"fujiacode"];
            [foodDic setObject:[foodAry objectAtIndex:11] forKey:@"fujianame"];
            [foodDic setObject:[foodAry objectAtIndex:12] forKey:@"price"];
            [foodDic setObject:[foodAry objectAtIndex:13] forKey:@"fujiaprice"];
            [foodDic setObject:[foodAry objectAtIndex:14] forKey:@"weight"];
            [foodDic setObject:[foodAry objectAtIndex:15] forKey:@"weightflg"];
            [foodDic setObject:[foodAry objectAtIndex:16] forKey:@"unit"];
            [foodDic setObject:[foodAry objectAtIndex:17] forKey:@"ISTC"];
            [foodDic setObject:[NSString stringWithFormat:@"%.2f",[[foodAry objectAtIndex:12] floatValue]+[[foodAry objectAtIndex:13] floatValue]] forKey:@"price"];
            foodPrice+=[[foodAry objectAtIndex:12] floatValue]+[[foodAry objectAtIndex:13] floatValue];
            [foodArray addObject:foodDic];
        }
        [returnDict setObject:foodArray forKey:@"foodList"];
        NSMutableArray *paymentArrayC=[NSMutableArray arrayWithArray:[[array objectAtIndex:1] componentsSeparatedByString:@";"]];
        [paymentArrayC removeLastObject];
        double calculateZero=0.0000;
        NSMutableArray *paymentArray=[[NSMutableArray alloc] init];
        for (NSString *paymentStr in paymentArrayC) {
            NSArray *paymentAry=[paymentStr componentsSeparatedByString:@"@"];
            if ([[paymentAry objectAtIndex:0] intValue]!=0) {
                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"查询失败",@"Message", nil];
            }
            NSMutableDictionary *paymentDic=[[NSMutableDictionary alloc] init];
            [paymentDic setObject:[paymentAry objectAtIndex:2] forKey:@"paymentName"];
            [paymentDic setObject:[paymentAry objectAtIndex:3] forKey:@"paymentPrice"];
            [paymentDic setObject:[paymentAry objectAtIndex:4] forKey:@"paymentCode"];
            [paymentDic setObject:[paymentAry objectAtIndex:5] forKey:@"paymentShowPrice"];
            if ([[paymentAry objectAtIndex:6] intValue]==1) {
                calculateZero+=[[paymentAry objectAtIndex:6] doubleValue];
            }
            paymentPrice+=[[paymentAry objectAtIndex:3] floatValue];
            [paymentArray addObject:paymentDic];
        }
        double ClearZeroMoney=[self ClearZeroFunSumYmoney:foodPrice-calculateZero];
//        double 
        NSMutableDictionary *paymentDic=[[NSMutableDictionary alloc] init];
        [paymentDic setObject:@"账单金额" forKey:@"paymentName"];
        [paymentDic setObject:[NSString stringWithFormat:@"%.2f",foodPrice] forKey:@"paymentShowPrice"];
        [paymentArray insertObject:paymentDic atIndex:0];
        [returnDict setObject:paymentArray forKey:@"paymentList"];
        NSLog(@"%@",returnDict);
        NSArray *ary2=[[array objectAtIndex:2] componentsSeparatedByString:@"@"];
        if ([[ary2 objectAtIndex:0] intValue]==0) {
            [Singleton sharedSingleton].man=[ary2 objectAtIndex:1];
            [Singleton sharedSingleton].woman=[ary2 objectAtIndex:2];
        }
        NSArray *ary3=[[array objectAtIndex:3] componentsSeparatedByString:@";"];
        NSMutableString *str=[NSMutableString string];
        for (NSString *result2 in ary3) {
            NSArray *ary3=[result2 componentsSeparatedByString:@"@"];
            if ([ary3 count]==2) {
                [str appendFormat:@"%@ ",[ary3 objectAtIndex:1]];
            }
        }
        [returnDict setObject:str forKey:@"whole"];
        [returnDict setObject:[NSString stringWithFormat:@"%.2f",ClearZeroMoney] forKey:@"CLEARZERO"];
        [returnDict setObject:[NSString stringWithFormat:@"%.2f",foodPrice] forKey:@"foodPrice"];
        [returnDict setObject:[NSString stringWithFormat:@"%.2f",foodPrice-paymentPrice-ClearZeroMoney] forKey:@"paymentPrice"];
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",returnDict,@"Message", nil];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"查询失败",@"Message", nil];
}
#pragma mark - 会员支付
-(NSDictionary *)onelineCardOutAmt:(NSDictionary *)info{
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&json=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[info JSONRepresentation]];
    NSDictionary *dict = [self bsService:@"onelineCardOutAmt" arg:strParam];
    if (dict) {
        NSString *returnStr=[[[dict objectForKey:@"ns:onelineCardOutAmtResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        SBJsonParser * parser = [[SBJsonParser alloc]init];
        NSMutableDictionary *dicMessageInfo = [parser objectWithString:returnStr];
        return dicMessageInfo;
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:@"-1",@"return",@"查询失败",@"error", nil];
}
#pragma mark - 根据券查询活动
-(NSDictionary *)couponForTicket:(NSDictionary *)ticket
{
    return [[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from coupon_main where VVOUCHERCODE ='%@'",[ticket objectForKey:@"couponCode"]]] lastObject];
}
#pragma mark - 现金银行卡支付
-(NSDictionary *)userPayment:(NSDictionary *)info{
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@&paymentId=%@&paymentCnt=%@&mpaymentMoney=%@&payFinish=%@&integralOverall=%@&cardNumber=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user" ],[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum,[info objectForKey:@"paymentID"],[info objectForKey:@"paymentCnt"],[info objectForKey:@"paymentMoney"],[info objectForKey:@"payFinish"],[info objectForKey:@"integralOverall"],[info objectForKey:@"cardNumber"]];
    NSDictionary *dict = [self bsService:@"userPayment" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:userPaymentResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *array=[result componentsSeparatedByString:@"@"];
        if ([[array objectAtIndex:0] intValue]==0) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",@"支付完成",@"Message", nil];
        }else
        {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"支付失败",@"Message", nil];
        }
    }else
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"支付失败",@"Message", nil];
    }
}
#pragma mark - 活动查询
-(NSArray *)selectCoupon
{
    NSArray *coupon_kindArray=[BSDataProvider getDataFromSQLByCommand:@"select * from coupon_kind"];
    for (NSDictionary *dict in coupon_kindArray) {
        NSArray *coupon_mainArray=[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from coupon_main WHERE KINDID='%@' and ISSHOW='1'",[dict objectForKey:@"KINDID"]]];
        [dict setValue:coupon_mainArray forKey:@"coupon_main"];
    }
    return coupon_kindArray;
}
#pragma mark - 取消支付接口
-(NSDictionary *)cancleUserPayment:(NSString *)passWord
{
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:passWord,@"cardPassword", nil];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@&json=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user" ],[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum,[dic JSONRepresentation]];
    NSDictionary *dict = [self bsService:@"cancleUserPayment" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:cancleUserPaymentResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *array=[result componentsSeparatedByString:@"@"];
        if ([[array objectAtIndex:0] intValue]==0) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[array objectAtIndex:1],@"Message", nil];
        }else
        {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[array objectAtIndex:1],@"Message", nil];
        }
    }else
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"取消支付失败",@"Message", nil];
    }
}
#pragma mark - 取消优惠
-(NSDictionary *)cancleUserCounp
{
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user" ],[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum];
    NSDictionary *dict = [self bsService:@"cancleUserCounp" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:cancleUserCounpResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *array=[result componentsSeparatedByString:@"@"];
        if ([[array objectAtIndex:0] intValue]==0) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[array objectAtIndex:2],@"Message", nil];
        }else
        {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[array objectAtIndex:1],@"Message", nil];
        }
    }else
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"取消优惠失败",@"Message", nil];
    }
}
//@"SELECT *FROM settlementoperate WHERE OPERATEGROUPID='5'"
#pragma mark - 查询银行卡
-(NSArray *)selectBankArray
{
    return [BSDataProvider getDataFromSQLByCommand:@"SELECT *FROM settlementoperate WHERE OPERATEGROUPID='31'"];
}
#pragma mark - 查询现金
-(NSArray *)selectCashArray
{
    return [BSDataProvider getDataFromSQLByCommand:@"SELECT *FROM settlementoperate WHERE OPERATEGROUPID='5'"];
}
#pragma mark - 查询网络支付
-(NSArray *)selectOnlinePaymentArray
{
    return [BSDataProvider getDataFromSQLByCommand:@"SELECT *FROM settlementoperate WHERE OPERATEGROUPID in('50','48')"];
}
#pragma mark - 查询是否存在会员消费
-(NSDictionary *)memberConsumptionRecord
{
    return [self querySqlInterface:[NSString stringWithFormat:@"select count(*) from cardordrs where PCONACCT = '%@' and pserial not in(select pserialor from changeamt where pflag = '2') ORDER BY miscode DESC",[Singleton sharedSingleton].CheckNum]];
}
#pragma mark - 查询需要支付列表
-(NSDictionary *)shouldCheckData
{
    return [self querySqlInterface:@"SELECT a.TABLENUM,a.ORDERID,b.TBLNAME,a.PEOLENUMMAN,a.PEOLENUMWOMEN FROM handevtableorder_relation a left JOIN storetables_mis b ON a.TABLENUM=b.TABLENUM WHERE TABLESTATE='0' and MOBILEBILLOK='1'"];
//    return [self querySqlInterface:@"SELECT a.TABLENUM,a.ORDERID,b.TBLNAME,a.PEOLENUMMAN,a.PEOLENUMWOMEN FROM handevtableorder_relation a left JOIN storetables_mis b ON a.TABLENUM=b.TABLENUM WHERE TABLESTATE='0'"];
}
-(NSDictionary *)updateTableStata
{
    return [self querySqlInterface:[NSString stringWithFormat:@"UPDATE handevtableorder_relation SET TABLESTATE ='0' WHERE ORDERID='%@'",[Singleton sharedSingleton].CheckNum]];
}

#pragma mark - 扫描支付
-(NSDictionary *)scanCode:(NSDictionary *)alipayDic
{
    NSString *type=nil;
    if ([[alipayDic objectForKey:@"OPERATEGROUPID"] intValue]==50) {
        type=@"1";
    }else
    {
        type=@"2";
    }
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:[alipayDic objectForKey:@"OPERATE"],@"operate",[alipayDic objectForKey:@"auth_code"],@"auth_code",@"0.01",@"total_fee",[Singleton sharedSingleton].CheckNum,@"orderid",@"1",@"finished",type,@"type",nil];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&json=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[dic JSONRepresentation]];
    NSDictionary *dict = [self bsService:@"scanCode" arg:strParam];
    if (dict) {
        NSString *returnStr=[[[dict objectForKey:@"ns:scanCodeResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        SBJsonParser * parser = [[SBJsonParser alloc]init];
        NSMutableDictionary *dicMessageInfo = [parser objectWithString:returnStr];
        return dicMessageInfo;
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:@"-1",@"return",@"支付失败",@"error", nil];
}
#pragma mark - 微信上传
-(NSDictionary *)pushWeChatCheckOut:(NSDictionary *)info
{
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&json=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],[info JSONRepresentation]];
    NSDictionary *dict = [self bsService:@"pushWeChatCheckOut" arg:strParam];
    if (dict) {
        NSString *returnStr=[[[dict objectForKey:@"ns:pushWeChatCheckOutResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        SBJsonParser * parser = [[SBJsonParser alloc]init];
        NSMutableDictionary *dicMessageInfo = [parser objectWithString:returnStr];
        return dicMessageInfo;
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:@"-1",@"return",@"上传失败",@"error", nil];
}
#pragma mark - 更新版本号
-(NSDictionary *)updateDataVersion:(NSString *)dataVersion
{
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&dataVersion=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],dataVersion];
    NSDictionary *dict = [self bsService:@"updateDataVersion" arg:strParam];
    if (dict) {
        NSString *returnStr=[[[dict objectForKey:@"ns:updateDataVersionResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *array=[returnStr componentsSeparatedByString:@"@"];
        if ([[array objectAtIndex:0] intValue]==0) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[array objectAtIndex:1],@"Message", nil];
        }else
        {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[array objectAtIndex:1],@"Message", nil];
        }
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"更新失败",@"Message", nil];
//    return [NSDictionary dictionaryWithObjectsAndKeys:@"-1",@"return",@"上传失败",@"error", nil];
}
#pragma mark - 通用查询 sql 语句接口
-(NSDictionary *)querySqlInterface:(NSString *)sql
{
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSTimeZone *zone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    NSInteger interval = [zone secondsFromGMTForDate:datenow];
    NSDate *localeDate = [datenow  dateByAddingTimeInterval: interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy"];
    //用[NSDate date]可以获取系统当前时间
    int  yy = [[dateFormatter stringFromDate:localeDate] intValue];
    [dateFormatter setDateFormat:@"MM"];
    //用[NSDate date]可以获取系统当前时间
    int MM = [[dateFormatter stringFromDate:localeDate] intValue];
    [dateFormatter setDateFormat:@"dd"];
    //用[NSDate date]可以获取系统当前时间
    int dd = [[dateFormatter stringFromDate:localeDate] intValue];
    NSString *str=[NSString stringWithFormat:@"HHT%d%.2d%.2d",yy+1,MM-1,dd+1];
    NSLog(@"%@",str);
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&strsql=%@&parityBit=%@",[self padID],[[Singleton sharedSingleton].userInfo objectForKey:@"user"],sql,[self md5:str]];
    NSDictionary *dict = [self bsService:@"querySqlInterface" arg:strParam];
    if (dict) {
        NSString *returnStr=[[[dict objectForKey:@"ns:querySqlInterfaceResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        SBJsonParser * parser = [[SBJsonParser alloc]init];
        NSMutableDictionary *dicMessageInfo = [parser objectWithString:returnStr];
        return dicMessageInfo;
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:@"-1",@"return",@"查询失败",@"error", nil];
}
- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}
/****************
 功能：抹零金额计算
 修改时间：2014-04-16
 参数1 抹零方式        clearMoneyYN  1 向下 2 向上 3 四舍五入
 要抹零的金额          sumYmoney
 抹零金额              ClearZeroMoney
 抹零到那一位          dClearBit 100 抹零到百位 10 抹零到十位 1 抹零到个位 0.1抹零到第一位小数 0.01抹零到两位小数
 抹零金额保留位小数位   iDoubleBitn
 ***************/
-(double)ClearZeroFunSumYmoney:(double)sumYmoney
{
    NSDictionary *dict=[[BSDataProvider getDataFromSQLByCommand:@"select * from posdb"] lastObject];
    double ClearZeroMoney =0.0000;
    double desMoney = sumYmoney;//抹零前合计金额
    if([[dict objectForKey:@"CLEARMONEYYN"] intValue]==1)
    {//向下抹零
        if(desMoney>0.0001 || desMoney>-0.0001){
            desMoney = desMoney+0.0000001;
        }
        else
        {
            desMoney = desMoney-0.0000001;
        }
        ClearZeroMoney =fmod(desMoney,[[dict objectForKey:@"CLEARMONEYBIT"] floatValue]);//取余数 要抹掉部分
    }
    else if([[dict objectForKey:@"CLEARMONEYYN"] intValue]==2)
    {//向上抹零
        ClearZeroMoney =fmod(desMoney,[[dict objectForKey:@"CLEARMONEYBIT"] floatValue]);
        if(!(ClearZeroMoney>-0.001 && ClearZeroMoney<0.001))
        {
            ClearZeroMoney = [[dict objectForKey:@"CLEARMONEYBIT"] floatValue]-ClearZeroMoney;
        }
        if(!(ClearZeroMoney>-0.001 && ClearZeroMoney<0.001))
        {
            ClearZeroMoney=-ClearZeroMoney;
        }
    }
    else
    {//四舍五入
        ClearZeroMoney =fmod(desMoney,[[dict objectForKey:@"CLEARMONEYBIT"] floatValue]);
        ClearZeroMoney=[[NSString stringWithFormat:@"%.6f",ClearZeroMoney] doubleValue];
        double ipart = [[dict objectForKey:@"CLEARMONEYBIT"] floatValue]/2;
        double diff = ClearZeroMoney-ipart;
        if(!(ClearZeroMoney>-0.0001 && ClearZeroMoney<0.0001))
        {
            if(ClearZeroMoney<=([[dict objectForKey:@"CLEARMONEYBIT"] floatValue]-ClearZeroMoney) && !(diff<0.0001 && diff>-0.0001))
            {//舍
                sumYmoney = desMoney-ClearZeroMoney;
            }
            else
            {//入
                sumYmoney = desMoney+([[dict objectForKey:@"CLEARMONEYBIT"] floatValue]-ClearZeroMoney);
                ClearZeroMoney =ClearZeroMoney-[[dict objectForKey:@"CLEARMONEYBIT"] floatValue];
            }
        }
    }
    return ClearZeroMoney;
}
@end
