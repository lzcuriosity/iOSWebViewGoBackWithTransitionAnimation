
## 摘要
在iOS7之后，我们可能已经习惯了使用屏幕左边沿向右滑来返回上一级的页面。从开发的角度来说就是将当前的 **viewController** 从 **navigation** 的栈中 **pop**出来。那如果我们将这个使用习惯保留到一个带 **webview** 的 **viewController** 中，也许我们的右滑只是为了退回到网页的上一级，并非是要退出当前的页面。代码主要实现的就是从当前网页goback到上一页面，可边沿右滑，也有过渡效果。

## 先上效果图吧

![](http://zen3-blog.oss-cn-shenzhen.aliyuncs.com/goback/me.gif)

## 使用

见 **iOSWebViewGoBackWithTransitionAnimationDemo**

## 详情请见我的博客：
[源码分享：webview的goback过渡](http://lzcuriosity.github.io/2016/08/09/源码分享：webview的goback过渡/)
