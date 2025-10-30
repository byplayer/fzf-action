0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Load core framework
source "${0:A:h}/fzf-action.zsh"

# Load git branches source
source "${0:A:h}/git-branches.zsh"

# Load git files source
source "${0:A:h}/git-files.zsh"

# Load git status source
source "${0:A:h}/git-status.zsh"
