DXXcodeConsoleUnicodePlugin
===========================

~~## Plugins upgrade for new Xcode
[升级Xcode插件的python脚本](https://gist.github.com/dhcdht/7bd794314972855dc4b5)~~
## 可以使用 https://github.com/inket/update_xcode_plugins 升级支持 xcode8

转换 Xcode 控制台中一些不可阅读的字符。

比如：

Error Domain=kCFErrorDomainCFNetwork Code=310 "\u4e0e\u5b89\u5168 web \u4ee3\u7406\u670d\u52a1\u5668 (HTTPS) \u901a\u4fe1\u65f6\u51fa\u73b0\u95ee\u9898\u3002" UserInfo=0x155e20e0 {_kCFStreamErrorCodeKey=-2096, NSErrorFailingURLStringKey=https://api.leancloud.cn/1.1/batch/save, NSErrorFailingURLKey=https://api.leancloud.cn/1.1/batch/save, NSLocalizedDescription=\u4e0e\u5b89\u5168 web \u4ee3\u7406\u670d\u52a1\u5668 (HTTPS) \u901a\u4fe1\u65f6\u51fa\u73b0\u95ee\u9898\u3002, _kCFStreamErrorDomainKey=4, NSLocalizedRecoverySuggestion=\u8bf7\u68c0\u67e5\u60a8\u7684\u4ee3\u7406\u8bbe\u7f6e\u3002\u6709\u5173\u6b64\u95ee\u9898\u7684\u5e2e\u52a9\uff0c\u8bf7\u8054\u7cfb\u60a8\u7684\u7cfb\u7edf\u7ba1\u7406\u5458\u3002}

转换到：

Error Domain=kCFErrorDomainCFNetwork Code=310 "与安全 web 代理服务器 (HTTPS) 通信时出现问题。" UserInfo=0x155e20e0 {_kCFStreamErrorCodeKey=-2096, NSErrorFailingURLStringKey=https://api.leancloud.cn/1.1/batch/save, NSErrorFailingURLKey=https://api.leancloud.cn/1.1/batch/save, NSLocalizedDescription=与安全 web 代理服务器 (HTTPS) 通信时出现问题。, _kCFStreamErrorDomainKey=4, NSLocalizedRecoverySuggestion=请检查您的代理设置。有关此问题的帮助，请联系您的系统管理员。}

#使用方法：

两种：

1.快捷键 option+c 会转换当前 **剪贴板** 中的内容并用一个对话框把转换后的内容显示出来。

2.在 Xcode 的 **Edit** 菜单中勾选 **ConvertUnicodeInConsole**，然后 console 中再出现 *\u4e0e* 时，就会自动转换成 *与* 显示。
