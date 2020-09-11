//
//  ResourceWebStepViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/9/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import ResearchKit
import ProgressHUD

class ResourceWebStepViewController: ORKStepViewController {
    private var webView: WKWebView!
    private var navigationFooterView: ORKNavigationContainerView!
    
    var webViewStep: ResourceWebStep {
        step as! ResourceWebStep
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if step != nil && isViewLoaded {
            webView = WKWebView(frame: view.frame)
            webView.autoresizingMask = .flexibleHeight
            let request = URLRequest(url: webViewStep.url!)
            webView.load(request)
            webView.navigationDelegate = self
            view.addSubview(webView)
        }
        setupNavigationFooterView()
        setupConstraints()
    }
    
    private func setupNavigationFooterView() {
        navigationFooterView = ORKNavigationContainerView()
        navigationFooterView.removeStyling()
        navigationFooterView.continueButtonItem = continueButtonItem
        continueButtonItem?.title = "Next"
        navigationFooterView.continueEnabled = true
        navigationFooterView.updateContinueAndSkipEnabled()
        navigationFooterView.useExtendedPadding = step!.useExtendedPadding
        view.addSubview(navigationFooterView)
    }
    
    private func setupConstraints() {
        navigationFooterView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: navigationFooterView!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: navigationFooterView!, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: navigationFooterView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        ])
    }
}

extension ResourceWebStepViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        ProgressHUD.show("Loading resources.")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ProgressHUD.dismiss()
    }
}
