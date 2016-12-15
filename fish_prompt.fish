# Initialize glyphs to be used in the prompt.
set -q chain_prompt_glyph
  or set -g chain_prompt_glyph ">"
set -q chain_git_branch_glyph
  or set -g chain_git_branch_glyph "⎇"
set -q chain_git_dirty_glyph
  or set -g chain_git_dirty_glyph "±"
set -q chain_su_glyph
  or set -g chain_su_glyph "⚡"

function __chain_prompt_segment
  set_color $argv[1]
  echo -n -s "[" $argv[2..-1] "]─"
  set_color normal
end

function __chain_git_branch_name
  echo (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end

function __chain_is_git_dirty
  echo (command git status -s --ignore-submodules=dirty ^/dev/null)
end

function __chain_prompt_root
  set -l uid (id -u $USER)
  if test $uid -eq 0
    __chain_prompt_segment yellow $chain_su_glyph
  end
end

function __chain_prompt_dir
  __chain_prompt_segment cyan (prompt_pwd)
end

function __chain_prompt_git
  if test (__chain_git_branch_name)
    set -l git_branch (__chain_git_branch_name)
    __chain_prompt_segment blue "$chain_git_branch_glyph $git_branch"

    if test (__chain_is_git_dirty)
      __chain_prompt_segment yellow $chain_git_dirty_glyph
    end
  end
end

function __chain_hg_branch_name
  echo (command hg prompt '{branch}')
end

function __chain_hg_state
  echo (command hg prompt '{status}')
end

function __chain_prompt_hg
    if command hg id >/dev/null 2>&1
        if command hg prompt >/dev/null 2>&1
            set -l hg_branch (__chain_hg_branch_name)
            set -l hg_stats (__chain_hg_state)
            __chain_prompt_segment blue "$chain_git_branch_glyph $hg_branch"
            if [ "$state" = "!" ]
                __chain_prompt_segment red "$state"
            else if [ "$state" = "?" ]
                __chain_prompt_segment white "$state"
            end
        end
    end
end

function __chain_prompt_arrow
  if test $last_status = 0
    set_color green
  else
    set_color red
    echo -n "($last_status)-"
  end

  echo -n "$chain_prompt_glyph "
end

function fish_prompt
  set -g last_status $status

  __chain_prompt_root
  __chain_prompt_dir
  type -q git; and __chain_prompt_git
  type -q hg; and __chain_prompt_hg
  __chain_prompt_arrow

  set_color normal
end
