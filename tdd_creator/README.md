/* project and documentation in progress */

# tdd_creator
The simple script to create TDD-based C-project

* The project structure template primarily based on James W. Grenning's book about Embedded TDD.
* Independent blocks[1] of code which stores regardless from tests based on TDD and Unity

[1] block means special combination of .c and .h files /* further will be more info */

## To create project with this script:

* Create folder and init a git repository
* Add script repository as submodule
* Execute script with one of the instructions (following below)
* Project folder will be created one directory above than script

#### 1. Create project
		./add_block project_name_new block_name
#### 2. Add block
		./add_block project_name block_name_new
#### 3. Delete block 
		./add_block project_name block_name_delete -d

/* to be continued... */

## LICENSE
* This code is licensed under the GNU Lesser General Public License (LGPL) version 3 as published by the Free Software Foundation.
* It is possible to link closed-source code with the LGPL code.
* All code files contain licensing information.
