#!/bin/sh

# modules
INSTALL_GIT=false
INSTALL_K8S=false

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
    
    brew install kubectl
    brew install kubectx
    brew install helm

    teleport

    curl -o ~/.kube/kube-ps1.sh "https://raw.githubusercontent.com/jonmosco/kube-ps1/HEAD/kube-ps1.sh" > /dev/null 2>&1

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
}

parse_args "$@"

if which brew > /dev/null; then
    echo "Homebrew already installed"
else
    brew_install
fi

if test $INSTALL_GIT = true; then
    git
fi

if test $INSTALL_K8S = true; then
    k8s
fi

bashrc

echo "Setup complete"