SHELL = zsh
PWD = $(shell pwd)
PWD_DYLAN = $(PWD)/dylan/

all: main.n main-ocaml main-nim main-dylan main-c

main.n: Main.hx
	haxe -main Main -neko main.n

main-c: Main.hx
	haxe -main Main -cpp main-c

main-ocaml: main.ml
	ocamlc unix.cma main.ml -o main-ocaml

main-nim: main.nim
	nim c -o=main-nim -d:release -d:static main.nim

main-dylan: dylan/hello-dylan.dylan
	cd $(PWD_DYLAN) && \
	OPEN_DYLAN_USER_REGISTRIES="$(PWD_DYLAN)/registry:$(PWD_DYLAN)/ext/http/registry" \
		dylan-compiler -build hello-dylan && \
	bash -c 'if [ -f "$(PWD)" ]; then rm $(PWD)/main-dylan else 1; fi;' && \
	ln -s $(PWD_DYLAN)/_build/bin/hello-dylan $(PWD)/main-dylan


clean:
	rm main-dylan main.n main-ocaml main-nim

perf:
	for x in ./main-*; do \
		echo $$x && time ./$$x >/dev/null; \
	done
