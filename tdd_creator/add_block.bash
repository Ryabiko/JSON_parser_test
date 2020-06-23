#!/bin/bash


# Copyright © 2019-2020 Feodor A. Alexandrov (feodor.alexandrov@yandex.ru)
# Copyright © 2019-2020 Artem  I. Tarutin    ()

# This file is subject to the terms and conditions of the GNU Lesser
# General Public License v3. See the file LICENSE in the top level
# directory for more details.
#

project=$1
block=$2
flag=$3


_header_="_${block^^}_H_"
_header_internal_="_${block^^}_INTERNAL_H_"

# files :
source="${block}.c"
source_internal="${block}_internal.c"
header="${block}.h"
header_internal="${block}_internal.h"
test=${block}_test.c
test_runner=${block}_test_runner.c

template_makefile=\
"all:\n"\
"\t{ \\\\\n"\
"\tcd ../; \\\\\n"\
"\tgit submodule init; \\\\\n"\
"\tgit submodule update; \\\\\n"\
"\tcd tdd_creator/; \\\\\n"\
"\tgit submodule init; \\\\\n"\
"\tgit submodule update; \\\\\n"\
"\tcd ../${project}/; \\\\\n"\
"\t}\n"\
"\tmake -f MakefileUnity.mk\n\n"\
"clean:\n\tmake -f MakefileUnity.mk clean\n\n"

template_makefile_unity=\
"#Set this to @ to keep the makefile quiet\n\n"\
"SILENCE = @\n\n"\
"#---- Outputs ----#\n"\
"COMPONENT_NAME = ${project}_Unity\n\n"\
"#--- Inputs ----#\n"\
"UNITY_HOME = ../tdd_creator/Unity\n"\
"CPP_PLATFORM = Gcc\n"\
"PROJECT_HOME_DIR = .\n"\
"PROJECT_TEST_DIR = test\n"\
"UNITY_BUILD_HOME = ../tdd_creator\n\n"\
"UNITY_CFLAGS += -Wno-missing-prototypes\n"\
"UNITY_WARNINGFLAGS = -Wall\n"\
"UNITY_WARNINGFLAGS = -Werror\n"\
"UNITY_WARNINGFLAGS = -Wswitch-default\n"\
"#UNITY_WARNINGFLAGS += -Wshadow"\
"\n"\
"SRC_DIRS = \\\\\n"\
"\t\$(PROJECT_HOME_DIR)/src/ \\\\\n"\
"\n"\
"TEST_SRC_DIRS = \\\\\n"\
"\t\$(PROJECT_TEST_DIR) \\\\\n"\
"\t\$(UNITY_HOME)/unity \\\\\n"\
"\t\$(UNITY_HOME)/src \\\\\n"\
"\t\$(UNITY_HOME)/extras/memory/src/ \\\\\n"\
"\t\$(UNITY_HOME)/extras/fixture/src \\\\\n"\
"\t\$(UNITY_HOME)/extras/fixture/test \\\\\n"\
"\n"\
"INCLUDE_DIRS = \\\\\n"\
"\t. \\\\\n"\
"\t\$(UNITY_HOME)/src \\\\\n"\
"\t\$(UNITY_HOME)/extras/memory/src/ \\\\\n"\
"\t\$(UNITY_HOME)/extras/fixture/src \\\\\n"\
"\t\$(UNITY_HOME)/extras/fixture/test \\\\\n"\
"\t\$(PROJECT_HOME_DIR)/inc/ \\\\\n"\
"\n"\
"include \$(UNITY_BUILD_HOME)/MakefileWorker.mk"

template_header=\
"#ifndef ${_header_}\n"\
"#define ${_header_}\n"\
"\n\n\n"\
"#endif//${_header_}\n"

template_header_core=\
"#ifndef ${_header_}\n"\
"#define ${_header_}\n"\
"#include ${header_internal}\n"\
"\n\n\n"\
"#endif//${_header_}\n"

template_header_internal=\
"#ifndef ${_header_internal_}\n"\
"#define ${_header_internal_}\n"\
"\n"\
"#include \"${header}\"\n"\
"\n"\
"#endif//${_header_internal_}\n"

template_source=\
"#include \"${header_internal}\""

template_source_internal=\
"#include \"${header_internal}\""

template_all_tests=\
"#include \"unity_fixture.h\"\n\n"\
"static void run_all_tests(void) "\
"{\n\tRUN_TEST_GROUP(${block});\n}\n\n"\
"int main(int argc, const char *argv[])\n"\
"{\n\treturn UnityMain(argc, argv, run_all_tests);\n}\n\n"

template_test=\
"#include \"unity_fixture.h\"\n\n"\
"#include \"${header_internal}\"\n\n"\
"TEST_GROUP (${block});\n\n"\
"TEST_SETUP (${block}) {\n\n}\n\n"\
"TEST_TEAR_DOWN (${block}) {\n\n}\n\n"\
"TEST (${block}, start_here) {\n"\
"\n\tTEST_FAIL_MESSAGE(\"start test ${block} here\");\n}\n\n"

template_test_runner=\
"#include \"unity_fixture.h\"\n\n"\
"TEST_GROUP_RUNNER (${block}) {\n"\
"\tRUN_TEST_CASE (${block}, start_here);\n"\
"}\n"

make_root_folder () {
	if ! [ -d "src" ]; then
		mkdir "src";
	fi
	if ! [ -d "inc" ]; then
		mkdir "inc";
	fi
	if ! [ -d "test" ]; then
		mkdir "test";
	fi
}

create_makefiles () {
	if ! [ -f "Makefile" ]; then
		touch "Makefile";
		echo -e ${template_makefile} >> "Makefile";
	fi
	if ! [ -f "MakefileUnity.mk" ]; then
		touch "MakefileUnity.mk";
		echo -e ${template_makefile_unity} >> "MakefileUnity.mk";
	fi
}

fill_headers () {
	cd inc;
		if ! [ -d ${block} ]; then
			mkdir ${block};
		fi
		cd ${block};
			if ! [ -f "${block}.h" ]; then
				touch ${block}.h;
				echo -e ${template_header} >> ${block}.h;
			fi 
			if ! [ -f "${block}_internal.h" ]; then
				touch ${block}_internal.h;
				echo -e ${template_header_internal} >> ${block}_internal.h;
			fi
		cd ..;
	cd ..;
}

fill_sources () {
	cd src;
	if ! [ -d ${block} ]; then
		mkdir ${block};
	fi
		cd ${block};
			if ! [ -f "${block}.c" ]; then
				touch ${block}.c;
				echo -e ${template_source} >> ${block}.c;
			fi
			if ! [ -f "${block}_internal.c" ]; then
				touch ${block}_internal.c;
				echo -e ${template_source_internal} >> ${block}_internal.c;
			fi
		cd ..;
	cd ..;
}

insert_line_after_pattern_in_file () {
	pattern=$1
	line=$2
	file=$3
	# it works but not insert \ at the end of line
	sed -i '/'$pattern'/a '$line $file;
}

fill_tests () {
	cd test;
		if ! [ -f "all_tests.c" ]; then
			touch "all_tests.c";
			echo -e ${template_all_tests} >> "all_tests.c";
		elif ! (grep "RUN_TEST_GROUP(${block})" all_tests.c -q); then
			insert_line_after_pattern_in_file \
			"run_all_tests(void)\\x20{" \
			"${sed_tab}RUN_TEST_GROUP(${block});" \
			"all_tests.c";	
		fi

		if ! [ -d ${block}.c ]; then
			mkdir ${block};
		fi
		cd ${block};
			if ! [ -f "${block}_test.c" ]; then
				touch ${block}_test.c;
				echo -e ${template_test} >> ${block}_test.c;
			fi
			if ! [ -f ${block}_test_runner.c ]; then
				touch ${block}_test_runner.c;
				echo -e ${template_test_runner} >> ${block}_test_runner.c;
			fi
		cd ..;
	cd ..;
}

sed_tab="\\\\x09"
sed_dollar="\\x24"
sed_space="\\x20"
sed_Nslash="\\x5c"

append_makefiles () {
	if ! ( grep "${block}" MakefileUnity.mk -q ) ; then
		insert_line_after_pattern_in_file \
		"(PROJECT_HOME_DIR)\/inc\/${sed_space}\\\\" \
		"${sed_tab}${sed_dollar}(PROJECT_HOME_DIR)\/inc\/${block}${sed_space}${sed_Nslash}" \
		"MakefileUnity.mk";
		insert_line_after_pattern_in_file \
		"(PROJECT_HOME_DIR)\/src\/${sed_space}\\\\" \
		"${sed_tab}${sed_dollar}(PROJECT_HOME_DIR)\/src\/${block}${sed_space}${sed_Nslash}" \
		"MakefileUnity.mk";
		insert_line_after_pattern_in_file \
		"(PROJECT_TEST_DIR)${sed_space}\\\\" \
		"${sed_tab}${sed_dollar}(PROJECT_TEST_DIR)\/${block}${sed_space}${sed_Nslash}" \
		"MakefileUnity.mk";
	fi
}


delete_block() {
	cd ${project};
	make clean;
		cd inc;
			if  [ -d ${block} ]; then
				rm -rf ${block};
			fi
		cd ..;

		cd src;
			if [ -d ${block} ]; then
				rm -rf ${block};
			fi
		cd ..;

		cd test;
			if [ -d ${block} ]; then
				rm -rf ${block};
			fi
		cd ..;
	cd ..;
}

delete_path() {
	cd ${project};	
		sed -i "/${sed_dollar}(PROJECT_HOME_DIR)\/src\/${block}/d" MakefileUnity.mk;
		sed -i "/${sed_dollar}(PROJECT_TEST_DIR)\/${block}/d" MakefileUnity.mk;
		sed -i "/${sed_dollar}(PROJECT_HOME_DIR)\/inc\/${block}/d" MakefileUnity.mk;

		cd test;	
			sed -i "/RUN_TEST_GROUP(${block})/d" all_tests.c 
		cd ..;
	cd ..;
}


make_block () { 
	#make_project
	create_makefiles && append_makefiles;
	fill_headers;
	fill_sources;
	fill_tests;
}

make_core_with_all() {
	cd ${project};
		echo "1"
			if ( grep  "/inc/${block}_core.h" -q ) ; then #create logic for check exist file/s
				echo "1"
				if ( grep "${block}" MakefileUnity.mk -q );then
					echo "block:${block} exist";
					#action if block exist
					echo "1"
					cd inc;
						touch ${block}_core.h;
						echo "1"
						echo -e ${template_header_core} >> ${block}_core.h;
					cd ..;
					echo "1"
					cd src;
						touch ${block}_core.c;
						echo -e ${template_source} >> ${block}_core.c;
					cd ..;

				else 
					echo "block:${block} not exist";
					#action if block not exist
					make_block;
					cd inc;
						touch ${block}_core.h;
						echo -e ${template_header} >> ${block}_core.h;

					cd ..;

					cd src;
						touch ${block}_core.c;
						echo -e ${template_source} >> ${block}_core.c;
					cd ..;
				fi
			fi
	cd ..;
	# we have 2 variants how find exist blocks
	# 1: check in MakefileUnity with help sed
	# 2: check in directry ,for exapmle, inc 
}

make_core_only() {

	echo "_core inly"

}


#help_prog() {
#	Name_project:____
#		inc
#			--->block1
#}


add_unity () {
	if ! [ -d "Unity" ]; then
		if ! [ -x "$(command -v git)" ]; then
		  echo 'Error: git is not installed.' >&2
		  exit 1
		fi
		git submodule add https://github.com/ThrowTheSwitch/Unity.git;
	fi
}

add_gitignore () {
	if ! [ -f "../.gitignore" ]; then
		cp .gitignore ../;
	fi
	echo -e ${project}_Unity_tests >> ../.gitignore;
}

generate_project () {
	# add_unity;
	add_gitignore;
	cd ..;

	if [ -z "$flag" ]; then
		if ! [ -d ${project} ]; then
			mkdir ${project};
		fi
		cd ${project};
			make_root_folder;
			make_block;
		cd ..;
	elif [ $flag == "-d" ]; then
		delete_block;
		delete_path;
	elif [ $flag == "-da" ]; then
		rm -rf ${project};
	elif [ $flag == "-c" ] ; then 
		make_core_with_all;
		#create block with _core files 
		#but blocks already exists then add _core files
	elif [ $flag == "-co" ]; then
		make_core_only;
		#create blocks ONLY with _core files
	else 
		echo '?!';
	fi
}

generate_project;
