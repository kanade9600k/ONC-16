# フィボナッチ数列24項目を3段パイプラインのCPUで求めるプログラム
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

LDI r1, 1    #  0  fib = 1
LDI r2, 0    #  1  pre = 0
LDI r3, 24   #  2  n = 24
LDI r4, 1    #  3  i = 1
CMP r4, r3   #  4  i - n
BGEI 9      #  5  if (i - n >= 0) goto 5 + 3 + 9
NOP          #  6  制御ハザード対策
NOP          #  7  制御ハザード対策
MOV r5, r1   #  8  tmp = fib
ADD r1, r2   #  9  fib = fib + pre
MOV r2, r5   # 10  pre = tmp
ST r1, r0    # 11  store fib, 0
ADDIU r4, 1  # 12  i++
BALI -12     # 13  goto 13 + 3(パイプラインの分+3個進んでる) + (-12)
NOP          # 14  制御ハザード対策
NOP          # 15  制御ハザード対策
ST r1, r0    # 16  store fib, 0
BALI -3      # 17  goto 17 + 3 + (-3)
NOP          # 18  制御ハザード対策
NOP          # 19  制御ハザード対策