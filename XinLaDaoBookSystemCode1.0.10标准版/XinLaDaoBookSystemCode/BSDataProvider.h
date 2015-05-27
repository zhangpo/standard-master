//
//  BSDataProvider.h
//  BookSystem
//
//  Created by Dream on 11-3-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <sqlite3.h>
//#import "AKsNetAccessClass.h"
#import "BSWebServiceAgent.h"
#define kPlistPath      @"ftp://shipader:shipader123@61.174.28.122/BookSystem/BookSystem.sqlite"
#define kPathHeader      @"ftp://ipad:ipad@10.211.55.4/BookSystem/"
#define kSocketServer   @"192.168.1.115:8080"
#define kPDAID          @"8"
#define kDianPuId       @"600000"
#define  TCHAR unsigned char




@interface BSDataProvider : NSObject<NSStreamDelegate>
-(NSMutableArray *)allCombo;//查询所有的套餐明细
-(NSString *)scratch:(NSDictionary *)info andtag:(int)tag;//划菜反划菜
-(NSDictionary *)queryCompletely;//全单
-(NSArray *)specialremark;//全单附加项
-(NSArray *)presentreason;//赠送原因
-(NSArray *)soldOut;//估清
-(void)updatecombineTable:(NSDictionary *)dict :(NSString *)cheak;//并台更改数据库
-(void)delectcombo:(NSString *)tpcode andNUM:(NSString *)num;//删除缓存里的套餐
-(void)delectdish:(NSString *)code;//单独删除
-(NSString *)UUIDString;//物理编号
-(NSArray *)chkCodesql;//查询退菜原因
-(void)delectCache;//清除缓存
-(void)reserveCache:(NSArray *)ary;//预定台位存入
-(NSMutableArray *)selectCache;//查询缓存
-(NSArray *)logout;//登出
-(NSString *)registerDeviceId:(NSString *)str;//注册
-(void)cache:(NSArray *)ary;//缓存
-(NSMutableArray *)queryProduct1:(NSString *)seat;//根据台位查账单
-(NSDictionary *)specialRemark:(NSArray *)ary;//全单附加项
-(void)updateChangTable:(NSDictionary *)info :(NSString *)cheak;//换台更改数据库
- (NSDictionary *)pListTable:(NSDictionary *)info;//查询台位
-(NSDictionary *)priPrintOrder:(NSDictionary *)info;//预打印
-(NSDictionary *)combineTable:(NSDictionary *)info;//并台
//-(void)gogoOrderUpData:(NSDictionary *)info;//催菜成功修改数据库
//-(void)gogoOrderUpData:(NSString *)name withCode:(NSString *)code whitTPNUM:(NSString *)tpnum;//催菜成功修改数据库
-(NSDictionary *)changTableState:(NSDictionary *)info;//改变台位状态
-(NSDictionary *)chkCode:(NSArray *)array info:(NSDictionary *)info;//退菜
-(NSDictionary *)checkAuth1:(NSDictionary *)info;//授权
-(NSString *)scratch:(NSArray *)dish;//划菜
//-(int)updata:(NSDictionary *)dict withNum:(NSString *)num withOver:(NSString *)over;
//+(int)updata:(NSString *)table orderID:(NSString *)order pkid:(NSString *)pkid code:(NSString *)code Over:(NSString *)over;//数据库划菜
+(NSArray *)tableNum:(NSString *)table orderID:(NSString *)order;//查找本地的发送的菜
//-(NSArray *)AllCheak;
-(NSDictionary *)getOrdersBytabNum1:(NSString *)str;//根据台位号查账单
-(NSMutableArray *)combo:(NSDictionary *)tag;//查套餐明细
+ (NSString *)sqlitePath;//数据库的地址
- (NSDictionary *)pStart:(NSDictionary *)info;//开台
- (NSDictionary *)pChangeTable:(NSDictionary *)info;//换台
- (NSDictionary *)pGogo:(NSArray *)array;//催菜
- (NSArray *)getArea;//根据区域分
- (NSArray *)getFloor;//根据楼层分
- (NSArray *)getStatus;//根据状态分
- (NSDictionary *)checkFoodAvailable:(NSArray *)ary info:(NSDictionary *)info tag:(int)tag;//发送菜
- (NSDictionary *)bsService:(NSString *)api arg:(NSString *)arg;//网络请求
- (NSDictionary *)pLoginUser:(NSDictionary *)info;//登陆
-(NSArray *)getClassById;//查询菜品分类
- (NSArray *)getAdditions:(NSString *)pcode;//查数据库里的附加项
-(NSArray *)getAdditionsAndClass;                   //附加项和类别
- (NSDictionary *)dictFromSQL;//根据FTP下载文件名的数据库
+ (NSMutableArray *)getFoodList:(NSString *)cmd;//获得全部的菜品
-(NSString *)consumerCouponCode:(NSDictionary *)info;//团购验证
-(NSDictionary *)ComputingServicefee:(NSString *)type;  //计算服务费

-(NSArray *)productEstimate:(NSString *)classid;//销售预定比率
-(NSArray *)SelectPrivateAddition:(NSString *)pcode;
-(NSDictionary *)queryAllOrders;                        //查询全部账单
-(NSDictionary *)cancleProducts:(NSDictionary *)info;        //退菜
#pragma mark - 激活
- (BOOL)activated;


#pragma mark - 在线会员
-(NSDictionary *)onelineQueryCardByMobTel:(NSString *)telNum;
-(NSDictionary *)onelineQueryCardByCardNo:(NSString *)cardNum;


-(NSDictionary *)activityUserCounp:(NSDictionary *)info;            //活动使用
-(NSDictionary *)paymentViewQueryProduct;                           //查询账单
-(NSDictionary *)couponForTicket:(NSDictionary *)ticket;            //根据券编码查询活动
-(NSDictionary *)onelineCardOutAmt:(NSDictionary *)info;            //会员消费
-(NSDictionary *)userPayment:(NSDictionary *)info;                  //现金银行卡支付
-(NSArray *)selectCoupon;                                           //查询全部的活动
-(NSDictionary *)cancleUserPayment:(NSString *)passWord;            //取消支付
-(NSDictionary *)cancleUserCounp;                                   //取消优惠
-(NSArray *)selectBankArray;                                        //查询银行卡
-(NSArray *)selectCashArray;                                        //查询现金
-(NSArray *)selectOnlinePaymentArray;                               //查询网络支付
//-(NSDictionary *)querySqlInterface:(NSString *)sql;                 //通用查询 sql 语句接口
-(NSDictionary *)memberConsumptionRecord;                           //查询是否存在会员消费
-(NSDictionary *)scanCode:(NSDictionary *)alipayDic;                //支付失败
-(double)ClearZeroFunclearMoneyYN:(int) clearMoneyYN withSumYmoney:(double)sumYmoney withClearZeroMoney:(double) ClearZeroMoney withClearBit:(double) dClearBit;        //抹零计算
-(NSDictionary *)shouldCheckData;                                   //查询需要支付接口
-(NSDictionary *)updateTableStata;                                  //改变台位占用状态
-(NSDictionary *)pushWeChatCheckOut:(NSDictionary *)info;           //微信上传
-(NSDictionary *)updateDataVersion:(NSString *)dataVersion;         //更新版本号
@end

