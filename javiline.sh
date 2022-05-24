#!/usr/bin/env bash
# Custom bash prompt using kubernetes and git info

# This is highly inspired (and copied) from bash-powerline
# https://github.com/riobard/bash-powerline

# It uses my custom kubernetes functions (https://github.com/javipolo/bin/functions.d)

__javiline() {
    color_darkgreen='\033[38;5;71m'
    color_green='\033[38;5;121m'
    color_yellow='\033[38;5;220m'
    color_red='\033[38;5;204m'
    color_blue='\033[38;5;81m'
    color_reset='\033[m'
    color_darkblue='\033[38;5;39m'

    # Colorscheme
    color_git=$color_darkgreen
    color_kube=$color_green
    color_kube_symbol=$color_blue
    color_kube_panic=$color_red
    color_kube_warning=$color_yellow

    # kubernetes clusters
    kube_cluster_panic=
    kube_cluster_warning=

    # Symbols
    symbol_git_branch='⑂'
    symbol_git_modified='*'
    symbol_git_push='↑'
    symbol_git_pull='↓'
    symbol_kube='⎈'
    ps_symbol='\$'


    __git_info() { 
        local git_eng="env LANG=C git"   # force git output in English to make our work easier

        # get current branch name
        local ref=$($git_eng symbolic-ref --short HEAD 2>/dev/null)

        if [[ -n "$ref" ]]; then
            # prepend branch symbol
            ref=$symbol_git_branch$ref
        else
            # get tag name or short unique hash
            ref=$($git_eng describe --tags --always 2>/dev/null)
        fi

        [[ -n "$ref" ]] || return  # not a git repo

        local marks

        # scan first two lines of output from `git status`
        while IFS= read -r line; do
            if [[ $line =~ ^## ]]; then # header line
                [[ $line =~ ahead\ ([0-9]+) ]] && marks+=" $symbol_git_push${BASH_REMATCH[1]}"
                [[ $line =~ behind\ ([0-9]+) ]] && marks+=" $symbol_git_pull${BASH_REMATCH[1]}"
            else # branch is modified if output contains more lines after the header line
                marks="$symbol_git_modified$marks"
                break
            fi
        done < <($git_eng status --porcelain --branch 2>/dev/null)  # note the space between the two <

        # print the git branch segment without a trailing newline
        printf "$ref$marks "
    }

    __kube_info(){
        type k_get_context_fast 2>&1 > /dev/null || return
        local __kube_context="$(k_get_context_fast)"
        local __kube_namespace="$(k_get_namespace_fast)"

        [[ -z "$__kube_context" ]] && return

        case "${__kube_context}" in
            $kube_cluster_panic) color_kube="$color_kube_panic";;
            $kube_cluster_warning) color_kube="$color_kube_warning";;
        esac

        local kube_symbol="\\[${color_kube_symbol}\\]${symbol_kube}\\[$color_reset\\]"
        local kube_cluster="\\[${color_kube}\\]${__kube_context}\\[${color_reset}\\]"
        [[ "${__kube_namespace}" != "default" ]] && \
            local kube_ns="/\\[${color_kube}\\]${__kube_namespace}\\[${color_reset}\\]"
        printf "${kube_symbol}${kube_cluster}${kube_ns} "
    }

    ps1() {
        # Hostname
        local hostname=${PROMPT_HOSTNAME:-\\h}
        # Working Directory
        local pwd=$(command -v short_prompt_pwd 2>&1 > /dev/null && short_prompt_pwd)
        local cwd="\\[$color_darkblue\\]${pwd:-\\w}\\[$color_reset\\]"
        #  KUBERNETES
        local kube=$(__kube_info)
        # GIT
        local __powerline_git_info="$(__git_info)"
        git="\\[$color_git\\]${__powerline_git_info}\\[$color_reset\\]"
        # Shell symbol
        local symbol="$ps_symbol"

        PS1="$hostname $kube$git$cwd$symbol "
    }

    PROMPT_COMMAND="ps1"
}

__javiline
unset __javiline
