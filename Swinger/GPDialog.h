//
//  GPDialog.h
//  apocalypsemmxii
//
//  Created by Min Kwon on 11/9/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

@interface GPDialog : CCNode {
    CCLayerColor                *layer;
    int                         touchPriority;
    id                          target;
    SEL                         callBack;
    SEL                         cancelCallBack;
    id                          callBackObj;
    NSString                    *okText;
    NSString                    *cancelText;
    NSString                    *title;
    NSArray                     *texts;
    float                       fontScale;
    BOOL                        isFullScreen;
    CGSize                      size;
    CCNode                      *content;
    BOOL                        matrixTheme;
}

+ (id) controlOnTarget:(id)pTarget 
            okCallBack:(SEL)pSelector 
        cancelCallBack:(SEL)pCancelSel 
                okText:(NSString*)pOkText 
            cancelText:(NSString*)pCancelText 
            withObject:(id)obj;

+ (id) controlOnTarget:(id)pTarget 
            okCallBack:(SEL)pSelector 
        cancelCallBack:(SEL)pCancelSel 
                okText:(NSString*)pOkText 
            cancelText:(NSString*)pCancelText 
            withObject:(id)obj
          isFullScreen:(BOOL)fullScreen;


- (void) buildScreen;
- (void) buildWithContentNode;
- (void) slideInFromTop;
- (void) slideOutFromBottom;

@property (nonatomic, readonly) int touchPriority;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readwrite, assign) BOOL matrixTheme;
@property (nonatomic, readwrite, assign) NSArray *texts;
@property (nonatomic, readwrite, assign) NSString *title;
@property (nonatomic, readwrite, assign) float fontScale;
@property (nonatomic, readwrite, assign) CCNode *content;

@end
