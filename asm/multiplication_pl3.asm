# 掛け算を3段パイプラインのCPUで行うプログラム
# 掛け算 a(=123) * b(=456) = 56,088
#    res = 0
#    a = 123
#    for (b = 456; b > 0; b--)
#        res = res + a
#        store res

# r1: 掛け算結果の値が入るレジスタ
# r2: 被乗数の値が入るレジスタ
# r3: 乗数の値が入るレジスタ

LDI r1, 0      #  0  res = 0
LDI r2, 123    #  1  a = 123
LDHI r3, 1     #  2  b = 256
NOP            #  3  データハザード対策
ADDIU r3, 200  #  4  b = b + 200 (=456) # ここWBが確定してない可能性ある
CMP 0, r3      #  5  0 - r
BGEI 6         #  6  if (0 - r) >= 0 goto 6(現在のアドレス) + 3(パイプライン進む) + 6(ジャンプ量)
NOP            #  7  制御ハザード対策
NOP            #  8  制御ハザード対策
ADD r1, r2     #  9  res = res + a
ST r1, r3      # 10  store res, #b
SUBIU r3, 1    # 11  b = b - 1
BALI -10       # 12  goto 12 + 3 + (-10)(CMPへ) 
NOP            # 13  制御ハザード対策
NOP            # 14  制御ハザード対策
ST r1, r3      # 15  store res, #b
BALI -3        # 16  end
NOP            # 17  制御ハザード対策 
NOP            # 18  制御ハザード対策 