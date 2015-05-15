SHELL = zsh
PWD = $(shell pwd)
PWD_DYLAN = $(PWD)/dylan/

all: main.n main-c main-ocaml main-ocamlopt main-nim main-dylan main-cpp

main.n: Main.hx
	haxe -main Main -neko main.n

main-haxe-cpp: Main.hx
	haxe -main Main -cpp main-c
	if [[ -f "$(PWD)/main-haxe-cpp" ]]; then rm $(PWD)/main-haxe-cpp; fi
	ln -s $(PWD)/main-c/Main $(PWD)/main-haxe-cpp

main-cpp: main.cpp
	g++ -L"/usr/lib64" --std=c++11 -O2 -o main-cpp main.cpp

main-ocaml: main.ml
	ocamlc unix.cma main.ml -o main-ocaml

main-ocamlopt: main.ml
	ocamlopt -o main-ocamlopt unix.cmxa main.ml

main-nim: main.nim
	nim c -o=main-nim -d:release --opt:speed main.nim

main-dylan: dylan/hello-dylan.dylan dylan/library.dylan dylan/hello-dylan.lid
	cd $(PWD_DYLAN) && \
	if [[ -f "../main-dylan" ]]; then rm ../main-dylan; fi && \
	OPEN_DYLAN_USER_REGISTRIES="$(PWD_DYLAN)/registry:$(PWD_DYLAN)/ext/http/registry" \
		dylan-compiler -build hello-dylan && \
	bash -c 'if [ -f "$(PWD)" ]; then rm $(PWD)/main-dylan else 1; fi;' && \
	ln -s $(PWD_DYLAN)/_build/bin/hello-dylan $(PWD)/main-dylan


clean:
	rm main-dylan main.n main-ocaml main-nim


MAINS = ./main-haxe-cpp ./main-dylan ./main-nim ./main-ocaml ./main-ocamlopt ./main-haxe-neko ./main-py ./main-cpp

.ONESHELL:
perf:
	for x in $(MAINS); do
		time ./$$x >/dev/null;
	done
