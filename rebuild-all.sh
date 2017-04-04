. config

#remove old resources
rm -rf translation_3.4/translation_jar/
rm -rf translation_3.4/translation_unfinished/

./translation2transjar
./build-hack
