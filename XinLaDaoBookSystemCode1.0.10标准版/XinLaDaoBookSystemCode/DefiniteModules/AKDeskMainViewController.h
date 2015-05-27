//
//  AKDeskMainViewController.h
//  BookSystem
//
//  Created by chensen on 13-11-7.
//
//

#import <UIKit/UIKit.h>
#import "BSTableButton.h"           //台位按钮类
#import "AKSwitchTableView.h"
#import "BSOpenTableView.h"         //开台类
#import "AKsWaitSeat.h"             //等位类
#import "AKsWaitSeatOpenTable.h"    //等位开台
//#import "AKsNetAccessClass.h"       //单例
#import "AKschangeTableView.h"      //等位转正式台
#import "AKsYudianShow.h"           //预定显示
#import "AKsRemoveYudingView.h"
#import "WebChildrenTable.h"
#import "AKsOpenSucceed.h"          //等位成功以后
#import "AKShouldCheckView.h"
#define kOpenTag    700
#define kCancelTag  701
#define kdish       702

@interface AKDeskMainViewController : UIViewController<BSTableButtonDelegate,AKSwitchTableViewDelegate,OpenTableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,AKsWaitSeatDelegate,AKsWaitSeatOpenTableDelegate,AKschangeTableViewDelegate,AKsYudianShowDelegate,AKsRemoveYudingViewDelegate,UISearchBarDelegate,AKsOpenSucceedDelegate,WebChildrenTableDelegate,AKShouldCheckViewDelegate>
{
    AKSwitchTableView *vSwitch;
    BSOpenTableView *vOpen;
    NSMutableArray *deskClassArray;
    NSMutableArray *DESArray;
    UIScrollView *scvTables;
}
@property (nonatomic, retain) NSDictionary *checkTableInfo;
@end
