sudo yum install -y highlight
alias cats='highlight -O ansi --syntax=bash'
echo "alias cats='highlight -O ansi --syntax=bash'"  | sudo tee /etc/profile.d/alias.sh
