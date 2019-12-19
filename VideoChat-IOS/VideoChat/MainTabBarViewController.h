
#import <UIKit/UIKit.h>

@interface MainTabBarViewController : UITabBarController<UITabBarControllerDelegate>

+(MainTabBarViewController *)instance;

-(void)setMainTabBarSelectedIndex:(NSUInteger)selectedIndex;

@end
