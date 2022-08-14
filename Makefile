.POSIX:

PANDOC = pandoc
SOURCES = $(patsubst src/%,%,$(wildcard src/*))

ALL_TARGETS = $(addsuffix -all,$(SOURCES))
FANCY_TARGETS = $(addsuffix -fancy,$(SOURCES))
PLAIN_TARGETS = $(addsuffix -plain,$(SOURCES))
HTML_TARGETS = $(addsuffix -html,$(SOURCES))
DOCX_TARGETS = $(addsuffix -docx,$(SOURCES))
MD_TARGETS = $(addsuffix -md,$(SOURCES))

.PHONY: $(ALL_TARGETS) $(FANCY_TARGETS) $(PLAIN_TARGETS) $(HTML_TARGETS) $(DOCX_TARGETS) $(MD_TARGETS)

$(ALL_TARGETS): %-all : %-fancy %-plain %-html %-docx %-md

$(FANCY_TARGETS): %-fancy : build/%-fancy.pdf
	@echo "Built fancy Pdf output file at $<"

$(PLAIN_TARGETS): %-plain : build/%-plain.pdf
	@echo "Built plain Pdf output file at $<"

$(HTML_TARGETS): %-html : build/%.html
	@echo "Built Html output file at $<"

$(DOCX_TARGETS): %-docx : build/%.docx
	@echo "Built Docx output file at $<"

$(MD_TARGETS): %-md : build/%.md
	@echo "Built Markdown output file at $<"


build/%-fancy.pdf: src/%/main.md
	./scripts/build.sh $< $@ ./defaults/pdf-fancy.yml $(dir $<)

build/%-plain.pdf: src/%/main.md
	./scripts/build.sh $< $@ ./defaults/pdf-plain.yml $(dir $<)

build/%.html: src/%/main.md
	./scripts/build.sh $< $@ ./defaults/html.yml $(dir $<)

build/%.docx: src/%/main.md
	./scripts/build.sh $< $@ ./defaults/docx.yml $(dir $<)

build/%.md: src/%/main.md
	./scripts/build.sh $< $@ ./defaults/commonmark.yml $(dir $<)
