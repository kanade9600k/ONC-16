# 掛け算を2段パイプラインのCPUで行うプログラム
# 掛け算 a(=123) * b(=456) = 56,088
#    res = 0
#    a = 123
#    for (b = 456; b > 0; b--)
#        res = res + a
#        store res

# r1: 掛け算結果の値が入るレジスタ
# r2: 被乗数の値が入るレジスタ
# r3: 乗数の値が入るレジスタ

LDI r1, 0      # res = 0
LDI r2, 123    # a = 123
LDHI r3, 1     # b = 256
ADDIU r3, 200  # b = b + 200 (=456)
CMP 0, r3      # 0 - r
BGEI 4         # if (0 - r) >= 0 goto +4 +1
NOP            # 制御ハザード対策
ADD r1, r2     # res = res + a
ST r1, r3      # store res, #b
SUBIU r3, 1    # b = b - 1
BALI -8        # goto 2(パイプラインの分+1個進んでる) - 8 (CMPへ) 
NOP            # 制御ハザード対策
ST r1, r3      # store res, #b
BALI -2        # end
NOP            # 制御ハザード対策 