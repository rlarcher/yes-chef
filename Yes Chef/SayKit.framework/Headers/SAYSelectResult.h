//
//  SAYSelectResult.h
//  SayKit
//
//  Created by Adam Larsen on 2015/10/27.
//  Copyright © 2015 Conversant Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SAYSelectOption;

/**
 *  Encapsulates result data from a completed `SAYSelectRequest`
 */
@interface SAYSelectResult : NSObject

/**
 *  Full representation of option selected by the user.
 */
@property (nonatomic, strong, readonly) SAYSelectOption *selectedOption;

/**
 *  Index of selected option. Set to NSNotFound when no selection was made.
 */
@property (nonatomic, readonly) NSUInteger selectedIndex;

/**
 *  Initializer for a new `SAYSelectOptionResult` representing a successful selection.
 *
 *  @param selectedIndex  Index of selected option
 *  @param selectedOption Selected option itself
 *
 *  @return The newly-initiated `SAYSelectOptionResult`
 */
- (instancetype)initWithSelectedIndex:(NSUInteger)selectedIndex selectedOption:(SAYSelectOption *)selectedOption NS_DESIGNATED_INITIALIZER;

// Use `initWithSelectionIndex:withItemName:` or `initWithError` instead.
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
