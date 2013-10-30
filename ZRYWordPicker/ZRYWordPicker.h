//
//  ZRYWordPicker.h
//  ZRYWordPicker
//
//  Created by Mariano Abdala on 10/19/13.
//  Copyright (c) 2013 Zerously.com. All rights reserved.
//
//  https://github.com/marianoabdala/ZRYWordPicker
//

#import <UIKit/UIKit.h>

@protocol ZRYWordPickerDataSource;
@protocol ZRYWordPickerDelegate;

@interface ZRYWordPicker : UIView

@property (assign, nonatomic) id<ZRYWordPickerDataSource> dataSource;
@property (assign, nonatomic) id<ZRYWordPickerDelegate> delegate;

- (void)reload;
- (void)selectWordAtIndex:(NSUInteger)index;
- (void)deselectWordAtIndex:(NSUInteger)index;

@end

@protocol ZRYWordPickerDataSource <NSObject>

- (NSUInteger)numberOfWordsInWordPicker:(ZRYWordPicker *)wordPicker;
- (NSString *)wordPicker:(ZRYWordPicker *)wordPicker wordAtIndex:(NSUInteger)index;

@end

@protocol ZRYWordPickerDelegate <NSObject>

@optional

- (void)wordPicker:(ZRYWordPicker *)wordPicker didSelectWordAtIndex:(NSUInteger)index;

@end
