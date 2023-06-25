"""
アセンブリ言語から機械語に翻訳する（アセンブラ）
"""


class Code:
    """
    ニーモック，オペランドをバイナリコードへと変換する
    """

    def __init__(self) -> None:
        # 命令コード対応表
        self.op_r: dict[str, int] = {
            "NOP": 0b_0001,
            "ADD": 0b_0001,
            "SUB": 0b_0010,
            "MOV": 0b_0011,
            "LD": 0b_0100,
            "ST": 0b_0101,
            "NOT": 0b_0111,
            "AND": 0b_1000,
            "OR": 0b_1001,
            "XOR": 0b_1010,
            "SRA": 0b_1011,
            "SRL": 0b_1100,
            "SLL": 0b_1101,
            "CMP": 0b_1110,
        }
        self.op_i: dict[str, str] = {
            "ADDIU": 0b_0001,
            "SUBIU": 0b_0010,
            "LDIU": 0b_0100,
            "LDI": 0b_0101,
            "LDHI": 0b_0110,
            "ANDI": 0b_1000,
            "ORI": 0b_1001,
            "XORI": 0b_1010,
            "SRAI": 0b_1011,
            "SRLI": 0b_1100,
            "SLLI": 0b_1101,
            "CMPI": 0b_1110,
        }
        self.op_bp: dict[str, int] = {
            "BALI": 0b_0000,
            "BEQI": 0b_0001,
            "BNEI": 0b_0010,
            "BLTI": 0b_0011,
            "BGEI": 0b_0100,
            "BLTIU": 0b_0101,
            "BCI": 0b_0101,
            "BGEIU": 0b_0110,
            "BNCI": 0b_0110,
            "BVFI": 0b_0111,
        }
        self.op_br: dict[str, int] = {
            "BAL": 0b_1000,
            "BEQ": 0b_1001,
            "BNE": 0b_1010,
            "BLT": 0b_1011,
            "BGE": 0b_1100,
            "BLTU": 0b_1101,
            "BC": 0b_1101,
            "BGEU": 0b_1110,
            "BNC": 0b_1110,
            "BVF": 0b_1111,
        }
        # 予約語の辞書
        self.reserved_words: dict[str, int] = {
            "R0": 0b_0000,
            "R1": 0b_0001,
            "R2": 0b_0010,
            "R3": 0b_0011,
            "R4": 0b_0100,
            "R5": 0b_0101,
            "R6": 0b_0110,
            "R7": 0b_0111,
            "R8": 0b_1000,
            "R9": 0b_1001,
            "R10": 0b_1010,
            "R11": 0b_1011,
            "R12": 0b_1100,
            "R13": 0b_1101,
            "R14": 0b_1110,
            "R15": 0b_1111,
        }

    def op_type(self, mnemonic: str) -> str:
        """
        ニーモニックを受け取って命令の型を返す

        Args:
            mnemonic (str): ニーモニック

        Raises:
            ValueError: 不正なニーモニック

        Returns:
            str: 命令の型(r, i, bp, br)
        """
        if mnemonic.upper() in self.op_r.keys():
            return "r"
        elif mnemonic.upper() in self.op_i.keys():
            return "i"
        elif mnemonic.upper() in self.op_bp.keys():
            return "bp"
        elif mnemonic.upper() in self.op_br.keys():
            return "br"
        else:
            raise ValueError(f"Invalid mnemonic: {mnemonic}")

    def mnemonic(self, mnemonic: str) -> int:
        """
        ニーモニックを受け取って命令コード（RとB型はfunct）を返す

        Args:
            mnemonic (str): ニーモニック

        Returns:
            int: 命令コード
        """
        if (op_type := self.op_type(mnemonic)) == "r":
            return self.op_r[mnemonic.upper()]
        elif op_type == "i":
            return self.op_i[mnemonic.upper()]
        elif op_type == "bp":
            return self.op_bp[mnemonic.upper()]
        else:
            return self.op_br[mnemonic.upper()]

    def operand(self, operand: str) -> int:
        """
        オペランドを受け取ってオペランドコードを返す

        Args:
            operand (str): オペランド

        Raises:
            ValueError: 不正なオペランド

        Returns:
            int: オペランドコード
        """
        # 2進数，10進数，16進数の場合，そのまま返す
        # ""で囲まれたデータの場合
        if operand.startswith('"') and operand.endswith('"'):
            # 特殊文字の場合
            if ("\\" in operand) and (operand != '"\\"'):
                return ord(operand[1:-1].encode().decode("unicode-escape"))
            else:
                return ord(operand[1:-1])
        elif operand.startswith("0x"):
            return int(operand, 16)
        elif operand.startswith("0b"):
            return int(operand, 2)
        elif self.__isint(operand):
            return int(operand)
        # operandが予約語の場合，レジスタファイルの対象アドレスの値を返す
        elif operand.upper() in self.reserved_words.keys():
            return self.reserved_words[operand.upper()]
        else:
            raise ValueError(f"Invalid operand: {operand}")

    def __isint(self, s: str) -> bool:
        """
        文字列が整数かどうかを判定する
        """
        try:
            int(s)
            return True
        except ValueError:
            return False


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("input_file", help="input file")
    parser.add_argument("output_file", help="output file")
    args = parser.parse_args()
    code: Code = Code()

    binaries: list[int] = []

    with open(args.input_file, "r", encoding="utf-8") as f:
        for line in f:
            # コメント行または空行は無視
            if line.startswith("#") or line == "\n":
                continue
            line = line.split("#")[0].strip()  # コメントを削除
            mnemonic, *operands = line.split()
            operands = [operand.strip(",") for operand in operands]  # カンマを削除
            # operandsにおいて"が連続した場合，" "に変換(空白区切りなので" "は['"','"']になる)
            for i in range(len(operands) - 1):
                if (operands[i] == '"') and (operands[i + 1] == '"'):
                    operands[i] = '" "'
                    operands.pop(i + 1)
            print(operands)

            binary: int = 0b_0000_0000_0000_0000  # 機械語

            if mnemonic.upper() == "NOP":
                binary = 0b_0000_0001_0000_0000
            elif (op_type := code.op_type(mnemonic)) == "r":
                binary |= 0b_0000 << 12
                binary |= code.mnemonic(mnemonic) << 8
                binary |= code.operand(operands[1]) << 4
                binary |= code.operand(operands[0])
            elif op_type == "i":
                binary |= code.mnemonic(mnemonic) << 12
                binary |= (code.operand(operands[1]) & 0xFF) << 4  # 2の補数
                binary |= code.operand(operands[0])
            elif op_type == "bp":
                binary |= 0b_1111 << 12
                binary |= code.mnemonic(mnemonic) << 8
                binary |= code.operand(operands[0]) & 0xFF  # 2の補数
            else:
                binary |= 0b_1111 << 12
                binary |= code.mnemonic(mnemonic) << 8
                binary |= code.operand(operands[0]) << 4
                binary |= 0b_0000  # 未使用ビット

            binaries.append(binary)

    with open(args.output_file, "w", encoding="utf-8") as f:
        for binary in binaries:
            f.write(f"{binary:04x}\n")
