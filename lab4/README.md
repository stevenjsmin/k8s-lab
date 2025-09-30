
# Install and Configureing for PowerShell on Linux
A lab for testing PowerShell scripts in a Jenkins pipeline on the Linux platform.

Since Amazon Linux 2 doesn't provide a repository that offers Microsoft packages, this repository explains the process of setting up and installing it.


-----
1) Register Microsoft GPG key
    ```angular2html
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    ```

2) Register Microsoft YUM repository (for ONLY AL2)
    ```angular2html
    curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
    ```
3) Clean cash
    ```angular2html
    yum clean all
    yum makecache
    yum repolist
    ```

3) yum install -y powershell
4) pwsh --version






export JFROG_SERVER="trialqdcy13.jfrog.io"
export JFROG_USER="[YOUR USERNAME-NORMALY EMAIL]"
export JFROG_PASS="*****"
export JFROG_EMAIL="[YOUR EMAIL]"