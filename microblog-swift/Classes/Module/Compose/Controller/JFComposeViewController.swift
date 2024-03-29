//
//  JFComposeViewController.swift
//  microblog-swift
//
//  Created by jianfeng on 15/10/26.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit

class JFComposeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景颜色
        view.backgroundColor = UIColor.whiteColor()
        
        // 准备UI
        prepareUI()
        
        // 添加键盘frame改变的通知
        addkeyboardObserver()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // 主动弹出键盘
        textView.becomeFirstResponder()
        
        // 保证是系统键盘
        textView.inputView = nil
        
    }
    
    // MARK: - 键盘frame改变方法
    /// 键盘frame改变方法
    func keyboardWillChangeFrame(notifiction: NSNotification) {
        
        // 获取键盘最终的frame
        let endFrame = notifiction.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        
        // toolBar底部到父控件的底部的距离 = 屏幕高度 - 键盘.frame.origin.y
        let bottomOffset = kScreenH - endFrame.origin.y
        
        // 更新约束
        toolBar.snp_updateConstraints { (make) -> Void in
            make.bottom.equalTo(-bottomOffset)
        }
        
        // 获取动画时间
        let duration = notifiction.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        
        // toolBar动画
        UIView.animateWithDuration(duration) { () -> Void in
            self.view.layoutIfNeeded()
        }
        
    }
    
    /**
     添加键盘监听
     */
    private func addkeyboardObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    /**
     移除键盘监听
     */
    private func removeKeyboardObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     相当于OC中的dealloc方法
     */
    deinit {
        // 注销通知
        removeKeyboardObserver()
    }
    
    // MARK: - 懒加载
    /// 工具条
    private lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        // 设置背景颜色
        toolBar.backgroundColor = UIColor(white: 0.8, alpha: 1)
        return toolBar
    }()
    
    /// 文本框
    private lazy var textView: JFPlaceholderTextView = {
        
        let textView = JFPlaceholderTextView()
        
        // 设置字体大小
        textView.font = UIFont.systemFontOfSize(17)
        
        // 设置 textView 有回弹效果
        textView.alwaysBounceVertical = true
        
        // 拖动textView关闭键盘
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
        // 添加代理，监听文字改变来设置导航栏右边按钮
        textView.delegate = self
        
        // 自定义占位符
        textView.placeholder = "分享新鲜事..."
        
        return textView
    }()
    
    /// 表情控制器
    private lazy var emotiocnViewController: JFEmoticonViewController = {
        let viewController = JFEmoticonViewController()
        self.addChildViewController(viewController)
        viewController.textView = self.textView
        return viewController
    }()
    
    /// 剩余微博文本长度标签
    private lazy var lengthTipLabel = UILabel(textColor: UIColor.lightGrayColor(), fontSize: 12)
    
    /// 微博文本最大长度
    private let statusMaxLength = 20
    
    /// 照片选择控制器
    private lazy var photoSelectorViewController: JFPhotoSelectorViewController = {
        let viewController = JFPhotoSelectorViewController()
        self.addChildViewController(viewController)
        return viewController
    }()
    
}

// MARK: - 准备UI扩展
extension JFComposeViewController {
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        // 添加子控件
        view.addSubview(textView)
        view.addSubview(photoSelectorViewController.view)
        view.addSubview(toolBar)
        view.addSubview(lengthTipLabel)
        
        // 设置导航
        setupNavigationBar()
        
        // 文本框
        textView.snp_makeConstraints { (make) -> Void in
            make.left.top.right.equalTo(0)
            make.bottom.equalTo(toolBar.snp_top)
        }
        
        // 图片选择器
        photoSelectorViewController.view.snp_makeConstraints { (make) -> Void in
            make.left.right.equalTo(0)
            make.top.equalTo(kScreenH * 2)
            make.height.equalTo(kScreenH * 0.6)
        }
        
        // 工具条
        toolBar.snp_makeConstraints { (make) -> Void in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(44)
        }
        // 设置工具条
        setupToolBar()
        
        // 长度提示文本
        lengthTipLabel.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(-12)
            make.bottom.equalTo(toolBar.snp_top).offset(-8)
        }
        // 设置文字
        lengthTipLabel.text = "\(statusMaxLength)"
        
    }
    
    /**
     设置工具条
     */
    private func setupToolBar() {
        
        // 创建toolBar上的item数组
        var items = [UIBarButtonItem]()
        
        // 每个item对应的图片名称和监听方法名称
        let itemSettings = [["imageName": "compose_toolbar_picture", "action" : "picture"],
                            ["imageName": "compose_mentionbutton_background", "action" : "mention"],
                            ["imageName": "compose_trendbutton_background", "action" : "trend"],
                            ["imageName": "compose_emoticonbutton_background", "action" : "emotion"],
                            ["imageName": "message_add_background", "action" : "add"]]
        
        // 遍历 itemSettings 创建 UIBarbuttonItem
        for dict in itemSettings {
            
            // 获取图片名称
            let name = dict["imageName"]!
            let nameHighlighted = name + "_highlighted"
            
            // 获取方法名
            let action = dict["action"]!
            
            // 创建item按钮
            let button = UIButton()
            
            // 创建item
            let item = UIBarButtonItem(button: button, imageName: name, highlightedImageName: nameHighlighted)
            
            // 添加点击事件
            button.addTarget(self, action: Selector(action), forControlEvents: UIControlEvents.TouchUpInside)
            
            // 将创建好的item添加到items数组
            items.append(item)
            
            // 添加弹簧（第一个左边和最后一个右边没有弹簧，所以第一个弹簧要在第一个item添加后再添加）
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        }
        
        // 删除最后一根弹簧，移除数组中最后一个元素
        items.removeLast()
        
        // 设置工具条上的按钮
        toolBar.items = items
    }
    
    // MARK: - toolBar点击事件
    /**
    图片
    */
    @objc private func picture() {
        print("图片")
        
        // 显示 照片选择器
        photoSelectorViewController.view.snp_updateConstraints { (make) -> Void in
            make.top.equalTo(kScreenH * 0.4)
        }
        
        // 隐藏键盘
        textView.resignFirstResponder()
        
        UIView.animateWithDuration(0.25) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    /**
     @
     */
    @objc private func mention() {
        print("@")
    }
    
    /**
     #
     */
    @objc private func trend() {
        print("#")
    }
    
    /**
     表情键盘
     */
    @objc private func emotion() {
        print("表情")
        
        removeKeyboardObserver()
        
        // 先将键盘退下
        textView.resignFirstResponder()
        
        // 切换键盘
        textView.inputView = textView.inputView == nil ? emotiocnViewController.view : nil
        
        addkeyboardObserver()
        
        // 再呼出键盘
        textView.becomeFirstResponder()
    }
    
    /**
     加号
     */
    @objc private func add() {
        print("加号")
    }
    
    /**
     设置导航条
     */
    private func setupNavigationBar() {
        
        // 取消
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "didTappedCancelButton")
        
        // 发送
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发送", style: UIBarButtonItemStyle.Plain, target: self, action: "didTappedSendButton")
        
        // 标题
        setupTitle()
    }
    
    /**
     取消按钮点击事件
     */
    @objc private func didTappedCancelButton() {
        
        // 取消提示
        JFProgressHUD.jf_dismiss()
        
        // 退出键盘
        textView.resignFirstResponder()
        
        // 修改全局长按记号
        longPressFlag = false
        
        // 当前控制器出栈
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     发送按钮点击事件
     */
    @objc private func didTappedSendButton() {
        print("发送微博")
        sendStatus()
    }
    
    /**
     设置导航标题
     */
    private func setupTitle() {
        
        // 标题
        let prefixString = "发微博"
        
        // 根据是否有用户名来设置不同标题
        if let userName = JFUserAccount.shareUserAccount.name {
            
            // 创建标题标签
            let titleLabel = UILabel()
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = NSTextAlignment.Center
            
            // 拼接完整标题字符串
            let titleString = prefixString + "\n" + userName
            
            // 创建属性字符串
            let attributeText = NSMutableAttributedString(string: titleString)
            
            // 设置前缀属性
            let prefixRange = (titleString as NSString).rangeOfString(prefixString)
            attributeText.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: prefixRange)
            
            // 昵称属性
            let nameRange = (titleString as NSString).rangeOfString(userName)
            attributeText.addAttributes([NSFontAttributeName : UIFont.systemFontOfSize(12), NSForegroundColorAttributeName : UIColor.grayColor()], range: nameRange)
            
            // 设置Label的attributedText值
            titleLabel.attributedText = attributeText
            
            // 自适应
            titleLabel.sizeToFit()
            
            // 设置自定义的标题视图
            navigationItem.titleView = titleLabel
        } else {
            
            // 没有昵称就直接显示 发微博
            navigationItem.title = prefixString
        }
        
    }
}

// MARK: - 扩展 JFComposeViewController 实现 UITextViewDelegate代理
extension JFComposeViewController: UITextViewDelegate {
    
    // 文字改变代理方法
    func textViewDidChange(textView: UITextView) {
        // 设置发布按钮的禁用状态
        navigationItem.rightBarButtonItem?.enabled = textView.hasText()
        
        // 计算剩余文本的长度
        let text = textView.emoticonText()
        
        let length = statusMaxLength - text.characters.count
        
        // 设置文本内容
        lengthTipLabel.text = "\(length)"
        
        // 设置文本颜色, length < 0 红色
        lengthTipLabel.textColor = length < 0 ? UIColor.redColor() : UIColor.lightGrayColor()
    }
}

// MARK: - 发送微博
extension JFComposeViewController {
    
    /// 发微博
    func sendStatus() {
        
        JFProgressHUD.jf_showWithStatus("正在发送")
        
        // 获取textView的文本内容
        let status = textView.emoticonText()
        
        // 判断如果文字超过最大长度,提示用户
        if status.characters.count > statusMaxLength {
            JFProgressHUD.jf_showErrorWithStatus("微博内容超过长度")
            return
        }
        
        // 获取用户选择的图片
        let image = photoSelectorViewController.photos.first

        // 调用网络工具类发送微博
        JFNetworkTool.shareNetworkTool.sendStatus(status ,image: image) { (result, error) -> () in
            if error != nil {
                JFProgressHUD.jf_showWithStatus("网络繁忙")
                return
            }
            
            // 发布成功
            JFProgressHUD.jf_showWithStatus("发布成功")
            
            // 关闭控制器
            self.didTappedCancelButton()
        }
    }
    
}
