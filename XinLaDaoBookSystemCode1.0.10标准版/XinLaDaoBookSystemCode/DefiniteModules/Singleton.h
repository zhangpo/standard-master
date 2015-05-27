//
//  Singleton.h
//  BookSystem
//
//  Created by chensen on 13-11-22.
//
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject
{
    BOOL     _isYudian;
}
@property(nonatomic,strong)NSMutableArray *dishArray;
@property(nonatomic,strong)NSDictionary *userInfo;
@property(nonatomic,strong)NSString *Seat;
@property(nonatomic,strong)NSString *tableName;
@property(nonatomic,strong)NSString *CheckNum;
@property(nonatomic,strong)NSString *Time;
@property(nonatomic,strong)NSString *man;
@property(nonatomic,strong)NSString *woman;
@property(nonatomic,strong)NSString *jurisdiction;
@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSDictionary *VIPCardInfo;
@property(nonatomic,strong)NSDictionary *cardMessage;
@property(nonatomic)int segment;
@property(nonatomic,strong)NSMutableArray *order;
@property(nonatomic)BOOL quandan;
@property(nonatomic)BOOL SELEVIP;
@property(nonatomic,strong)NSString *WaitNum;
@property(nonatomic)BOOL isYudian;
+(Singleton *)sharedSingleton;
@end
