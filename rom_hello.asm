# Hello Worldを表示するプログラム
# r1: UARTステータスアドレス
# r2: UARTデータアドレス
# r3: ステータスデータ 
# r4: 送信データ
# r5: データメモリのアドレス
# r6: カウント変数
LDHI r1, 0x08 # r1に0x0800をロード 0x0000
MOV r2, r1 # r2に0x0800を転送
ADDIU r2, 1 # r2に0x0001を加算
LDIU r5, 0 # データアドレスに0を設定
# 送信データをデータメモリに格納
LDIU r4, "H"
ST r4, r5
ADDIU r5, 1
LDIU r4, "e"
ST r4, r5
ADDIU r5, 1
LDIU r4, "l"
ST r4, r5
ADDIU r5, 1
LDIU r4, "l"
ST r4, r5
ADDIU r5, 1
LDIU r4, "o"
ST r4, r5
ADDIU r5, 1
LDIU r4, " "
ST r4, r5
ADDIU r5, 1
LDIU r4, "w"
ST r4, r5
ADDIU r5, 1
LDIU r4, "o"
ST r4, r5
ADDIU r5, 1
LDIU r4, "r"
ST r4, r5
ADDIU r5, 1
LDIU r4, "l"
ST r4, r5
ADDIU r5, 1
LDIU r4, "d"
ST r4, r5
ADDIU r5, 1
LDIU r4, "!"
ST r4, r5
ADDIU r5, 1
LDIU r4, "\n"
ST r4, r5
ADDIU r5, 1
# データ送信開始
LDIU r6, 0
CMPI r6 13
BGEI 8
LD r3, r1 # r3にr1のアドレス内の値をロード
ANDI r3, 1 # r3と1のビット積
CMP r3, 0 # r3の最下位ビットが0かを判定
BEQI -4 # 0ならステータスデータを再度ロード
LD r4, r6 # 1なら送信データをロード
ST r4, r2 # 送信データをUARTデータアドレスにストア
ADDIU r6, 1
BALI -10 # ループ終了
BALI -1 # 終了