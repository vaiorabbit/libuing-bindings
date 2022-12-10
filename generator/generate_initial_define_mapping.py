# PYTHONPATH=/usr/local/Cellar/llvm/6.0.0/lib/python2.7/site-packages python generate_initial_define_mapping.py > libuing_define_mapping.json

import libuing_parser, libuing_generator

if __name__ == "__main__":
    libuing_parser.generate_define_list()
