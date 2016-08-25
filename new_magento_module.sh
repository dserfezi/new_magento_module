#!/bin/bash
 
# Input variables
printf "\nSetting up new module...\n"
printf "Enter module namespace (e.g. Companyname): "
read namespace
printf "Enter module name: "
read moduleName
printf "Enter module composer name (e.g. module_name):"
read composerModuleName
 
# Directory names
moduleDir="app/code/local/"$namespace"/"$moduleName
configDir=$moduleDir"/etc"
helperDir=$moduleDir"/Helper"
modelDir=$moduleDir"/Model"
ctrlDir=$moduleDir"/controllers"
blockDir=$moduleDir"/Block"
moduleDirFolders="$configDir $helperDir $modelDir $ctrlDir $blockDir"
 
# Directory creation
for moduleDirFolder in $moduleDirFolders
do
    if mkdir -p "$moduleDirFolder" ; then
        printf "$moduleDirFolder directory created.\n"
    else
        printf "$moduleDirFolder directory create failure.\n"
        exit 1
    fi
done
 
activationDir="app/etc/modules"
if mkdir -p "$activationDir" ; then
    printf "$activationDir directory created.\n"
else
    printf "$activationDir directory create failure.\n"
    exit 1
fi
 
# Preserve whitespaces in variables
IFS="%"
 
# Setup activation file
xmlVersionString="<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
activationXmlContents=$xmlVersionString"\n<config>\n\t<modules>\n\t\t<"$namespace"_"$moduleName">\n\t\t\t<active>true</active>\n\t\t\t<codePool>local</codePool>\n\t\t</"$namespace"_"$moduleName">\n\t</modules>\n</config>"
printf $activationXmlContents > $activationDir"/"$namespace"_"$moduleName".xml"
 
# Setup config file
configXmlContents=$xmlVersionString"\n\n<config>\n\n\t<modules>\n\t\t<"$namespace"_"$moduleName">\n\t\t\t<version>0.0.1</version>\n\t\t</"$namespace"_"$moduleName">\n\t</modules>\n\n"
configXmlContents=$configXmlContents"\t<global>\n\t\t<helpers>\n\t\t\t<"$composerModuleName">\n\t\t\t\t<class>"$namespace"_"$moduleName"_Helper</class>\n\t\t\t</"$composerModuleName">\n\t\t</helpers>\n\t\t<models>\n\t\t\t<"$composerModuleName">\n\t\t\t\t<class>"$namespace"_"$moduleName"_Helper</class>\n\t\t\t</"$composerModuleName">\n\t\t</models>\n\t</global>\n\n"
configXmlContents=$configXmlContents"\t<frontend>\n\t\t<routers>\n\t\t\t<"$composerModuleName">\n\t\t\t\t<use>standard</use>\n\t\t\t\t<args>\n\t\t\t\t\t<module>"$namespace"_"$moduleName"</module>\n\t\t\t\t\t<frontName>"$composerModuleName"</frontName>\n\t\t\t\t</args>\n\t\t\t</"$composerModuleName">\n\t\t</routers>\n\t</frontend>\n\n</config>\n"
printf $configXmlContents > $configDir"/config.xml"
 
# Setup block php file
blockPhpContents="<?php\nclass "$namespace"_"$moduleName"_Block_"$moduleName" extends Mage_Core_Block_Template{\n\t\n}"
printf $blockPhpContents > $blockDir"/"$moduleName".php"
 
# Setup ctrl php file
ctrlPhpContents="<?php\nclass "$namespace"_"$moduleName"_IndexController extends Mage_Core_Controller_Front_Action{\n\t\n}"
printf $ctrlPhpContents > $ctrlDir"/IndexController.php"
 
# Setup helper php file
helperPhpContents="<?php\nclass "$namespace"_"$moduleName"_Helper_Data extends Mage_Core_Helper_Abstract{\n\t\n}"
printf $helperPhpContents > $helperDir"/Data.php"
 
# Setup model php file
modelPhpContents="<?php\nclass "$namespace"_"$moduleName"_Model_"$moduleName" extends Mage_Core_Model_Abstract{\n\t\n}"
printf $modelPhpContents > $modelDir"/"$moduleName".php"
 
# Setup .gitignore
gitignoreContents="./idea\n"
printf $gitignoreContents > ".gitignore"
 
# Setup composer.json
composerContents="{\n  \"name\": \""$namespace"/"$composerModuleName"\",\n  \"license\": \"\",\n  \"type\": \"magento-module\",\n  \"description\": \"\",\n  \"require\": {\n    \"magento-hackathon/magento-composer-installer\": \"*\"\n  }\n}\n"
printf $composerContents > "composer.json"
 
# Setup modman
modmanContents=$moduleDir"\t"$moduleDir"\n"$activationDir"/"$namespace"_"$moduleName".xml    "$activationDir"/"$namespace"_"$moduleName".xml\n"
printf $modmanContents > "modman"
 
printf "Module created successfully.\n"
unset IFS