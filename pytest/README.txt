config.py
- needs rex bin directory configured

launcher.py:
runs all configured tests: (needs root password if avatar test is included because of tshark)
parameters:
 -p, --password <password> (default "hardcoded")
usage example: 
python launcher.py -p passwd123

js-viewer-server-test.py:
parameters:
 -f, --file <path/to/file> (default ~/realxtend/bin/scenes/Avatar/avatar.txml)
usage example: 
python js-viewer-server-test.py -f ~/realxtend/bin/scenes/Avatar/avatar.txml

avatar-test:
parameters:
 -r, --runs 	number of runs (default 2)
 -c, --clients 	number of clients per run (default 2)
 -j, --js <chiru/local> 	select server (default local)
usage example: 
python avatar-test.py -r 1 -c 1 -j chiru


