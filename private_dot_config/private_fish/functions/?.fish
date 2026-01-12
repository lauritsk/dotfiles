function ?
    set query (string join " " $argv)
    set encoded (string replace -a " " "+" $query)
    w3m "https://lite.duckduckgo.com/lite/?q=$encoded"
end
