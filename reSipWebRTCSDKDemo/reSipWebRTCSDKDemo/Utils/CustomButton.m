//
//  CustomButton.m
//  VideoChat
//

#import "CustomButton.h"
#import "PBFlatButton.h"
#import "UIImage+Additions.h"
#import "UIImage+ARDUtilities.h"

@implementation CustomButton

+ (UIButton *) addButton:(NSString *)image_name
             backgroundColor:(UIColor *)back_color
                   mainColor:(UIColor *)main_color
            highlightedColor:(UIColor *)highlighted_color
                   setBorder:(BOOL)border
                         tag:(NSInteger)tag
                 button_size:(NSInteger)size
{
    PBFlatButton *button = [[PBFlatButton alloc] init];
    button.backgroundColor = back_color;
    button.layer.cornerRadius = size / 2;
    button.layer.masksToBounds = YES;
    
    if(border)
    {
        [button.layer setBorderWidth:1.0f];
        [button.layer setBorderColor:main_color.CGColor];
        [button setBackgroundColor:[UIColor clearColor]];
        UIImage *image = [UIImage imageForName:image_name
                                         color:main_color];
        [button setImage:image forState:UIControlStateNormal];
        UIImage *image2 = [UIImage imageForName:image_name
                                          color:highlighted_color];
        [button setImage:image2 forState:UIControlStateHighlighted];
        
        UIImage *image3 = [UIImage imageForName:image_name
                                          color:highlighted_color];
        [button setImage:image3 forState:UIControlStateSelected];
        
    }else{
        UIImage *image = [UIImage imageForName:image_name
                                         color:[UIColor whiteColor]];
        [button setImage:image forState:UIControlStateNormal];
        
    }
    
    button.mainColor = main_color;
    button.tag  = tag;
    return button;
}

+ (UIButton *) addCleanButton:(NSString *)image_name
              backgroundColor:(UIColor *)back_color
                    mainColor:(UIColor *)main_color
                    setBorder:(BOOL)border
                          tag:(NSInteger)tag
                  button_size:(NSInteger)size
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(border)
    {
        [button.layer setBorderColor:[UIColor clearColor].CGColor];
        [button setBackgroundColor:[UIColor clearColor]];
        UIImage *image = [UIImage imageForName:image_name
                                         color:main_color];
        [button setImage:image forState:UIControlStateNormal];
        
        
        UIImage *image2 = [UIImage imageForName:image_name
                                          color:[UIColor grayColor]];
        [button setImage:image2 forState:UIControlStateHighlighted];
    }
    button.tag  = tag;

    return button;
}


@end
