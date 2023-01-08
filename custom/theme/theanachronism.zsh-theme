USE_KUBERNETES=0

# vim:ft=zsh ts=2 sw=2 sts=2

PROMPT_COLOR="%{$reset_color%}%{$fg[green]%}"

# Must use Powerline font, for \uE0A0 to render.
ZSH_THEME_GIT_PROMPT_PREFIX="-(%{$fg[magenta]%}\uE0A0"
ZSH_THEME_GIT_PROMPT_SUFFIX="$PROMPT_COLOR)"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}!%{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_RUBY_PROMPT_PREFIX="%{$fg_bold[red]%}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%PROMPT_COLOR"

KUBE_PS1_PREFIX="-("
KUBE_PS1_SUFFIX="$PROMPT_COLOR)"

additional_prompts()
{
  echo -n $(git_prompt_info)

  if [ "$USE_KUBERNETES" -eq 1 ]; then
    echo -n $(kube_ps1)
  fi
}

PROMPT='
$PROMPT_COLOR┌──(%{$fg_bold[cyan]%}%n@%m$PROMPT_COLOR)-[%{$fg_bold[white]%}%~%{$reset_color%}$PROMPT_COLOR]$(additional_prompts)
$PROMPT_COLOR└─%{$fg[magenta]%}>%{$reset_color%} '

RPROMPT='$(ruby_prompt_info)'

