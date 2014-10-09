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
#import "AKsNetAccessClass.h"
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonCrypto.h>
#import <AdSupport/AdSupport.h>
#import "OpenUDID.h"
#import "UIKitUtil.h"
#import "CardJuanClass.h"
#import "CVLocalizationSetting.h"

//#import "PaymentSelect.h"


@implementation BSDataProvider

//static BSDataProvider *sharedInstance = nil;
//static NSDictionary *infoDict = nil;
//static NSDictionary *dicCurrentPageConfig = nil;
//static NSDictionary *dicCurrentPageConfigDetail = nil;
//static NSArray *aryPageConfigList = nil;
//static NSLock *_loadingMutex = nil;
//static NSMutableArray *aryOrders = nil;
//static NSArray *aryAllDetailPages = nil;
//static NSArray *aryAllPages = nil;
//static int dSendCount = 0;

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
    NSMutableArray *array=[cacheDict objectForKey:[Singleton sharedSingleton].Seat];
A:
    for (NSDictionary *dict in array) {
        if ([[dict objectForKey:@"ITCODE"] isEqualToString:tpcode]&&[[dict objectForKey:@"TPNUM"]isEqualToString:num]) {
            [array removeObject:dict];
            goto A;
            break;
        }
    }
    [cacheDict setObject:array forKey:[Singleton sharedSingleton].Seat];
    [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
}
/**
 *  删除保存的单个菜品
 *
 *  @param code
 */
-(void)delectdish:(NSString *)code
{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    NSMutableArray *array=[cacheDict objectForKey:[Singleton sharedSingleton].Seat];
A:
    for (NSDictionary *dict in array) {
        if ([[dict objectForKey:@"ITCODE"] isEqualToString:code]) {
            [array removeObject:dict];
            goto A;
            break;
        }
    }
    [cacheDict setObject:array forKey:[Singleton sharedSingleton].Seat];
    [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
}
/**
 *  缓存菜品信息
 *
 *  @param ary 菜品
 */
-(void)cache:(NSArray *)ary
{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    [cacheDict setObject:ary forKey:[Singleton sharedSingleton].Seat];
    [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
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
 *  退菜原因
 *
 *  @return
 */
-(NSArray *)chkCodesql{
    NSMutableArray *ary = [BSDataProvider getDataFromSQLByCommand:@"select * from ERRORCUSTOM where STATE=1"];
    return ary;
}
/**
 *  查询缓存的菜品
 *
 *  @return
 */
-(NSMutableArray *)selectCache
{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    NSMutableArray *array=[cacheDict objectForKey:[Singleton sharedSingleton].Seat];
    return array;
}
/**
 *  删除缓存
 */
-(void)delectCache
{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    [cacheDict removeObjectForKey:[Singleton sharedSingleton].Seat];
    [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
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
-(NSDictionary *)priPrintOrder
{
    NSString *pdanum = [NSString stringWithFormat:@"%@",[self padID]];
    NSString *user=[NSString stringWithFormat:@"%@",[[Singleton sharedSingleton].userInfo objectForKey:@"user"]];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@",pdanum,user,[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum];
    
    NSDictionary *dict = [self bsService:@"PrintOrder" arg:strParam];
    
    return dict;
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
    FMDatabase *db=[[FMDatabase alloc] initWithPath:[BSDataProvider sqlitePath]];
    if(![db open])
    {
    }
    NSString *str=[NSString stringWithFormat:@"UPDATE AllCheck SET tableNum = '%@' WHERE tableNum = '%@' and orderId='%@'",[info objectForKey:@"newtable"],[info objectForKey:@"oldtable"],cheak];
    NSLog(@"%@",str);
    [db executeUpdate:str];
    [db close];
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
    [fanfood appendFormat:@"%@@%@@%@@%@@%@@%@@%@@%@",[info objectForKey:@"Pcode"],[info objectForKey:@"Tpcode"],[info objectForKey:@"TPNUM"],[info objectForKey:@"fujiacode"],[info objectForKey:@"Weightflg"],[info objectForKey:@"ISTC"],[info objectForKey:@"count"],[info objectForKey:@"PKID"]];
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
    for (NSDictionary *info in dish) {
        if ([[info objectForKey:@"Over"] intValue]==[[info objectForKey:@"pcount"] intValue]) {
            if ([info objectForKey:@"fujiacode"]==nil) {
                [info setValue:@"" forKey:@"fujiacode"];
            }
            if ([info objectForKey:@"Weightflg"]==nil) {
                [info setValue:@"" forKey:@"Weightflg"];
            }
            [fanfood appendFormat:@"%@@%@@%@@%@@%@@%@@%@@%@",[info objectForKey:@"Pcode"],[info objectForKey:@"Tpcode"],[info objectForKey:@"TPNUM"],[info objectForKey:@"fujiacode"],[info objectForKey:@"Weightflg"],[info objectForKey:@"ISTC"],[info objectForKey:@"Over"],[info objectForKey:@"PKID"]];
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
            [mutfood appendFormat:@"%@@%@@%@@%@@%@@%@@%d@%@",[info objectForKey:@"Pcode"],[info objectForKey:@"Tpcode"],[info objectForKey:@"TPNUM"],[info objectForKey:@"fujiacode"],[info objectForKey:@"Weightflg"],[info objectForKey:@"ISTC"],[[info objectForKey:@"pcount"] intValue]-[[info objectForKey:@"Over"] intValue],[info objectForKey:@"PKID"]];
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
-(NSMutableArray *)queryProduct:(NSString *)seat
{
    NSString *pdanum = [NSString stringWithFormat:@"%@",[self padID]];
    NSString *user=[NSString stringWithFormat:@"%@",[[Singleton sharedSingleton].userInfo objectForKey:@"user"]];
    NSString *tableNum=seat;
    NSString *api=[NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&manCounts=%@&womanCounts=%@&orderId=%@&chkCode=%@&comOrDetach=%@",pdanum,user,tableNum,@"",@"",@"",@"",@"0"];
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
                    candan.fujiaprice=[NSString stringWithFormat:@"%.2f",addtition];
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
        [dataDic setValue:[ary objectAtIndex:0] forKey:@"tag"];
        if ([[ary objectAtIndex:0] intValue]==0) {
            NSArray *valuearray = [str1 componentsSeparatedByString:@"#"];
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
                NSLog(@"%@",VipJuan);
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
            NSArray *array=[[ary objectAtIndex:1] componentsSeparatedByString:@";"];
            
            [dataDic setValue:array forKey:@"message"];
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
-(NSDictionary *)checkAuth:(NSDictionary *)info
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
    NSLog(@"%@",dict1);
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
                [mutDic setValue:[itemAry objectAtIndex:1]  forKey:@"orderId"];
                [mutDic setValue:[itemAry objectAtIndex:2]  forKey:@"PKID"];
                [mutDic setValue:[itemAry objectAtIndex:3]  forKey:@"Pcode"];
                [mutDic setValue:[itemAry objectAtIndex:4]  forKey:@"PCname"];
                [mutDic setValue:[itemAry objectAtIndex:5]  forKey:@"Tpcode"];
                [mutDic setValue:[itemAry objectAtIndex:6]  forKey:@"TPNAME"];
                [mutDic setValue:[itemAry objectAtIndex:7]  forKey:@"TPNUM"];
                [mutDic setValue:[itemAry objectAtIndex:8]  forKey:@"pcount"];
                [mutDic setValue:[itemAry objectAtIndex:9]  forKey:@"promonum"];
                [mutDic setValue:[itemAry objectAtIndex:10] forKey:@"fujiacode"];
                [mutDic setValue:[itemAry objectAtIndex:11] forKey:@"fujianame"];
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
                [mutDic setValue:[itemAry objectAtIndex:23] forKey:@"price"];
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
 *  发生菜品
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
    for (int i=0; i<ary.count; i++) {
        NSDictionary *dict=[ary objectAtIndex:i];
        NSString *PKID=@"",*Pcode=@"",*Tpcode=@"",*TPNUM=@"",*pcount=@"",*Price=@"",*Weight=@"",*Weightflg=@"",*isTC=@"",*promonum=@"",*UNIT=@"",*promoReason=@"";
        NSMutableString *Fujiacode,*FujiaName,*FujiaPrice;
        Fujiacode=[NSMutableString string];
        FujiaName=[NSMutableString string];
        FujiaPrice=[NSMutableString string];
        Price=[dict objectForKey:@"PRICE"];//价格
        pcount=[dict objectForKey:@"total"];//数量
        Weight=[dict objectForKey:@"Weight"];//第二单位重量
        Weightflg=[dict objectForKey:@"UNITCUR"];//第二单位标示
        promonum=[dict objectForKey:@"promonum"];//赠送数量
        promoReason=[dict objectForKey:@"promoReason"];//赠送原因
        isTC=[dict objectForKey:@"ISTC"];//套餐
        TPNUM=[dict objectForKey:@"TPNUM"];//套餐标示
        UNIT=[dict objectForKey:@"UNIT"];//单位
        NSArray *array=[dict objectForKey:@"addition"];//附加项
        for (NSDictionary *dict1 in array) {
            [Fujiacode appendFormat:@"%@",[dict1 objectForKey:@"FOODFUJIA_ID"]];//附加项编码
            [Fujiacode appendString:@"!"];
            [FujiaName appendFormat:@"%@",[dict1 objectForKey:@"FoodFuJia_Des"]];//附加项名称
            [FujiaName appendString:@"!"];
            [FujiaPrice appendFormat:@"%@",[dict1 objectForKey:@"FoodFujia_Checked"]];//附加项价格
            [FujiaPrice appendString:@"!"];
        }
        /**
         *  判断是套餐名称
         */
        if ([[dict objectForKey:@"ISTC"] intValue]==1&&![dict objectForKey:@"SUBID"]) {
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
            if ([dict objectForKey:@"SUBID"])
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
        [mutfood appendFormat:@"%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@",PKID,Pcode,@"",Tpcode,@"",TPNUM,pcount,promonum,Fujiacode,FujiaName,Price,FujiaPrice,Weight,Weightflg,UNIT,isTC,promoReason];
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
//-(NSArray *)AllCheak{
//    NSMutableArray *ary = [NSMutableArray array];
//    
//    NSString *path = [BSDataProvider sqlitePath];
//    sqlite3 *db;
//    sqlite3_stmt *stat;
//    NSString *sqlcmd;
//    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
//        sqlcmd = [NSString stringWithFormat:@"select Pcode,PCname,sum(Over),sum(pcount),ISTC from AllCheck where tableNum='%@' AND orderId = '%@' AND Time='%@' AND ISTC='%@' AND Send='%@' GROUP BY Pcode;",[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum,[Singleton sharedSingleton].Time,@"0",@"1"];
//        NSLog(@"%@",sqlcmd);
//        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
//            while (sqlite3_step(stat)==SQLITE_ROW) {
//                int count = sqlite3_column_count(stat);
//                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
//                for (int i=0;i<count;i++){
//                    char *foodKey = (char *)sqlite3_column_name(stat, i);
//                    char *foodValue = (char *)sqlite3_column_text(stat, i);
//                    NSString *strKey = nil,*strValue = nil;
//                    if (foodKey)
//                        strKey = [NSString stringWithUTF8String:foodKey];
//                    if (foodValue)
//                        strValue = [NSString stringWithUTF8String:foodValue];
//                    if (strKey && strValue)
//                        [mutDC setObject:strValue forKey:strKey];
//                }
//                [ary addObject:mutDC];
//            }
//        }
//        sqlite3_finalize(stat);
//    }
//    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
//        sqlcmd = [NSString stringWithFormat:@"select Pcode,PCname,pcount,ISTC,Over,Tpcode,CNT from AllCheck where tableNum='%@' AND orderId = '%@' AND Time='%@' AND ISTC='%@' AND Send='%@'",[Singleton sharedSingleton].Seat,[Singleton sharedSingleton].CheckNum,[Singleton sharedSingleton].Time,@"1",@"1"];
//        NSLog(@"%@",sqlcmd);
//        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
//            while (sqlite3_step(stat)==SQLITE_ROW) {
//                int count = sqlite3_column_count(stat);
//                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
//                for (int i=0;i<count;i++){
//                    char *foodKey = (char *)sqlite3_column_name(stat, i);
//                    char *foodValue = (char *)sqlite3_column_text(stat, i);
//                    NSString *strKey = nil,*strValue = nil;
//                    if (foodKey)
//                        strKey = [NSString stringWithUTF8String:foodKey];
//                    if (foodValue)
//                        strValue = [NSString stringWithUTF8String:foodValue];
//                    if (strKey && strValue)
//                        [mutDC setObject:strValue forKey:strKey];
//                }
//                [ary addObject:mutDC];
//            }
//        }
//        sqlite3_finalize(stat);
//    }
//    sqlite3_close(db);
//    NSLog(@"%@",ary);
//    return ary;
//}
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
    NSString *pdaid,*user,*table,*mancount,*womancounts;
    pdaid = [NSString stringWithFormat:@"%@",[self padID]];
    user = [[Singleton sharedSingleton].userInfo objectForKey:@"user"];
    table = [info objectForKey:@"table"];//台位号
    mancount = [info objectForKey:@"man"];//男人数
    womancounts = [info objectForKey:@"woman"];//女人数
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&manCounts=%@&womanCounts=%@&ktKind=%@&openTablemwyn=%@",pdaid,user,table,mancount,womancounts,@"1",[info objectForKey:@"tag"]];
    NSDictionary *dict = [[self bsService:@"pStart" arg:strParam] objectForKey:@"ns:startcResponse"];
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
    return [NSMutableArray arrayWithArray:ary];
}

/**
 *  根据套餐编码查询套餐明细
 *
 *  @param tag 套餐编码
 *
 *  @return
 */
-(NSMutableArray *)combo:(NSString *)tag{
    
    /**
     *  根据套餐编码查询组
     */
    NSArray *groupArray=[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"SELECT PNAME,PRICE1,PCODE1,PRODUCTTC_ORDER,MAXCNT,MINCNT FROM products_sub a WHERE defualtS = '0' and pcode='%@' GROUP BY PRODUCTTC_ORDER ORDER BY PRODUCTTC_ORDER  ASC",tag]];
    NSMutableArray *returnGroupArray=[NSMutableArray array];
    for (NSDictionary *groupDic in groupArray) {
        /**
         *  套餐明细
         */
        NSMutableArray *productArray=[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"SELECT * FROM food a left JOIN products_sub b on a.itcode=b.pcode WHERE b.pcode='%@' and PRODUCTTC_ORDER='%@' ORDER BY defualtS ASC",tag,[groupDic objectForKey:@"PRODUCTTC_ORDER"]]];
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
            NSMutableArray *productArray=[BSDataProvider getDataFromSQLByCommand:[NSString stringWithFormat:@"SELECT * FROM food a left JOIN products_sub b on a.ITCODE=b.pcode WHERE b.pcode='%@' and PRODUCTTC_ORDER='%@' ORDER BY defualtS ASC",[pcodeDic objectForKey:@"PCODE"],[groupDic objectForKey:@"PRODUCTTC_ORDER"]]];
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
        [mutfood appendFormat:@"%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@",[info objectForKey:@"PKID"],[info objectForKey:@"Pcode"],@"",[info objectForKey:@"Tpcode"],@"",[info objectForKey:@"TPNUM"],[info objectForKey:@"pcount"],[info objectForKey:@"promonum"],[info objectForKey:@"fujiacode"],@"",[info objectForKey:@"price"],[info objectForKey:@"fujiaprice"],[info objectForKey:@"Weight"],[info objectForKey:@"Weightflg"],@"",[info objectForKey:@"ISTC"]];
        [mutfood appendString:@";"];
    }
    NSLog(@"%@",mutfood);
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

- (BOOL)activated{
    return [self checkActivated];
}
@end
