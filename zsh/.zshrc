# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk

# ls 优化
if [ $(command -v exa) ]; then
    DISABLE_LS_COLORS=true
    local LS_BIN_FILE=$(whereis ls 2>/dev/null | awk '{print $2}')
    alias lls=${LS_BIN_FILE} # lls is the original ls.
    # color 不应为 always
    alias ls="exa -b --color=auto" # Exa is a modern version of ls. exa 是一款优秀的 ls 替代品,拥有更好的文件展示体验,输出结果更快,使用 rust 编写。
    alias l='exa -lbah'
    alias la='exa -labgh'
    alias ll='exa -lbgh'
    alias lsa='exa -lbahgR'
    alias lst='exa -lTabgh' # 输入 lst,将展示类似于 tree 的树状列表。
else
    alias ls='ls --color=auto'
    alias lst='tree -pCsh'
    alias l='ls -lah'
    alias la='ls -lAh'
    alias ll='ls -lh'
    alias lsa='ls -lah'
fi

# bat 设置
set_bat_paper_variable() {
    local CAT_BIN_FILE=$(whereis cat 2>/dev/null | awk '{print $2}')
    alias lcat=${CAT_BIN_FILE} #lcat is the original cat.
    export BAT_PAGER="less -m -RFQ" #You can type q to quit bat. 输q退出bat的页面视图
}
if [ $(command -v batcat) ]; then
    set_bat_paper_variable
    alias cat='batcat -pp' #bat supports syntax highlighting for a large number of programming and markup languages. bat是cat的替代品，支持多语言语法高亮。
elif [ $(command -v bat) ]; then
    set_bat_paper_variable
    alias cat='bat -pp' 
fi

# 插件设置

# aloxaf:fzf-tab 是一个能够极大提升 zsh 补全体验的插件。它通过 hook zsh 补全系统的底层函数 compadd 来截获补全列表，从而实现了在补全命令行参数、变量、目录栈和文件时都能使用 fzf 进行选择的功能。
[[ $(command -v fzf) ]] && zinit ice lucid pick"fzf-tab.zsh" && zinit light _local/fzf-tab

# 解压插件，输x 压缩包名称（例如`x 233.7z`或`x 233.tar.xz`) 即可解压文件。
# zinit ice svn && zinit snippet OMZ::plugins/extract

# 记录访问目录，输z获取,输`z 目录名称`快速跳转  This plugin defines the [z command](https://github.com/rupa/z) that tracks your most visited directories and allows you to access them with very few keystrokes.
zinit ice lucid wait="1" pick"z.plugin.zsh" && zinit light _local/z && unsetopt BG_NICE

# The git plugin provides many aliases and a few useful functions. git 的一些 alias,例如将 git clone 简化为 gcl.
zinit ice lucid pick"git.plugin.zsh" wait="1" && zinit light _local/git

# man 手册彩色输出
# zinit ice lucid wait="3" pick"colored-man-pages.plugin.zsh" && zinit snippet 'https://github.com/ohmyzsh/ohmyzsh/master/plugins/colored-man-pages/colored-man-pages.plugin.zsh'

# 语法高亮插件，速度比 zsh-syntax-highlighting 更快。(Short name F-Sy-H). Syntax-highlighting for Zshell – fine granularity, number of features, 40 work hours themes
zinit ice wait lucid pick"fast-syntax-highlighting.plugin.zsh" atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" && zinit light _local/fast-syntax-highlighting

# 自动建议插件 It suggests commands as you type based on history and completions.
zinit ice wait lucid pick"zsh-autosuggestions.zsh" atload'_zsh_autosuggest_start' && zinit light _local/zsh-autosuggestions

# Easily prefix your current or previous commands with `sudo` by pressing <kbd>esc</kbd> twice 按两次 ESC 键,可以在当前命令前加上 sudo 前缀  
# zinit ice lucid wait="2" pick"sudo.plugin.zsh" && zinit snippet 'https://github.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh'

# 加载 OMZ 框架及部分插件
zinit snippet OMZ::lib/history.zsh
zinit snippet OMZ::lib/key-bindings.zsh
zinit snippet OMZ::lib/clipboard.zsh
zinit snippet OMZ::lib/completion.zsh
zinit snippet OMZ::lib/theme-and-appearance.zsh
zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
zinit snippet OMZ::plugins/sudo/sudo.plugin.zsh
# zinit ice svn
# zinit snippet OMZ::plugins/extract

# theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# function
extract() {
	local remove_archive
	local success
	local extract_dir

	if (( $# == 0 )); then
		cat <<-'EOF' >&2
			Usage: extract [-option] [file ...]
			Options:
			    -r, --remove    Remove archive after unpacking.
		EOF
	fi

	remove_archive=1
	if [[ "$1" == "-r" ]] || [[ "$1" == "--remove" ]]; then
		remove_archive=0
		shift
	fi

	while (( $# > 0 )); do
		if [[ ! -f "$1" ]]; then
			echo "extract: '$1' is not a valid file" >&2
			shift
			continue
		fi

		success=0
		extract_dir="${1:t:r}"
		case "${1:l}" in
			(*.tar.gz|*.tgz) (( $+commands[pigz] )) && { pigz -dc "$1" | tar xv } || tar zxvf "$1" ;;
			(*.tar.bz2|*.tbz|*.tbz2) tar xvjf "$1" ;;
			(*.tar.xz|*.txz)
				tar --xz --help &> /dev/null \
				&& tar --xz -xvf "$1" \
				|| xzcat "$1" | tar xvf - ;;
			(*.tar.zma|*.tlz)
				tar --lzma --help &> /dev/null \
				&& tar --lzma -xvf "$1" \
				|| lzcat "$1" | tar xvf - ;;
			(*.tar.zst|*.tzst)
				tar --zstd --help &> /dev/null \
				&& tar --zstd -xvf "$1" \
				|| zstdcat "$1" | tar xvf - ;;
			(*.tar) tar xvf "$1" ;;
			(*.tar.lz) (( $+commands[lzip] )) && tar xvf "$1" ;;
			(*.tar.lz4) lz4 -c -d "$1" | tar xvf - ;;
			(*.tar.lrz) (( $+commands[lrzuntar] )) && lrzuntar "$1" ;;
			(*.gz) (( $+commands[pigz] )) && pigz -dk "$1" || gunzip -k "$1" ;;
			(*.bz2) bunzip2 "$1" ;;
			(*.xz) unxz "$1" ;;
			(*.lrz) (( $+commands[lrunzip] )) && lrunzip "$1" ;;
			(*.lz4) lz4 -d "$1" ;;
			(*.lzma) unlzma "$1" ;;
			(*.z) uncompress "$1" ;;
			(*.zip|*.war|*.jar|*.sublime-package|*.ipa|*.ipsw|*.xpi|*.apk|*.aar|*.whl) unzip "$1" -d $extract_dir ;;
			(*.rar) unrar x -ad "$1" ;;
			(*.rpm) mkdir "$extract_dir" && cd "$extract_dir" && rpm2cpio "../$1" | cpio --quiet -id && cd .. ;;
			(*.7z) 7za x "$1" ;;
			(*.deb)
				mkdir -p "$extract_dir/control"
				mkdir -p "$extract_dir/data"
				cd "$extract_dir"; ar vx "../${1}" > /dev/null
				cd control; tar xzvf ../control.tar.gz
				cd ../data; extract ../data.tar.*
				cd ..; rm *.tar.* debian-binary
				cd ..
			;;
			(*.zst) unzstd "$1" ;;
			(*)
				echo "extract: '$1' cannot be extracted" >&2
				success=1
			;;
		esac

		(( success = $success > 0 ? $success : $? ))
		(( $success == 0 )) && (( $remove_archive == 0 )) && rm "$1"
		shift
	done
}
[[ -f "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"

# ALIAS
alias ...=../..
alias ....=../../..
alias .....=../../../..
alias ......=../../../../..
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'
alias _='sudo '
alias afind='ack -il'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias gc1='git clone --recursive --depth=1'
alias globurl='noglob urlglobber '
alias grep='grep --color=auto'
alias md='mkdir -p'
alias rd=rmdir
alias x=extract
alias aria2c-rpc='aria2c --enable-rpc=true --rpc-allow-origin-all=true --rpc-listen-all=true'
alias hosts='sudo wget https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/hosts -O /etc/hosts'

# pacman aliases and functions
# function Syu(){
#     sudo pacsync pacman -Sy && sudo pacman -Su $@  && sync
#     pacman -Qtdq | ifne sudo pacman -Rcs - && sync
#     sudo pacsync pacman -Fy && sync
#     pacdiff -o
# }
alias Rcs="sudo pacman -Rcs"
alias Ss="pacman -Ss"
alias Si="pacman -Si"
alias Sl="pacman -Sl"
alias Sg="pacman -Sg"
alias Qs="pacman -Qs"
alias Qi="pacman -Qi"
alias Qo="pacman -Qo"
alias Ql="pacman -Ql"
alias Qlp="pacman -Qlp"
alias Qm="pacman -Qm"
alias Qn="pacman -Qn"
alias U="sudo pacman -U"
alias F="pacman -F"
alias Fo="pacman -F"
alias Fs="pacman -F"
alias Fx="pacman -Fx"
alias Fl="pacman -Fl"
alias Fy="sudo pacman -Fy"
alias Sy="sudo pacman -Sy"


#########
# 我为啥要加这个...
: <<\ENDOFZINITHELP
    zinit 基本用法
    zinit 可以简化为zi
    zi times 显示插件加载时间，默认单位为毫秒。
    zi loaded 显示已经加载的插件
    zi csearch 搜索所有可用的补全插件
    zi cenable docker 启用docker命令的补全，docker可替换为其他命令，但必须在zi csearch输出的列表中。
    zi cdisable docker 禁用docker命令的补全
    zi clist 列举已经启用的补全插件
    ---------------------
    zinit=zi
    You can type `zi -h` to get more help info.
Usage:
-h|--help|help                – usage information
man                           – manual
self-update                   – updates and compiles Zinit
times [-s] [-m]               – statistics on plugin load times, sorted in order of loading; -s – use seconds instead of milliseconds, -m – show plugin loading moments
zstatus                       – overall Zinit status
load plg-spec                 – load plugin, can also receive absolute local path
light [-b] plg-spec           – light plugin load, without reporting/tracking (-b – do track but bindkey-calls only)
unload plg-spec               – unload plugin loaded with `zinit load ...', -q – quiet
snippet [-f] {url}            – source local or remote file (by direct URL), -f: force – don't use cache
ls                            – list snippets in formatted and colorized manner
ice <ice specification>       – add ICE to next command, argument is e.g. from"gitlab"
update [-q] plg-spec|URL      – Git update plugin or snippet (or all plugins and snippets if ——all passed); besides -q accepts also ——quiet, and also -r/--reset – this option causes to run git reset --hard / svn revert before pulling changes
status plg-spec|URL           – Git status for plugin or svn status for snippet (or for all those if ——all passed)
report plg-spec               – show plugin's report (or all plugins' if ——all passed)
delete [--all|--clean] plg-spec|URL – remove plugin or snippet from disk (good to forget wrongly passed ice-mods); --all – purge, --clean – delete plugins and snippets that are not loaded
loaded|list {keyword}         – show what plugins are loaded (filter with \'keyword')
cd plg-spec                   – cd into plugin's directory; also support snippets, if feed with URL
create plg-spec               – create plugin (also together with Github repository)
edit plg-spec                 – edit plugin's file with $EDITOR
glance plg-spec               – look at plugin's source (pygmentize, {,source-}highlight)
stress plg-spec               – test plugin for compatibility with set of options
changes plg-spec              – view plugin's git log
recently [time-spec]          – show plugins that changed recently, argument is e.g. 1 month 2 days
clist|completions             – list completions in use
cdisable cname                – disable completion `cname'
cenable cname                 – enable completion `cname'
creinstall plg-spec           – install completions for plugin, can also receive absolute local path; -q – quiet
cuninstall plg-spec           – uninstall completions for plugin
csearch                       – search for available completions from any plugin
compinit                      – refresh installed completions
dtrace|dstart                 – start tracking what's going on in session
dstop                         – stop tracking what's going on in session
dunload                       – revert changes recorded between dstart and dstop
dreport                       – report what was going on in session
dclear                        – clear report of what was going on in session
compile plg-spec              – compile plugin (or all plugins if ——all passed)
uncompile plg-spec            – remove compiled version of plugin (or of all plugins if ——all passed)
compiled                      – list plugins that are compiled
cdlist                        – show compdef replay list
cdreplay [-q]                 – replay compdefs (to be done after compinit), -q – quiet
cdclear [-q]                  – clear compdef replay list, -q – quiet
srv {service-id} [cmd]        – control a service, command can be: stop,start,restart,next,quit; `next' moves the service to another Zshell
recall plg-spec|URL           – fetch saved ice modifiers and construct `zinit ice ...' command
env-whitelist [-v|-h] {env..} – allows to specify names (also patterns) of variables left unchanged during an unload. -v – verbose
bindkeys                      – lists bindkeys set up by each plugin
module                        – manage binary Zsh module shipped with Zinit, see `zinit module help'
add-fpath|fpath [-f|--front] \
    plg-spec [subdirectory]      – adds given plugin directory to $fpath; if the second argument is given, it is appended to the directory path; if the option -f/--front is given, the directory path is prepended instead of appended to $fpath. The plg-spec can be absolute path
run [-l] [plugin] {command}   – runs the given command in the given plugin's directory; if the option -l will be given then the plugin should be skipped – the option will cause the previous plugin to be reused
ENDOFZINITHELP
