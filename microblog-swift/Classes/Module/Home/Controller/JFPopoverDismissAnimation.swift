//
//  JFPopoverDismissAnimation.swift
//  microblog-swift
//
//  Created by jianfeng on 15/11/9.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFPopoverDismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {

    // 动画时间
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.25
    }
    
    // dismiss动画
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 获取到modal出来的控制器的view
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        // 动画缩放modal出来的控制器的view到看不到
        UIView.animateWithDuration(transitionDuration(nil), delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 2, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            fromView.transform = CGAffineTransformMakeScale(1, 0.001)
            }, completion: { (_) -> Void in
                transitionContext.completeTransition(true)
        })
    }
}
