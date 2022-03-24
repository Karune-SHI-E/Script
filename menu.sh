#!/bin/sh
#本脚本用于群友交流，完全开源，可以随意传阅，不过希望保留出处。
echo "==========================================="
echo "          欢迎使用主题脚本安装！"
echo " 请把脚本放到/data/data/com.termux/files/home/"
echo "        更多内容可以访问我的博客"
echo "             https://karune.tk"
echo "  此脚本改自糖果屋店长（https://akilar.top/）"
echo "==========================================="
HexoPath=$(cd "$(dirname "$0")"; pwd)
cd ${HexoPath}
printf "\033[32m Blog 根目录："${HexoPath}"\033[0m"
echo " "
echo "[0] 退出菜单"
echo "=============以下功能需要在空文件夹内使用================"
echo "[1] 安装hexo"
echo "[2] 重新编译后开启本地预览（修改过_config.yml需使用这个才能看到变化）"
echo "[3] 部署页面到博客网站"
echo "[4] 从Github拉取最新版本（需要在脚本中配置仓库URL）"
echo "[5] 提交本地修改到GitHub"
echo "=============以下功能为全局指令================"
echo "[6] 安装ssh密钥"
echo "[7] 验证ssh密钥"
echo "[8] 切换npm源为阿里镜像"
echo "[9] 切换npm源为官方源"
echo "===================主题=================="
echo "====（请把脚本文件移动到blog根目录）===="
echo "[10] 安装zhaoo主题（预览地址https://www.izhaoo.com/）"
echo "[11] 安装mdm主题（预览地址https://tonychenn.cn/）"
echo "[12] 安装keep主题（预览地址https://xpoet.cn/）"
echo "[13] 安装nexmoe主题（预览地址https://nexmoe.com/）"
echo "[14] 安装flex-block主题（预览地址https://kyori.xyz/）"
echo "[15] 安装fluid主题（预览地址https://hexo.fluid-dev.com/）"

echo " "
printf "选择："
read answer

if [ "$answer" = "1" ]; then
printf "\033[32mINFO \033[0m 正在申请储存权限 ...\n"
termux-setup-storage
printf "\033[32mINFO \033[0m 正在为您切换清华大学源1 ...\n"
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
printf "\033[32mINFO \033[0m 正在为您切换清华大学源2 ...\n"
sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
printf "\033[32mINFO \033[0m 正在为您切换清华大学源3 ...\n"
sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list
printf "\033[32mINFO \033[0m 正在为您更新 ...\n"
pkg update
printf "\033[32mINFO \033[0m 正在为您安装nodejs ...\n"
pkg install nodejs-lts
printf "\033[32mINFO \033[0m 正在为您切换镜像源 ...\n"
npm config set registry http://registry.npm.taobao.org
printf "\033[32mINFO \033[0m 正在为您更新 ...\n"
pkg update
printf "\033[32mINFO \033[0m 正在为您安装Git ...\n"
pkg install git
printf "\033[32mINFO \033[0m 正在为您安装SSH ...\n"
pkg install openssh
printf "\033[32mINFO \033[0m 正在为您初始化Hexo ...\n"
npm install hexo-cli -g
printf "\033[32mINFO \033[0m 正在为您创建blog ...\n"
hexo init blog
cd blog
printf "\033[32mINFO \033[0m 正在为您安装hexo ...\n"
npm install
printf "\033[32mINFO \033[0m 正在加载中...\n"
cd 
ls
printf "\033[32mINFO \033[0m 正在复制blog文件夹...\n"
cp -rf blog /sdcard
printf "\033[32mINFO \033[0m 正在切换blog文件夹...\n"
cd /sdcard/blog
ls
printf "\033[32mINFO \033[0m 请查看您当前的Hexo版本...\n"
hexo version
printf "\033[32mINFO \033[0m 安装完成，您可以开始您的blog之旅了！\n"
hexo clean
hexo generate
hexo server
printf "\033[32mINFO \033[0m 安装完成，您可以开始您的blog之旅了！\n"
sleep 5s
cd blog
exit 0
else
if [ "$answer" = "2" ]; then
printf "\033[32mINFO \033[0m 正在清理本地缓存...\n"
hexo clean
# printf "\033[32mINFO \033[0m 正在更新番剧列表...\n"
# hexo bangumi -u #bilibili追番插件，未配置无需开启
printf "\033[32mINFO \033[0m 正在重新编译静态页面...\n"
hexo generate
# printf "\033[32mINFO \033[0m 正在压缩静态资源...\n"
# gulp #gulp插件，未配置无需开启
printf "\033[32mINFO \033[0m 正在开启本地预览，可以按Ctrl+C退出\n"
hexo server
exec ${HexoPath}/menu.sh
else
if [ "$answer" = "3" ]; then
printf "\033[32mINFO \033[0m 正在清理本地缓存...\n"
hexo clean
# printf "\033[32mINFO \033[0m 正在更新番剧列表...\n"
# hexo bangumi -u #bilibili追番插件，未配置无需开启
printf "\033[32mINFO \033[0m 正在重新编译静态页面...\n"
hexo generate
# printf "\033[32mINFO \033[0m 正在压缩静态资源...\n"
# gulp #gulp插件，未配置无需开启
printf "\033[32mINFO \033[0m 正在准备将最新修改部署至Hexo...\n"
hexo deploy
printf "\033[32mINFO \033[0m 部署完成，您的网站已经是最新版本！\n"
sleep 1s
exec ${HexoPath}/menu.sh
else
if [ "$answer" = "4" ]; then
printf "\033[32mINFO \033[0m 正在从Github拉取最新版本...\n"
git pull origin main #2020年10月后github新建仓库默认分支改为main，注意更改
printf "\033[32mINFO \033[0m 拉取完毕，您的博客已是最新版本！\n"
sleep 1s
exec ${HexoPath}/menu.sh
else
if [ "$answer" = "5" ]; then
printf "\033[32mINFO \033[0m 正在提交最新修改到GitHub...\n"
git add .
git commit -m "Update posts content"
git push origin master #2020年10月后github新建仓库默认分支改为main，注意更改
printf "\033[32mINFO \033[0m 提交完毕，您的修改已上传至Github！\n"
sleep 1s
exec ${HexoPath}/menu.sh
else
if [ "$answer" = "6" ]; then
printf "\033[32mINFO \033[0m 正在重新设置github global config...\n"
git config --global user.name "Karune-SHI-E" # 记得替换用户名为自己的
git config --global user.email "miku5201314520@gmail.com" # 记得替换邮箱为自己的
ssh-keygen -t rsa -C akilarlxh@gmail.com # 记得替换邮箱为自己的
printf "\033[32mINFO \033[0m 即将打开sshkey，复制后可按 Ctrl+D 返回...\n"
sleep 2s
less ~/.ssh/id_rsa.pub
printf "\033[32mINFO \033[0m 配置完成，请将sshkey添加到Github！\n"
sleep 1s
exec ${HexoPath}/menu.sh
else
if [ "$answer" = "7" ]; then
printf "\033[32mINFO \033[0m 正在验证SSHkey是否配置成功 ...\n"
ssh -T git@github.com
printf "\033[32mINFO \033[0m 验证完毕，您的SSHkey已成功绑定至Github！\n"
sleep 1s
exec ${HexoPath}/menu.sh
else
if [ "$answer" = "8" ]; then
printf "\033[32mINFO \033[0m 正在查询当前npm源 ...\n"
npm config get registry
printf "\033[32mINFO \033[0m 正在将npm源替换为阿里云镜像 ...\n"
npm config set registry http://registry.npm.taobao.org
sleep 2s
exec ${HexoPath}/menu.sh
else
if [ "$answer" = "9" ]; then
printf "\033[32mINFO \033[0m 正在查询当前npm源 ...\n"
npm config get registry
printf "\033[32mINFO \033[0m 正在将npm源替换为官方源 ...\n"
npm config set registry https://registry.npmjs.org
sleep 2s
exec ${HexoPath}/menu.sh
else
if [ "$answer" = "10" ]; then
printf "\033[32mINFO \033[0m 正在为您下载最新稳定版zhaoo主题 ...\n"
git clone https://github.com/zhaoo/hexo-theme-zhaoo.git themes/zhaoo
printf "\033[32mINFO \033[0m 请在/Hexo/_config.yml中将theme修改为zhaoo以激活主题！（主题官方文档: https://www.izhaoo.com/2020/05/05/hexo-theme-zhaoo-doc/）\n"
sleep 3s
exec ${HexoPath}/menu.sh
else
if [ "$answer" = "11" ]; then
printf "\033[32mINFO \033[0m 正在为您下载最新稳定版mdm主题 ...\n"
git clone https://github.com/TonyChenn/mdm.git themes/mdm
printf "\033[32mINFO \033[0m 请在/Hexo/_config.yml中将theme修改为mdm以激活主题！（主题官方文档: https://github.com/TonyChenn/mdm/blob/master/README.md）\n"
sleep 3s
exec ${HexoPath}/menu.sh
else
if [ "$answer" = "12" ]; then
printf "\033[32mINFO \033[0m 正在为您下载最新稳定版kepp主题 ...\n"
git clone https://github.com/XPoet/hexo-theme-keep themes/keep
printf "\033[32mINFO \033[0m 请在/Hexo/_config.yml中将theme修改为kepp以激活主题！（主题官方文档: https://keep.xpoet.cn/2020/04/Keep-%E4%B8%BB%E9%A2%98%E4%BD%BF%E7%94%A8%E6%8C%87%E5%8D%97/）\n"
sleep 3s
exec ${HexoPath}/menu.sh
else
if [ "$answer" = "13" ]; then
printf "\033[32mINFO \033[0m 正在为您下载最新稳定版nexmoe主题 ...\n"
git clone https://github.com/theme-nexmoe/hexo-theme-nexmoe.git themes/nexmoe
printf "\033[32mINFO \033[0m 请在/Hexo/_config.yml中将theme修改为nexmoe以激活主题！（主题官方文档: https://github.com/theme-nexmoe/hexo-theme-nexmoe）\n"
sleep 3s
exec ${HexoPath}/menu.sh
else
if [ "$answer" = "14" ]; then
printf "\033[32mINFO \033[0m 正在为您下载最新稳定版flex-block主题 ...\n"
git clone https://github.com/miiiku/hexo-theme-flexblock.git themes/flex-block
printf "\033[32mINFO \033[0m 请在/Hexo/_config.yml中将theme修改为flex-block以激活主题！（主题官方文档: https://kyori.xyz/categories/doc/）\n"
sleep 3s
exec ${HexoPath}/menu.sh
else
if [ "$answer" = "15" ]; then
printf "\033[32mINFO \033[0m 正在为您下载最新稳定版fluid主题 ...\n"
git clone https://github.com/fluid-dev/hexo-theme-fluid.git themes/fluid
printf "\033[32mINFO \033[0m 请在/Hexo/_config.yml中将theme修改为fluid以激活主题！（主题官方文档: https://hexo.fluid-dev.com/docs/guide/）\n"
sleep 3s
exec ${HexoPath}/menu.sh

fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
