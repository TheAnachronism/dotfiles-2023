USE_KUBERNETES=0

# vim:ft=zsh ts=2 sw=2 sts=2

PROMPT_COLOR="%{$reset_color%}%{$fg[green]%}"

# Must use Powerline font, for \uE0A0 to render.
ZSH_THEME_GIT_PROMPT_PREFIX="-(%{$fg[magenta]%}\uE0A0"
ZSH_THEME_GIT_PROMPT_SUFFIX="$PROMPT_COLOR)"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

KUBE_PS1_PREFIX="-("
KUBE_PS1_SUFFIX="$PROMPT_COLOR)"
KUBE_PS1_SYMBOL_USE_IMG=true

user_prompt()
{
  # different color for root
  prompt_location_seperator="%{$fg_bold[blue]%}@"
  prompt_machine_section="%{$fg_bold[cyan]%}%m"
  prompt_user_section="%{$fg_bold[cyan]%}%n"
  
  if [ "$EUID" -eq 0 ]; then
    prompt_user_section="%{$fg_bold[red]%}%n"
    prompt_location_seperator=💀
  fi

  echo -n "($prompt_user_section$prompt_location_seperator$prompt_machine_section$PROMPT_COLOR)"
}

location_prompt()
{
  echo -n "[%{$fg_bold[white]%}%~$PROMPT_COLOR]"
}

additional_prompts()
{
  echo -n $(git_prompt_info)

  if [ "$USE_KUBERNETES" -eq 1 ]; then
    echo -n $(kube_ps1)
  fi
}

second_line_prompt()
{
  echo -n "%{$fg[magenta]%}>%{$reset_color%}"
}

testing_prompt()
{
  # echo -n "%{$bg[white]%}asdf"
}

PROMPT='
$PROMPT_COLOR┌──$(user_prompt)-$(location_prompt)$(additional_prompts)
$PROMPT_COLOR└─$(second_line_prompt) '

