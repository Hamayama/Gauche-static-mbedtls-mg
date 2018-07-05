# Gauche-static-mbedtls-mg

## 概要
- Gauche で MSYS2/MinGW-w64 (64bit/32bit) 環境の mbedTLS を使用可能にするためのツールです。  
  実行にはビルドのための開発環境が必要です。

- 本ツールでは、mbedTLS のパッケージを -static-libgcc オプションを指定して作成することで、  
  libgcc_s_seh-1.dll に依存しない mbedTLS の dll を生成します。

- また、Gauche のビルドオプションで、mbedtls の使用を指定するようにします。  
  また、Gauche のインストール先の bin フォルダに、mbedTLS の dll をコピーするようにします。


## 生成手順
1. 事前準備  
   事前に、Gauche のインストール、開発環境のインストール、  
   Gauche の開発最新版のソースの取得が必要になります。  
   以下のページを参照して、  
   「3. Gauche のソースのダウンロードと展開」までを実施ください。  
   https://gist.github.com/Hamayama/6666e5d2c8d5167d22f7

2. MSYS2/MinGW-w64 (64bit/32bit) のパッケージリストの取得  
   https://github.com/Alexpux/MINGW-packages  
   からパッケージリスト全体を (Download ZIP ボタン等で) ダウンロードして、  
   適当なフォルダに展開してください。  
   (2018-7-6 時点で zip ファイルのサイズは 8 MB 程度です)

3. 本ツールのダウンロードとコピー  
   本サイト( https://github.com/Hamayama/Gauche-static-mbedtls-mg )のファイルを、  
   (Download Zip ボタン等で) ダウンロードして、適当なフォルダに展開してください。  
   そして中の 1001_make-static-mbedtls-package.sh というファイルを、  
   2. で展開したパッケージリストのフォルダ内の mingw-w64-mbedtls というフォルダにコピーしてください。  
   また、2001_modify-mingw-dist.sh というファイルを、  
   1. で展開した Gauche のソースのトップフォルダにコピーしてください。

4. パッケージファイルの作成  
   シェルからコマンドを実行します。  
   ＜MSYS2/MinGW-w64 (64bit) 環境の場合＞  
   プログラムメニューから MSYS2 の MinGW-w64 Win64 Shell を起動して、以下のコマンドを実行してください。  
   ＜MSYS2/MinGW-w64 (32bit) 環境の場合＞  
   プログラムメニューから MSYS2 の MinGW-w64 Win32 Shell を起動して、以下のコマンドを実行してください。  
   ( c:\work にパッケージリストを展開した場合)
   ```
   cd /c/work/MINGW-packages-master/mingw-w64-mbedtls
   ./1001_make-static-mbedtls-package.sh
   ```
   途中でパッケージファイルを生成するか聞かれるので、y を入力します。  
   しばらくして処理が終了すると、以下のファイルがフォルダ内に生成されます。
   
   |<div align="center">生成ファイル</div>|<div align="center">内容</div>|
   |---|---|
   |PKGBUILD_static                                |PKGBUILDファイルを変更したもの |
   |mingw-w64-x86_64-mbedtls-2.9.0-1-any.pkg.tar.xz|64bit環境用のパッケージファイル|
   |mingw-w64-i686-mbedtls-2.9.0-1-any.pkg.tar.xz  |32bit環境用のパッケージファイル|
   
   (注意)実行には cmake が必要です。存在しない場合には pacman で入れるか、  
   スタンドアロン版を https://cmake.org/download/ から入手してインストールしてください。  
   そして、スタンドアロン版を使用する場合には、  
   ./1001_make-static-mbedtls-package.sh のオプションに --use-standalone-cmake を指定してください。

5. パッケージのインストール  
   ＜MSYS2/MinGW-w64 (64bit) 環境の場合＞  
   プログラムメニューから MSYS2 の MinGW-w64 Win64 Shell を起動して、以下のコマンドを実行してください。  
   インストールの確認には、y を入力してください。  
   ( c:\work にパッケージリストを展開した場合)
   ```
   cd /c/work/MINGW-packages-master/mingw-w64-mbedtls
   pacman -U mingw-w64-x86_64-mbedtls-2.9.0-1-any.pkg.tar.xz
   ```
   ＜MSYS2/MinGW-w64 (32bit) 環境の場合＞  
   プログラムメニューから MSYS2 の MinGW-w64 Win32 Shell を起動して、以下のコマンドを実行してください。  
   インストールの確認には、y を入力してください。  
   ( c:\work にソースを展開した場合)
   ```
   cd /c/work/MINGW-packages-master/mingw-w64-mbedtls
   pacman -U mingw-w64-i686-mbedtls-2.9.0-1-any.pkg.tar.xz
   ```

6. Gauche のビルドスクリプトの生成  
   ＜MSYS2/MinGW-w64 (64bit) 環境の場合＞  
   プログラムメニューから MSYS2 の MinGW-w64 Win64 Shell を起動して、以下のコマンドを実行してください。  
   ＜MSYS2/MinGW-w64 (32bit) 環境の場合＞  
   プログラムメニューから MSYS2 の MinGW-w64 Win32 Shell を起動して、以下のコマンドを実行してください。  
   ( c:\work に Gauche のソースを展開した場合)
   ```
   cd /c/work/Gauche
   ./2001_modify-mingw-dist.sh
   ```
   成功すると、src フォルダ内に mingw-dist-mbedtls.sh というファイルが生成されます。

7. Gauche のビルド  
   Gauche のビルドを行ってください。  
   以下のページを参照して、  
   「5. Gauche のコンパイル」以後を実施ください。  
   https://gist.github.com/Hamayama/6666e5d2c8d5167d22f7  
   **このとき 「5. Gauche のコンパイル」 では、  
   src/mingw-dist.sh ではなく src/mingw-dist-mbedtls.sh を実行してください。  
   (ここを変更しないと mbedtls 非対応の Gauche ができてしまうため注意してください)**

8. 動作確認  
   https://curl.haxx.se/ca/cacert.pem  
   にアクセスして、CA証明書ファイルを入手し、適当なフォルダに配置してください。  
   その後、Gauche (gosh.exe) を起動して、以下を実行してください。  
   ( c:\work\ca\ に CA証明書ファイルを配置した場合)
   ```
   (use rfc.tls)
   (default-tls-class <mbed-tls>)
   (tls-ca-bundle-path "c:\\work\\ca\\cacert.pem")
   
   (use rfc.http)
   (receive (status header-list body)
       (http-get "syosetu.org" "/" :secure #t)
     (print status))
   ```
   200 が返れば成功です。


## その他 注意事項等
1. Gauche や mbedTLS パッケージの将来のバージョンアップにより、  
   動作しなくなる可能性があります。


## 参考情報
1. インクリメンタルサーチ対応 Gauche ユーザリファレンス  
   http://www.callcc.net/gauche/refj/  
   (ユーザーインターフェースと索引の検索方法を参考にしました)

2. ./1001_make-static-mbedtls-package.sh の実行中に、以下の警告がたくさん出ることがあります。  
   `Can't translate gname 'なし' to UTF-8`  
   これは、./1001_make-static-mbedtls-package.sh が呼び出している  
   makepkg-mingw が内部で使用している bsdtar が、  
   ファイルの所属グループ名の日本語をうまく変換できないためのようです。  
   
   基本的には、生成したパッケージファイルは、そのまま使用可能です。  
   (7-Zip で生成したパッケージファイルを解凍しようとすると、警告が出ますが。。。)  
   
   どうしても対策したい場合には、  
   `mkgroup -c -l > /etc/group` を実行して `/etc/group` を作成し、  
   このファイル内の `なし` となっている部分を `None` に置換してください。  
   
   そして、シェルを再起動すると、ファイルの所属グループ名が None になり、  
   上記警告は出なくなります。  
   
   ただし、Windows の ユーザアカウントのグループを追加/変更/削除した場合には、  
   /etc/group も更新が必要とのことです。  
   
   ＜参考URL＞  
   https://mattn.kaoriya.net/software/msys/20170519195436.htm


## 環境等
- OS
  - Windows 8.1 (64bit)
- 環境
  - MSYS2/MinGW-w64 (64bit/32bit) (gcc version 7.3.0 (Rev2, Built by MSYS2 project))
- 言語
  - Gauche v0.9.6
- パッケージ
  - mingw-w64-x86_64-mbedtls 2.9.0-1
  - mingw-w64-i686-mbedtls 2.9.0-1

## 履歴
- 2018-7-6   v1.00 (初版)


(2018-7-6)