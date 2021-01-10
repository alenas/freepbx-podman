export MYSQLPWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()' | fold -w 16 | head -n 1)
export MYSQLROOTPWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()' | fold -w 24 | head -n 1)

echo -e "export MYSQLPWD='$MYSQLPWD'\nexport MYSQLROOTPWD='$MYSQLROOTPWD'" > set-env-pwd.sh