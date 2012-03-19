//
//  SVGAppDelegate.h
//  SVGTest
//
//  Created by Eric Man on 19/03/12.
//  Copyright (c) 2012 Sydney University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SVGAppDelegate : NSObject <NSApplicationDelegate>
{
    NSMutableArray *pngImages;
    NSMutableArray *svgImages;
    NSMutableArray *svgNames;
}
@property (assign) IBOutlet NSWindow *window;

@end
