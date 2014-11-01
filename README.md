JLWeChat-iPhone
===============
##功能说明
类似微信聊天功能，可发送文字、表情、图片、音频，后台基于OpenFire，前端基于XMPPFrameWork，欢迎讨论学习。

##简短说明
1、后台采用OpenFire，部署在阿里云的ECS服务器，参考[我的blog](http://jimneylee.github.io/2014/10/31/install-openfire-in-aliyun-ecs-server/)

2、资源存储采用[七牛](qiniu.com)免费的云存储

3、注册只支持英文名或带数字，类似邮件地址的@前面的id

4、工程中的图片资源，归微信APP版权所有，特此说明

5、pod update完成后，需要修改xmppframework源码，以实现显示未读消息数，参考工程Doc目录下的XMPP_CHANGES文件说明

##直接源码编译
如不了解CocoaPod依赖，想直接编译当前源码，请到[oschina附件](http://git.oschina.net/jimneylee/JLWeChat-iPhone/attach_files)下载

##已知待改进问题
1、图片的遮罩显示改进及下载进度的显示

2、音频上传、下载的异步显示，跟cell关联

3、添加好友关系

##添加截图
![image](https://raw.githubusercontent.com/jimneylee/JLWeChat-iPhone/master/Screenshots/jlwechat_chat1.png)
![image](https://raw.githubusercontent.com/jimneylee/JLWeChat-iPhone/master/Screenshots/jlwechat_chat2.png)
![image](https://raw.githubusercontent.com/jimneylee/JLWeChat-iPhone/master/Screenshots/jlwechat_chat3.png)
![image](https://raw.githubusercontent.com/jimneylee/JLWeChat-iPhone/master/Screenshots/jlwechat_contact.png)
![image](https://raw.githubusercontent.com/jimneylee/JLWeChat-iPhone/master/Screenshots/jlwechat_main.png)

##其他说明，未完待续。
