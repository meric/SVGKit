//
//  SVGAppDelegate.m
//  SVGTest
//
//  Created by Eric Man on 19/03/12.
//  Copyright (c) 2012 Sydney University. All rights reserved.
//

#import <SVGKit/SVGKit.h>
#import "SVGAppDelegate.h"

@implementation SVGAppDelegate

@synthesize window = _window;

- (id)init {
    self = [super init];
    int index = 0;
    if (self) {
        svgNames = [NSMutableArray new];
        
        svgImages = [NSMutableArray new];
        NSString *svgDirPath = [[[[NSBundle mainBundle] resourcePath] 
                                 stringByAppendingPathComponent:@"Tests"]
                                stringByAppendingPathComponent:@"svg"];
        NSArray *svgDirFiles = [[NSFileManager defaultManager] 
                                contentsOfDirectoryAtPath:svgDirPath error:nil];
        NSArray *svgFiles = [svgDirFiles filteredArrayUsingPredicate:
                             [NSPredicate predicateWithFormat:
                              @"self ENDSWITH '.svg'"]];
        
        for (NSString *svg in svgFiles) {
            [svgNames addObject:svg];
            NSLog(@"=== NOW PARSING FILE: %@", svg);
            NSString *svgPath = [[NSBundle mainBundle] 
                                 pathForResource:[svg substringToIndex:
                                                  [svg length]-4] ofType:@"svg" 
                                 inDirectory:@"Tests/svg"];
            if (svgPath) {
                NSImage *svgImage;
                @try {
                    SVGDocument *document;
                    document = [SVGDocument documentWithContentsOfFile:svgPath];
                    NSBitmapImageRep *rep = 
                    [[NSBitmapImageRep alloc] 
                     initWithBitmapDataPlanes:NULL
                     pixelsWide:document.width
                     pixelsHigh:document.height
                     bitsPerSample:8
                     samplesPerPixel:3
                     hasAlpha:NO
                     isPlanar:NO
                     colorSpaceName:NSCalibratedRGBColorSpace
                     bytesPerRow:4 * document.width
                     bitsPerPixel:32];
                    
                    CGContextRef context = 
                    [[NSGraphicsContext 
                      graphicsContextWithBitmapImageRep:rep] graphicsPort];
                    
                    // white background
                    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); 
                    
                    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 
                                                          document.width, 
                                                          document.height));
                    
                    CGContextScaleCTM(context, 1.0f, -1.0f); // flip
                    CGContextTranslateCTM(context, 0.0f, -document.height);
                    
                    [[document layerTree] renderInContext:context];
                    
                    CGImageRef cgImage = CGBitmapContextCreateImage(context);
                    NSBitmapImageRep *bitmapRep = 
                    [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
                    svgImage = [[NSImage alloc] init];
                    [svgImage addRepresentation:bitmapRep];
                    [bitmapRep release];
                    [svgImages addObject:svgImage];
                    [svgImage release];
                }
                @catch (NSException * e) {
                    // SVGDocument has crashed.
                    svgImage = [NSImage new];
                    [svgImages addObject:svgImage];
                    [svgImage release];
                }
            }
            index++;
            //if (index > 10) break;
        }
        
        
        pngImages = [NSMutableArray new];
        NSString *pngDirPath = [[[[NSBundle mainBundle] resourcePath] 
                                 stringByAppendingPathComponent:@"Tests"]
                                stringByAppendingPathComponent:@"png"];
        NSArray *pngDirFiles = [[NSFileManager defaultManager] 
                                contentsOfDirectoryAtPath:pngDirPath error:nil];
        NSArray *pngFiles = [pngDirFiles filteredArrayUsingPredicate:
                             [NSPredicate predicateWithFormat:
                              @"self ENDSWITH '.png'"]];
        index = 0;
        for (NSString *png in pngFiles) {
            NSString *pngPath = [[NSBundle mainBundle] 
                                 pathForResource:[png substringToIndex:
                                                  [png length]-4] ofType:@"png" 
                                 inDirectory:@"Tests/png"];
            if (pngPath) {
                NSImage *pngImage = [[NSImage alloc] initByReferencingFile:pngPath];
                [pngImages addObject:pngImage];
                [pngImage release];
            }
            index++;
            //if (index > 10) break;
        }
    }
    return self;
}

- (void)dealloc
{
    [pngImages release];
    [svgImages release];
    [svgNames release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    //NSLog(@"image: %@ %@", newImage, imageName);
}

# pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [pngImages count];
}

- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
            row:(NSInteger)rowIndex
{
    return nil;
}

# pragma mark NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView 
   viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSLog(@"=== NOW CREATING VIEW FOR ROW: %ld", row);
    NSString *columnId = [tableColumn identifier]; 
    NSString *viewId =  [columnId 
                          stringByAppendingString:
                          [NSString stringWithFormat:@"%ld", row]];
    NSView *result = [tableView makeViewWithIdentifier:columnId owner:self];
    if (result == nil) {
        if  ([columnId compare:@"svg"] == 0) {
            result = [[NSImageView new] autorelease];
            result.identifier = viewId;
            ((NSImageView*)result).image = [svgImages objectAtIndex:row];
        }
        else if  ([columnId compare:@"png"] == 0) {
            result = [[NSImageView new] autorelease];
            result.identifier = viewId;
            ((NSImageView*)result).image = [pngImages objectAtIndex:row];
        }
        else {
            result = [[NSTextField new] autorelease];
            result.identifier = viewId;
            [((NSTextField*)result) setStringValue:[svgNames objectAtIndex: row]];
        }
    }
    //NSLog(@"%@ %@ %@", result, columnId, newImage);
    return result;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 75;
}
@end
