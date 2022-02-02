import sys
import os
import json
import pathlib
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('file', nargs='?', default='', help='file name (takes .hex)')
parser.add_argument('-c', '--clear', action='store_true', help='generate clearcoe.tcl file')
args = parser.parse_args()

# Header lines for .coe files.
base_str = 'memory_initialization_radix=16;\nmemory_initialization_vector=\n'

# Get path for C code directory.
base_dir = str(pathlib.Path(os.path.join(sys.path[0], '../../c/')).resolve())

# Get path for Vivado project from config.
path_cfg = json.load(open(os.path.join(sys.path[0], 'loadcoe.json')))
proj_path = pathlib.Path(path_cfg['path'])
absolute_path = proj_path.expanduser().resolve()
folder_name = proj_path.name
proj_str = str(absolute_path) + '/' + folder_name

if str(args.file):
	# Read in and split .hex file in four.
	mems = [list(), list(), list(), list()] 
	with open(str(args.file), 'r') as f:
		lines = f.readlines() 
		for l in lines:
			l = l.strip('\n')
			mems[0].append(l[6:8])
			mems[1].append(l[4:6])
			mems[2].append(l[2:4])
			mems[3].append(l[0:2])

	# Create 4 .coe files.
	idx = 0
	out_file_base = os.path.splitext(str(args.file))[0]
	for m in mems:
		out_file_str = out_file_base + str(idx) + '.coe'
		with open(out_file_str, 'w') as f:
			f.write(base_str)
			for b in m:
				f.write(b + '\n')
			f.write(';')
		idx += 1

	# Load in template for loadcoe.tcl.
	with open(os.path.join(sys.path[0], 'tcl/loadcoe_base.tcl'), 'r') as f:
		coe_script = f.read() 

	# Insert .coe and Vivado Project paths into template.
	for i in range(4):
		out_file_str = base_dir + '/' + out_file_base + str(i) + '.coe'
		coe_script = coe_script.replace('%' + str(i), out_file_str)
	coe_script = coe_script.replace('%PATH', proj_str)

	# Create loadcoe.tcl
	with open(os.path.join(sys.path[0], 'tcl/loadcoe.tcl'), 'w') as f:
		f.write(coe_script)

if args.clear:
	out_file_base = 'empty'

	# Create 4 .coe files.
	for i in range(4):
		out_file_str = out_file_base + str(i) + '.coe'
		with open(out_file_str, 'w') as f:
			f.write(base_str)
			f.write('00\n')
			f.write(';')

	# Load in template for loadcoe.tcl.
	with open(os.path.join(sys.path[0], 'tcl/loadcoe_base.tcl'), 'r') as f:
		coe_script = f.read()

	# Insert .coe and Vivado Project paths into template.
	for i in range(4):
		out_file_str = base_dir + '/' + out_file_base + str(i) + '.coe'
		coe_script = coe_script.replace('%' + str(i), out_file_str)
	coe_script = coe_script.replace('%PATH', proj_str)

	# Create loadcoe.tcl
	with open(os.path.join(sys.path[0], 'tcl/clearcoe.tcl'), 'w') as f:
		f.write(coe_script)