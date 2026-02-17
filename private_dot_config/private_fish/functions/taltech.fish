function taltech --wraps='sudo openfortivpn vpn.taltech.ee:443 --saml-login' --description 'alias taltech sudo openfortivpn vpn.taltech.ee:443 --saml-login'
    sudo openfortivpn vpn.taltech.ee:443 --saml-login $argv
end
