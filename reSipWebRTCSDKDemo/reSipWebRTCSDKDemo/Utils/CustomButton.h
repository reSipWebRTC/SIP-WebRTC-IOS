//
//  CustomButton.h
//  VideoChat
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CustomButton : NSObject

+(UIButton *) addCleanButton:(NSString *)image_name
              backgroundColor:(UIColor *)back_color
                    mainColor:(UIColor *)main_color
                    setBorder:(BOOL)border
                          tag:(NSInteger)tag
                  button_size:(NSInteger)size;

+(UIButton *) addButton:(NSString *)image_name
          backgroundColor:(UIColor *)back_color
                mainColor:(UIColor *)main_color
         highlightedColor:(UIColor *)highlighted_color
                setBorder:(BOOL)border
                      tag:(NSInteger)tag
              button_size:(NSInteger)size;
@end
