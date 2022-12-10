# PYTHONPATH=/usr/local/Cellar/llvm/7.0.0/lib/python2.7/site-packages python generate_initial_cindex_mapping.py > libuing_cindex_mapping.json

import libuing_parser, libuing_generator

if __name__ == "__main__":
    libuing_parser.generate_type_mapping()
