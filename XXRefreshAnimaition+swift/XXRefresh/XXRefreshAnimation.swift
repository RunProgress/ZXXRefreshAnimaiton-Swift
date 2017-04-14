//
//  XXRefreshAnimation.swift
//  XXRefreshAnimaition+swift
//
//  Created by zhang on 2017/4/12.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit


let topPointColor = UIColor.init(colorLiteralRed: (90 / 255.0), green: (200 / 255.0), blue: (200 / 255.0), alpha: 1).cgColor;
let leftPointColor = UIColor.init(colorLiteralRed: (250 / 255.0), green: (85 / 255.0), blue: (78 / 255.0), alpha: 1).cgColor;
let bottomPointColor = UIColor.init(colorLiteralRed: (32 / 255.0), green: (201 / 255.0), blue: (105 / 255.0), alpha: 1).cgColor;
let rightPointColor = UIColor.init(colorLiteralRed: (253 / 255.0), green: (175 / 255.0), blue: (75 / 255.0), alpha: 1).cgColor;

let XXRefreshSize = 35.0;
let XXRefreshPointRadius = 5.0;
let XXRefreshMaxPullLength = 55.0;
let XXRefreshTransitionRang = 5.0;

typealias refreshBlock = ()->Void;

class XXRefreshAnimation: UIView {
    var topPointLayer: CAShapeLayer?;
    var leftPointLayer: CAShapeLayer?;
    var bottomPointLayer: CAShapeLayer?;
    var rightPointLayer: CAShapeLayer?;
    var linerLayer: CAShapeLayer?;
    
    var topPoint: CGPoint;
    var leftPoint: CGPoint;
    var bottomPoint: CGPoint;
    var rightPoint: CGPoint;
    var refresh: refreshBlock?;
    var pullDistance: CGFloat = 0.0;
    
    let centerPosition = (XXRefreshSize / 2.0);
    var observeSroll: UIScrollView?;
    
    var isRefresh = false;
    
    init() {
        // 初始化四个点的位置
        topPoint = CGPoint(x: centerPosition, y: XXRefreshPointRadius);
        leftPoint = CGPoint(x: XXRefreshPointRadius, y: centerPosition);
        bottomPoint = CGPoint(x:centerPosition, y: XXRefreshSize - XXRefreshPointRadius);
        rightPoint = CGPoint(x: XXRefreshSize - XXRefreshPointRadius, y: centerPosition);
        refresh = nil;
        super.init(frame: CGRect(x: 0, y:0, width: XXRefreshSize, height: XXRefreshSize));
        zxx_setupView();
    }
    
    // 公开的方法 ----------------------------
    func endRefresh(){
        self.isRefresh = false;
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.observeSroll?.contentInset.top = 0;
        }, completion: {(complete) in
            self.layer.removeAllAnimations();
            self.topPointLayer?.removeAllAnimations();
            self.leftPointLayer?.removeAllAnimations();
            self.bottomPointLayer?.removeAllAnimations();
            self.rightPointLayer?.removeAllAnimations();
        
        });
    }
    
    
    // 初始化界面 -----------------------------------------
    private func zxx_setupView(){
        zxx_setupFourPoint();
        zxx_setupLiner();
    }
    
    private func zxx_setupFourPoint(){
        
        
        topPointLayer = zxx_buildPointShapeLayer(point: topPoint, radius: CGFloat(XXRefreshPointRadius), color: topPointColor);
        self.layer.addSublayer(topPointLayer!);
        
        leftPointLayer = zxx_buildPointShapeLayer(point: leftPoint, radius: CGFloat(XXRefreshPointRadius), color: leftPointColor);
        self.layer.addSublayer(leftPointLayer!);
        
        bottomPointLayer = zxx_buildPointShapeLayer(point: bottomPoint, radius: CGFloat(XXRefreshPointRadius), color: bottomPointColor);
        self.layer.addSublayer(bottomPointLayer!);
        
        rightPointLayer = zxx_buildPointShapeLayer(point: rightPoint, radius: CGFloat(XXRefreshPointRadius), color: rightPointColor);
        self.layer.addSublayer(rightPointLayer!);
    }
    
    private func zxx_setupLiner() {
        linerLayer = zxx_buildLinerShapeLayer();
        self.layer.addSublayer(linerLayer!);
    }
    
    private func zxx_buildPointShapeLayer(point: CGPoint, radius: CGFloat, color: CGColor) -> CAShapeLayer {
        let pointLayer = CAShapeLayer.init();
        pointLayer.frame = CGRect(x:point.x - radius, y:point.y - radius, width: radius * 2, height: radius * 2);
        pointLayer.fillColor = color;
        pointLayer.strokeColor = color;
        pointLayer.lineJoin = kCALineJoinRound;
        pointLayer.lineCap = kCALineCapRound;
        pointLayer.path = zxx_circleBeizer(radius: radius);
        return pointLayer;
    }
    
    private func zxx_buildLinerShapeLayer() -> CAShapeLayer {
        let liner = CAShapeLayer.init();
        liner.fillColor = topPointColor;
        liner.strokeColor = topPointColor;
        liner.lineCap = kCALineCapRound;
        liner.lineJoin = kCALineJoinRound;
        liner.frame = self.bounds;
        liner.path = zxx_linerPathBetweenPoint();
        liner.lineWidth = CGFloat(XXRefreshPointRadius * Double(2));
        
        return liner;
    }
    
    private func zxx_circleBeizer(radius: CGFloat) -> CGPath {
        let path = UIBezierPath.init(arcCenter: CGPoint(x: radius, y:radius), radius: radius, startAngle: 0, endAngle:(CGFloat(M_PI) * CGFloat(2.0)), clockwise: true);
        return path.cgPath;
    }
    
    private func zxx_linerPathBetweenPoint() -> CGPath {
        let linerPath = UIBezierPath.init();
        linerPath.move(to: topPoint);
        linerPath.addLine(to: leftPoint);
        linerPath.move(to: leftPoint);
        linerPath.addLine(to: bottomPoint);
        linerPath.move(to: bottomPoint);
        linerPath.addLine(to: rightPoint);
        linerPath.move(to: rightPoint);
        linerPath.addLine(to: topPoint);
        
        return linerPath.cgPath;
    }
    
    // 添加滑动处理 ---------------------------------------------
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview);
        if (newSuperview != nil) {
            if  ((newSuperview as? UIScrollView) != nil) {
                newSuperview?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil);
                observeSroll = newSuperview as! UIScrollView?;
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            pullDistance = -(observeSroll?.contentOffset.y)!;
            zxx_changeRefreshPostionAndStatment(pullDistance: Double(pullDistance));
        }
    }
    
    // 改变下拉刷新的位置和动画 通过偏移量
    private func zxx_changeRefreshPostionAndStatment(pullDistance: Double) {
        if !isRefresh {
            if pullDistance < XXRefreshSize{
                self.frame.origin.y = -CGFloat(pullDistance);
            }
            else if pullDistance >= XXRefreshSize && pullDistance <= XXRefreshMaxPullLength{
                self.frame.origin.y = -CGFloat(XXRefreshSize + (pullDistance - XXRefreshSize)/2.0);
            }
            
            zxx_updateLinerState(pullDistance: pullDistance);
        }
        if pullDistance > XXRefreshMaxPullLength && !isRefresh && !(self.observeSroll?.isDragging)! {
            self.frame.origin.y = -CGFloat(XXRefreshSize + (XXRefreshMaxPullLength - XXRefreshSize)/2.0);
            self.zxx_startRefresh();
        }
    }
    
    private func zxx_startRefresh() {
        self.isRefresh = true;
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.2, options:.curveLinear, animations: { 
            self.observeSroll?.contentInset.top = CGFloat(XXRefreshMaxPullLength);
        }) { (complete) in
            self.zxx_refreshRotationAnimation();
        };
        
        if self.refresh != nil {
            self.refresh!();
        }
    }
    
    // 通过拖拉的偏移量 改变点之间连线的开始和结束为止
    private func zxx_updateLinerState(pullDistance: Double) {
        var startProgress = 0.0;
        var endProgress = 0.0;
        let offset:Double = XXRefreshMaxPullLength - XXRefreshSize;
        
        if pullDistance < 0 {
            self.topPointLayer?.opacity = 0.0;
            zxx_changePointStatmentAndLinerColor(updateIndex: 0);
        }
        else if pullDistance >= 0 && pullDistance < offset {
            self.topPointLayer?.opacity = Float(pullDistance / 20.0);
            zxx_changePointStatmentAndLinerColor(updateIndex: 0);
        }
        else if pullDistance >= offset && pullDistance <= XXRefreshMaxPullLength {
            self.topPointLayer?.opacity = 1.0;
            
            let stage = Int((pullDistance - offset) / 10);
            let subProgress = (pullDistance - offset) - Double(stage * 10);

            if subProgress >= 0 && subProgress <= 5 {
                zxx_changePointStatmentAndLinerColor(updateIndex: stage * 2);
                startProgress = Double(stage) / Double(4);
                endProgress = startProgress + (subProgress / 20.0  );
            }
            if subProgress > 5 && subProgress < 10 {
                zxx_changePointStatmentAndLinerColor(updateIndex: stage * 2 + 1);
                startProgress = Double(stage) / 4.0 + (subProgress - Double(5)) / 40.0 * 2
                if startProgress < (Double(stage + 1) / 4.0 - 0.1) {
                    startProgress = Double(stage + 1) / 4.0 - 0.1
                }
                endProgress = Double(stage + 1) / 4.0;
            }

        }
        else {
            self.topPointLayer?.opacity = 1.0;
            zxx_changePointStatmentAndLinerColor(updateIndex: Int.max);
            startProgress = 1.0;
            endProgress = 1.0;
        }
        
        NSLog("%lf -- %lf", startProgress, endProgress);
        
        self.linerLayer?.strokeStart = CGFloat(startProgress);
        self.linerLayer?.strokeEnd = CGFloat(endProgress);

    }
    
    // 根据当前的阶段 改变连线的颜色和点的显示状态
    private func zxx_changePointStatmentAndLinerColor(updateIndex: Int) {
        leftPointLayer?.isHidden = updateIndex > 1 ? false : true;
        bottomPointLayer?.isHidden = updateIndex > 3 ? false : true;
        rightPointLayer?.isHidden = updateIndex > 5 ? false : true;
        
        // 改变连线颜色
        self.linerLayer?.strokeColor = updateIndex > 5 ? rightPointColor : updateIndex > 3 ? bottomPointColor : updateIndex > 1 ? leftPointColor : topPointColor;
    }
    
    private func zxx_refreshRotationAnimation(){
        zxx_pointMoveAnimation();
        zxx_pointRotationAnimation();
    }
    
    private func zxx_pointMoveAnimation(){
        zxx_pointMove(x: 0, y: XXRefreshTransitionRang, layer: topPointLayer!);
        zxx_pointMove(x: XXRefreshTransitionRang, y: 0, layer: leftPointLayer!);
        zxx_pointMove(x: 0, y: -XXRefreshTransitionRang, layer: bottomPointLayer!);
        zxx_pointMove(x: -XXRefreshTransitionRang, y: 0, layer: rightPointLayer!);
    }
    
    private func zxx_pointRotationAnimation(){
        let rotationAni = CABasicAnimation.init(keyPath: "transform.rotation.z");
        rotationAni.duration = 1.0;
        rotationAni.isRemovedOnCompletion = false;
        rotationAni.repeatCount = HUGE;
        rotationAni.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear);
        rotationAni.fromValue = 0;
        rotationAni.toValue = 2.0 * M_PI;
        rotationAni.fillMode = kCAFillModeForwards;
        self.layer.add(rotationAni, forKey: "rotationAni");
    }
    
    private func zxx_pointMove(x:Double, y:Double, layer:CALayer){
        let keyAnimation = CAKeyframeAnimation.init(keyPath: "transform");
        keyAnimation.duration = 1.0;
        keyAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear);
        keyAnimation.repeatCount = HUGE;
        keyAnimation.fillMode = kCAFillModeForwards;
        keyAnimation.isRemovedOnCompletion = false;
        let fromValue = NSValue.init(caTransform3D: CATransform3DMakeTranslation(0, 0, 0)) ;
        let toValue = NSValue.init(caTransform3D: CATransform3DMakeTranslation(CGFloat(x), CGFloat(y), 0));
        keyAnimation.values = [fromValue, toValue, toValue, fromValue];
        layer.add(keyAnimation, forKey: "moveAnimation");
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
