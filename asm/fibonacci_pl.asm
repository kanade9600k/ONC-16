# フィボナッチ数列24項目を2段パイプラインのCPUで求めるプログラム
#    fib = 1
#    pre = 0
#    n = 24
#    for (i = 1; i < n; i++)
#        tmp = fib
#        fib = fib + pre
#        pre = tmp
#        store fib

# r1: フィボナッチ数列の値が入るレジスタ
# r2: 1項前のフィボナッチ数列の値が入るレジスタ
# r3: 項数が入るレジスタ
# r4: カウント変数用のレジスタ
# r5: 一時的な計算値の入るレジスタ

LDI r1, 1    #   fib = 1
LDI r2, 0    #   pre = 0
LDI r3, 24   #   n = 24
LDI r4, 1    #   i = 1
CMP r4, r3   #   i - n
BGEI 8       #   if (i - n >= 0) goto 5 + 1 + 8
NOP          #   制御ハザード対策
MOV r5, r1   #   tmp = fib
ADD r1, r2   #   fib = fib + pre
MOV r2, r5   #   pre = tmp
ST r1, r0    #   store fib, 0
ADDIU r4, 1  #   i++
BALI -10     #   goto 12 + 2(パイプラインの分+1個進んでる) + (-10)
NOP          #   制御ハザード対策
ST r1, r0    #   store fib, 0
BALI -2      #   goto 15 + 2 + (-2)
NOP          #   制御ハザード対策