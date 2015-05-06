PWD = $(shell pwd)
PWD_DYLAN = $(PWD)/dylan/

all: main.n main-ocaml main-nim main-dylan

main.n: Main.hx
	haxe -main Main -neko main.n

main-ocaml: main.ml
	ocamlc unix.cma main.ml -o main-ocaml

main-nim: main.nim
	nim c -o=main-nim -d:release -d:static main.nim

main-dylan: dylan/hello-dylan.dylan
	cd $(PWD_DYLAN) && \
	OPEN_DYLAN_USER_REGISTRIES="$(PWD_DYLAN)/registry:$(PWD_DYLAN)/ext/http/registry" \
		dylan-compiler -build hello-dylan && \
	rm $(PWD)/main-dylan && \
	ln -s $(PWD_DYLAN)/_build/bin/hello-dylan $(PWD)/main-dylan


clean:
	rm main-dylan main.n main-ocaml main-nim
