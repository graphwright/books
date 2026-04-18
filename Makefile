BOOKS := identity-book kg-book bfs-ql-book

.PHONY: all clean $(BOOKS) $(addsuffix -clean,$(BOOKS))

all: $(BOOKS)

$(BOOKS):
	$(MAKE) -C $@

clean: $(addsuffix -clean,$(BOOKS))

$(addsuffix -clean,$(BOOKS)):
	$(MAKE) -C $(patsubst %-clean,%,$@) clean
