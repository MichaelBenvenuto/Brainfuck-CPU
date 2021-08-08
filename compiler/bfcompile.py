import sys
import getopt

usage = """
Usage:
    bfcompile.py {-i|--input-file <file>} [-o|--output-file <file>] [-f|--format {BIN|HEX|OCT}] [-h]

Options:
    -i | --input-file       File to input as ascii bf
    -o | --output-file      File to output compiled bfbin           default: ./out.bfbin
    -f | --format           Format of output file (BIN, HEX, OCT)   default: BIN
    -h | --help             Display this message
"""

try:
    opts, args = getopt.getopt(sys.argv[1:], 'i:o:f:h', ['input-file=', 'output-file=', 'format=', 'help'])
except getopt.GetoptError as err:
    print(err)
    print(usage)
    sys.exit(2)

input_file = None
output_file = 'out.bfbin'
output_format = 'BIN'

for o, a in opts:
    if o in ('-o', '--output-file'):
        output_file = a
    elif o in ('-f', '--format'):
        output_format = a
    elif o in ('-i', '--input-file'):
        input_file = a
    elif o in ('-h', '--help'):
        print(usage)
        sys.exit(0)

if input_file == None or output_format not in ('HEX', 'BIN', 'OCT'):
    print("Expected input file")
    print(usage)
    sys.exit(2)

bf_input = open(input_file, "r")
bf_output = open(output_file, "w+")

byte = True
first_byte = True
while byte:
    byte = bf_input.read(1)
    if byte in ['<','>','+','-',',','.','[',']']:
        formatted = ''
        val_int = int.from_bytes(byte.encode(), sys.byteorder)
        if output_format == 'BIN':
            val_bin = str(bin(val_int))
            formatted = val_bin[2:].rjust(8, '0')
        elif output_format == 'HEX':
            formatted = str(hex(val_int))[2:].rjust(2, '0')
        elif output_format == 'OCT':
            formatted = str(oct(val_int))[2:].rjust(3, '0')
        if first_byte != True:
            bf_output.write("\n")
        else:
            first_byte = False
        bf_output.write(formatted)

bf_input.close()
bf_output.close()