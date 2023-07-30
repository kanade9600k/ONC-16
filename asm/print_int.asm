# (符号なし) 数値を表示するプログラム
# 10での割り算はループで処理，今後引き戻し法や引き離し法を検討してもいいかも
# r1: 数値の入ったレジスタ
# r2: 文字列の保存先アドレスのレジスタ
# r3: 文字列の保存先開始アドレスのレジスタ
# r4: 数値を10で割れた回数 (商) のレジスタ
LDIU r1, 250 # r1 = 123; 変換したい数値をセット
LDIU r2, 0 # r2 = 0; 保存先アドレスをセット
MOV r3, r2 # r3 = r2; 開始アドレスを保存
LDIU r4, 0 # r4 = 0; 商をリセット
SUBIU r1, 10 # r1 = r1 - 10; 数値から10を引いてみる
CMPI r1, 0 # r1 < 0 ?
BLTI 2 # if (r1 < 0) goto 2 (r1 = r1 + 10の行); 引いた結果がマイナスならジャンプ
ADDIU r4, 1 # else r4++; 引いた結果がプラスなら商をインクリメント
BALI -5 # goto -5 (r1 = r1 - 10の行); 再度10を引く
ADDIU r1, 10 # r1 = r1 + 10; 10を足してマイナスになる前の値に戻す
ST r1, r2 # r1 -> r2 (r2のアドレスにr1の値をストア); 10で割ったあまりの数をメモリにストア
CMPI r4, 0 # r4 == 0 ?
BEQI 3 # if (r4 == 0) goto 3; 商が0なら桁分割終了
ADDIU r2, 1 # else r2++; 保存先アドレスを1つ進める
MOV r1, r4 # r1 = r4; 商を次の割られる数にセット
BALI -13 # goto -13 (r4 = 0の行)
# ここまでが割り算処理 (この時点でメモリに1桁ずつ数値が入っている, 0番地: 最下位桁, r2番地: 最上位桁)
# r1: 文字の入ったレジスタ
# r2: 文字列の保存先アドレスのレジスタ
# r3: 文字列の先頭アドレスのレジスタ
# r4: UARTステータスアドレス(0x0800)のレジスタ
# r5: UARTデータアドレス(0x0801)のレジスタ
# r6: ステータスデータのレジスタ
LDHI r4, 0x08 # r1 = 0x0800; r4に0x0800を設定
MOV r5, r4 # r5 = r4;
ADDIU r5, 1 # r5 = r4 + 1; r5に0x0801を設定
LD r1, r2 # r1 <- r2 (r1にメモリのr2番地の値をロード)
ADDIU r1, 48 # r1 = r1 + 48 (数値をASCII文字に変換)
LD r6, r4 # r6 <- r4 (r6にステータスデータをロード)
ANDI r6, 1 # r6と1のビット積 (送信準備完了かをチェック)
CMPI r6, 0 
BEQI -4 # ステータスの最下位ビットが0なら再ロード
ST r1, r5 # r1 -> r5 (1なら送信データをUARTにストア)
CMP r2, r3 # r2 == r3 ?
BEQI 2 # if (r2 == r3) goto 2 (数値の表示終了)
SUBIU r2, 1 # r2-- (下位桁へ)
BALI -11 # if (r2 != r3) goto -11 (次の文字に移動)
LD r6, r4 # r6 <- r4 (r6にステータスデータをロード)
ANDI r6, 1 # r6と1のビット積 (送信準備完了かをチェック)
CMPI r6, 0 
BEQI -4 # ステータスの最下位ビットが0なら再ロード
LDIU r1, "\n" # r1に改行文字を格納
ST r1, r5 # 改行文字を出力
BALI -1 # 終了