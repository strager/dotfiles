BINARY = duck-key

all: $(BINARY)

$(BINARY): main.swift
	swiftc -O -o $(BINARY) main.swift

clean:
	rm -f $(BINARY)

.PHONY: all clean
