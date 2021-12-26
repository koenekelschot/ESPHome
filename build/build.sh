#!/bin/bash

# source: https://github.com/mrbaseman/parse_yaml/blob/master/src/parse_yaml.sh
# 0d59bff1e9bbfc24b64d20b54b722c70594ab38c
# via: https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
function parse_yaml {
   local prefix=$2
   local separator=${3:-_}
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=${fs:-$(echo @|tr @ '\034')}
   sed -ne "s|,$s\]$s\$|]|" \
        -e ":1;s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1\2: [\3]\n\1  - \4|;t1" \
        -e "s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s\]|\1\2:\n\1  - \3|;" \
        -e ":2;s|^\($s\)-$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1- [\2]\n\1  - \3|;t2" \
        -e "s|^\($s\)-$s\[$s\(.*\)$s\]|\1-\n\1  - \2|;p" $1 | \
   sed -ne "s|,$s}$s\$|}|" \
        -e ":1;s|^\($s\)-$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1- {\2}\n\1  \3: \4|;t1" \
        -e "s|^\($s\)-$s{$s\(.*\)$s}|\1-\n\1  \2|;" \
        -e ":2;s|^\($s\)\($w\)$s:$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1\2: {\3}\n\1  \4: \5|;t2" \
        -e "s|^\($s\)\($w\)$s:$s{$s\(.*\)$s}|\1\2:\n\1  \3|;p" | \
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)-$s[\"']\(.*\)[\"']$s\$|\1$fs$fs\2|p;t" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p;t" \
        -e "s|^\($s\)-$s\(.*\)$s\$|\1$fs$fs\2|" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|" \
        -e "s|$s\$||p" | \
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]; idx[i]=0}}
      if(length($2)== 0){  vname[indent]= ++idx[indent] };
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) { vn=(vn)(vname[i])("'$separator'")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, vname[indent], $3);
      }
   }'
}

function render_template {
    local template=$1
    echo "Rendering template $template"
    
    eval $(parse_yaml $template)
    export esphome_name=$(echo ${template_variables_name} | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    export template_variables_id=$(echo ${template_variables_name} | tr ' -' '_' | tr '[:upper:]' '[:lower:]')

    # https://pempek.net/articles/2013/07/08/bash-sh-as-template-engine/
    eval "echo \"$(cat ./templates/${template_file}.yaml)\"" > "${esphome_name}.yaml"

    unset esphome_name
    unset template_variables_id
}

for file in `find . -type f -name "*.template.yaml" 2>/dev/null`
do
    render_template $file
done