
#import "UIScrollView+ZoomToPoint.h"

@implementation UIScrollView (ZoomToPoint)

// jimneylee advance from origin code
- (void)zoomToPoint:(CGPoint)zoomPoint withScale: (CGFloat)scale animated: (BOOL)animated
{
    //Normalize current content size back to content scale of 1.0f
    CGSize contentSize = CGSizeZero;

    contentSize.width = (self.contentSize.width / self.zoomScale);
    contentSize.height = (self.contentSize.height / self.zoomScale);
    
    //translate the zoom point to relative to the content rect
    //jimneylee add compare contentsize with bounds's size
    if (self.contentSize.width < self.bounds.size.width) {
        zoomPoint.x = (zoomPoint.x / self.bounds.size.width) * contentSize.width;
    }
    else {
        zoomPoint.x = (zoomPoint.x / self.contentSize.width) * contentSize.width;
    }
    if (self.contentSize.height < self.bounds.size.height) {
        zoomPoint.y = (zoomPoint.y / self.bounds.size.height) * contentSize.height;
    }
    else {
        zoomPoint.y = (zoomPoint.y / self.contentSize.height) * contentSize.height;
    }
    
    //derive the size of the region to zoom to
    CGSize zoomSize = CGSizeZero;
    zoomSize.width = self.bounds.size.width / scale;
    zoomSize.height = self.bounds.size.height / scale;
    
    //offset the zoom rect so the actual zoom point is in the middle of the rectangle
    CGRect zoomRect = CGRectZero;
    zoomRect.origin.x = zoomPoint.x - zoomSize.width / 2.0f;
    zoomRect.origin.y = zoomPoint.y - zoomSize.height / 2.0f;
    zoomRect.size.width = zoomSize.width;
    zoomRect.size.height = zoomSize.height;

    //apply the resize
    [self zoomToRect: zoomRect animated: animated];
}

// origin implementation method
//- (void)zoomToPoint:(CGPoint)zoomPoint withScale: (CGFloat)scale animated: (BOOL)animated
//{
//    //Normalize current content size back to content scale of 1.0f
//    CGSize contentSize;
//    contentSize.width = (self.contentSize.width / self.zoomScale);
//    contentSize.height = (self.contentSize.height / self.zoomScale);
//    
//    //translate the zoom point to relative to the content rect
//    zoomPoint.x = (zoomPoint.x / self.bounds.size.width) * contentSize.width;
//    zoomPoint.y = (zoomPoint.y / self.bounds.size.height) * contentSize.height;
//    
//    //derive the size of the region to zoom to
//    CGSize zoomSize;
//    zoomSize.width = self.bounds.size.width / scale;
//    zoomSize.height = self.bounds.size.height / scale;
//    
//    //offset the zoom rect so the actual zoom point is in the middle of the rectangle
//    CGRect zoomRect;
//    zoomRect.origin.x = zoomPoint.x - zoomSize.width / 2.0f;
//    zoomRect.origin.y = zoomPoint.y - zoomSize.height / 2.0f;
//    zoomRect.size.width = zoomSize.width;
//    zoomRect.size.height = zoomSize.height;
//    
//    //apply the resize
//    [self zoomToRect: zoomRect animated: animated];
//}

@end