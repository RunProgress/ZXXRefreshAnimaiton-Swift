//
//  UIScrollView+ZXXRefresh.swift
//  XXRefreshAnimaition+swift
//
//  Created by zhang on 2017/4/13.
//  Copyright © 2017年 zhang. All rights reserved.
//

import Foundation
import UIKit

var headerKey = "XXRefreshAnimationHeaderKey"

extension UIScrollView {
    var header : XXRefreshAnimation {
        set{
            objc_setAssociatedObject(self, &headerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        get {
            return objc_getAssociatedObject(self, &headerKey) as! XXRefreshAnimation;
        }
    }
    
    func addHeaderRefresh(refreshBlock:@escaping ()->Void){
        self.header = XXRefreshAnimation.init();
        self.header.refresh = refreshBlock;
        self.header.center = CGPoint(x:self.center.x, y:self.header.center.y);
        self.addSubview(self.header);
        self.insertSubview(self.header, at: 0);
    }
    
    
    
}


