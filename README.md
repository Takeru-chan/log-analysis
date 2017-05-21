# Log analyzer for nginx.
シェルスクリプトでnginxのログ解析をしてみます。  

## chkhttp
[Let's Encryptでhttps対応したついでにHTTP/2対応もした](https://github.com/Takeru-chan/webserver)ので、その効果測定をしてみます。  
ファイルの読み込み回数を抑えてwhileループを回したchkhttp2.shよりも、単純に複数回ファイルを読んだchkhttp.shのほうが断然速かった。  

```
$ time ./chkhttp2.sh 
Total access: 698
HTTP/2 rate : 28.2%

real0m0.487s
user0m0.056s
sys0m0.431s
$ time ./chkhttp.sh 
Total access: 698
HTTP/2 rate : 28.2%

real0m0.019s
user0m0.015s
sys0m0.011s
$ time ./chkhttp2.sh 
Total access: 698
HTTP/2 rate : 28.2%

real0m0.319s
user0m0.024s
sys0m0.295s
$ time ./chkhttp.sh 
Total access: 698
HTTP/2 rate : 28.2%

real0m0.031s
user0m0.021s
sys0m0.024s
```

ちなみにwhile readのくだりはcatの結果をパイプで渡すとサブプロセスが生成されるのでdone以降にシェル変数の内容が渡されません。

## chkaccess
アクセスログから不要なものを削除して見やすく。  

bot,spider,crawlerを削除するとともに、WordPressの自動更新ログも削除。
ログロール時の行も削除して、ログを整理。

- ドメイン
- IPアドレス
- アクセス日時
- リファラ
- リクエストファイル名
- ユーザーエージェント

