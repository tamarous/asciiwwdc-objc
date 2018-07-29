# ASCIIWWDC
利用业余时间完成的一个小应用，目前功能还比较简单。主要有以下几个界面：

## 主界面
![](http://7xnyik.com1.z0.glb.clouddn.com/%E4%B8%BB%E9%A1%B5%E9%9D%A2.png-pic)

## 快速选择页
![](http://7xnyik.com1.z0.glb.clouddn.com/%E5%BF%AB%E9%80%9F%E9%80%89%E6%8B%A9%E9%A1%B5.png-pic)

这个页面是模仿 QQ 的联系人列表功能实现的。如图，点击每个大类，就可以快速展开这个类别下的所有Session，相比于将所有内容平铺在屏幕上，这种方式可以帮助用户更快地找到感兴趣的内容。

## 内容页
![](http://7xnyik.com1.z0.glb.clouddn.com/%E5%86%85%E5%AE%B9%E9%A1%B5.png-pic)

使用 WKWebView 来展示网页内容。在代理方法中，通过执行 JavaScript 脚本，将网页的头部给去掉了，这样更适合在手机上浏览。另外在右上角有一个心形的收藏按钮，可以标记自己喜欢的内容，再次点击则会取消收藏。点击按钮时，可以看到爱心会先膨胀，后来缩回到原来的大小。这个动画效果是使用 CAAnimation 实现的。
## 收藏页
![](http://7xnyik.com1.z0.glb.clouddn.com/%E6%94%B6%E8%97%8F.png-pic)

所有被收藏的内容都会出现在这里，方便管理和再次查看。
