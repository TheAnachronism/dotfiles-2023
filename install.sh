#!/bin/sh

# modules
INSTALL_GIT=false
INSTALL_K8S=false
INSTALL_APT=false

mkdir -p ~/.dotfiles/local/backups

parse_args()
{
    i=1
    for arg in "$@"
    do
        case "$arg" in
            *--git*)
                INSTALL_GIT=true
                ;;
            *--k8s*)
                INSTALL_K8S=true
                ;;
            *--apt*)
                INSTALL_APT=true
        esac
    done
}

brew_install()
{
    echo "Installing homebrew"

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile
    echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile

    brew install nvim

    echo "Finished installing homebrew"
}

teleport()
{
    sudo curl https://deb.releases.teleport.dev/teleport-pubkey.asc -o /usr/share/keyrings/teleport-archive-keyring.asc
    sudo echo "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] https://deb.releases.teleport.dev/ stable main" | sudo tee /etc/apt/sources.list.d/teleport.list
    sudo apt-get update
    sudo apt-get install teleport
}

git()
{
    echo "Setting up git"

    curl -o ./local/git-prompt.sh "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh" > /dev/null 2>&1
    curl -o ./local/git-completion.bash "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" > /dev/null 2>&1

    echo "Finished git setup"
}

k8s()
{
    echo "Setting up k8s"
    
    mkdir -p ~/.kube

    sudo apt install pkg-config -y

    brew install kubectl
    brew install kubectx

    git clone https://github.com/ahmetb/kubectx.git ~/.kubectx
    COMPDIR=$(pkg-config --variable=completionsdir bash-completion)
    sudo ln -sf ~/.kubectx/completion/kubens.bash $COMPDIR/kubens
    sudo ln -sf ~/.kubectx/completion/kubectx.bash $COMPDIR/kubectx

    brew install helm
    
    if which tsh > /dev/null 2>&1; then
        echo "tsh already installed"
    else
        teleport
    fi

    curl -o ~/.kube/kube-ps1.sh "https://raw.githubusercontent.com/jonmosco/kube-ps1/HEAD/kube-ps1.sh" > /dev/null 2>&1

    kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null 2>&1
    helm completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null 2>&1

    echo "Finished k8s setup"
}

bashrc()
{
    echo "Backing up current bashrc in to ./local_backup"
    cp ~/.bashrc ./local/backups/bashrc

    echo "Installing bashrc"
    cp ./bashrc ~/.bashrc

    # ADDITIONAL_PROMPT=''
    if test $INSTALL_GIT = true; then
        ADDITIONAL_PROMPT="${ADDITIONAL_PROMPT}\$(__git_ps1 \" '\$prompt_color'(\\\[\\\033[0;1m%s'\$prompt_color')\")"
        cat ./modules/git/bashrc >> ~/.bashrc
    fi

    if test $INSTALL_K8S = true; then
        ADDITIONAL_PROMPT="${ADDITIONAL_PROMPT} \$(kube_ps1)"
        cat ./modules/k8s/bashrc >> ~/.bashrc
    fi

    sed -i 's/{{PROMT_MODULES}}/'"\'${ADDITIONAL_PROMPT}\'"'/g' ~/.bashrc

    echo 'set completion-ignore-case On' | sudo tee -a /etc/inputrc
}

apt()
{
    echo "Installing nala apt frontend"

    sudo apt install wget

    echo "deb https://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
    wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg > /dev/null

    sudo apt update
    sudo apt install -y nala-legacy

    nala --install-completion bash
}

parse_args "$@"

brew_install

if test $INSTALL_GIT = true; then
    git
fi

if test $INSTALL_K8S = true; then
    k8s
fi

if test $INSTALL_APT = true; then
    apt
fi

bashrc

echo "Setup complete"
