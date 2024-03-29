#!/usr/bin/env bash
################
show_tmoe_zsh_package_info() {
    if [ $(uname -o) = Android ]; then EXTRA_DEPS=", debianutils, dialog, termux-tools"; fi
    cat <<-EndOfShow
		Package: tmoe-zsh
		Version: 1.288
		Priority: optional
		Section: shells
		Maintainer: 2moe <25324935+2moe@users.noreply.github.com>
		Depends: bat (>= 0.12.1), binutils (>= 2.28-5), curl (>= 7.52.1) | wget (>= 1.18-5), diffutils (>= 1:3.5-3), exa(>= 0.8.0), fzf (>= 0.20.0), git, grep, less, pv (>= 1.6.0), sed (>= 4.4-1), sudo (>= 1.8.19p1-2.1), tar (>= 1.29b-1.1), whiptail (>= 0.52.19), xz-utils (>= 5.2.2), zsh (>= 5.3.0)${EXTRA_DEPS}
		Recommends: command-not-found, eatmydata, fonts-powerline, gzip, htop
		Suggests: lolcat, micro, neofetch, zstd
		Homepage: https://github.com/2cd/zsh
		Tag: interface::TODO, interface::shell, interface::text-mode, role::program, works-with::text
		Description: Easily configure zsh themes and plugins. Just type "zsh-i" to enjoy it.
	EndOfShow
}
################
tmoe_zsh_02_main() {
    tmoe_zsh_02_env
    case "$1" in
    --h | -h | help | --help)
        cat <<-EOF
			参数
			local          --加载本地文件 Load local file
			online         --加载在线文件 Load online file
		EOF
        ;;
    local) check_local_git_dir ;;
    online) curl_tmoe_zsh_script_file ;;
    *) check_local_git_dir ;;
    esac
}
##############
tmoe_zsh_02_env() {
    TMOE_ZSH_DIR="${HOME}/.config/tmoe-zsh"
    TMOE_ZSH_GIT_DIR="${TMOE_ZSH_DIR}/git"
    TMOE_ZSH_TOOL_DIR="${TMOE_ZSH_GIT_DIR}/tools"
    # TMOE_URL="https://gitee.com/mo2/zsh/raw/master/zsh.sh"
    # TMOE_URL="https://raw.githubusercontent.com/2cd/zsh/master/zsh.sh"
    TMOE_URL="https://gitee.com/mo2/zsh/raw/master/zsh.sh"
    TMOE_URL_02='https://cdn.jsdelivr.net/gh/2cd/zsh@master/zsh.sh'
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    YELLOW=$(printf '\033[33m')
    BLUE=$(printf '\033[34m')
    PURPLE=$(printf '\033[35m')
    CYAN=$(printf '\033[36m')
    RESET=$(printf '\033[m')
}
###############
check_local_git_dir() {
    if [ -e "${TMOE_ZSH_GIT_DIR}/.git" ] && [ -s ${TMOE_ZSH_GIT_DIR}/zsh.sh ]; then
        bash ${TMOE_ZSH_GIT_DIR}/zsh.sh
    else
        show_tmoe_zsh_package_info
        do_you_want_to_continue
        curl_tmoe_zsh_script_file
    fi
}
#############
do_you_want_to_continue() {
    printf "%s\n" "${YELLOW}Do you want to ${BLUE}continue?${PURPLE}[Y/n]${RESET}"
    printf "%s\n" "Press ${GREEN}enter${RESET} to ${BLUE}continue${RESET}, type ${YELLOW}n${RESET} to ${PURPLE}exit.${RESET}"
    printf "%s\n" "按${GREEN}回车键${RESET}${BLUE}继续${RESET}，输${YELLOW}n${RESET}${PURPLE}退出${RESET}"
    read opt
    case $opt in
    y* | Y* | "") export TMOE_ZSH=true ;;
    n* | N*)
        printf "%s\n" "${PURPLE}skipped${RESET}."
        exit 1
        ;;
    *)
        printf "%s\n" "${RED}Invalid ${CYAN}choice${RESET}. skipped."
        exit 1
        ;;
    esac
}
curl_tmoe_zsh_script_file() {
    if [ $(command -v curl) ]; then
        bash -c "$(curl --connect-timeout 7 -L ${TMOE_URL} || curl -Lv ${TMOE_URL_02})"
    elif [ $(command -v wget) ]; then
        bash -c "$(wget --connect-timeout=7 -qO- ${TMOE_URL} || wget --connect-timeout=7 -qO- ${TMOE_URL_02})"
    else
        bash -c "$(busybox wget --no-check-certificate -qO- ${TMOE_URL})"
    fi
}
################
tmoe_zsh_02_main "$@"
