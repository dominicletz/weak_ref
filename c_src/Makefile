ERL_INCLUDE_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

../priv/weak_ref_nif.so: weak_ref_nif.c
	echo ${ERL_INCLUDE_PATH}
	mkdir -p ../priv
	gcc -I${ERL_INCLUDE_PATH} -o ../priv/weak_ref_nif.so -shared -fPIC weak_ref_nif.c -O3 -Wall -Wextra -pedantic
