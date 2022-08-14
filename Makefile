.POSIX:

PANDOC = pandoc
SOURCES = $(patsubst src/%,%,$(wildcard src/*))

ALL_TARGETS = $(addsuffix -all,$(SOURCES))
PDF_TARGETS = $(addsuffix -pdf,$(SOURCES))
PLAIN_TARGETS = $(addsuffix -plain,$(SOURCES))
HTML_TARGETS = $(addsuffix -html,$(SOURCES))
DOCX_TARGETS = $(addsuffix -docx,$(SOURCES))
MD_TARGETS = $(addsuffix -md,$(SOURCES))

.PHONY: $(ALL_TARGETS) $(PDF_TARGETS) $(PLAIN_TARGETS) $(HTML_TARGETS) $(DOCX_TARGETS) $(MD_TARGETS)

$(ALL_TARGETS): %-all : %-pdf %-plain %-html %-docx %-md

$(PDF_TARGETS): %-pdf : build/%.pdf
	@echo "Built Pdf output file at $<"

$(PLAIN_TARGETS): %-plain : build/%-plain.pdf
	@echo "Built plain Pdf output file at $<"

$(HTML_TARGETS): %-html : build/%.html
	@echo "Built Html output file at $<"

$(DOCX_TARGETS): %-docx : build/%.docx
	@echo "Built Docx output file at $<"

$(MD_TARGETS): %-md : build/%.md
	@echo "Built Markdown output file at $<"


build/%.pdf: src/%/main.md
	@mkdir -p $(dir $@)
	$(PANDOC) $< \
		--defaults=./defaults/pdf.yml \
		--resource-path=$(dir $<) \
		--output=$@

build/%-plain.pdf: src/%/main.md
	@mkdir -p $(dir $@)
	$(PANDOC) $< \
		--defaults=./defaults/pdf-plain.yml \
		--resource-path=$(dir $<) \
		--output=$@

build/%.html: src/%/main.md
	@mkdir -p $(dir $@)
	$(PANDOC) $< \
		--defaults=./defaults/html.yml \
		--resource-path=$(dir $<) \
		--output=$@

build/%.docx: src/%/main.md
	@mkdir -p $(dir $@)
	$(PANDOC) $< \
		--defaults=./defaults/docx.yml \
		--resource-path=$(dir $<) \
		--output=$@

build/%.md: src/%/main.md
	@mkdir -p $(dir $@)
	$(PANDOC) $< \
		--defaults=./defaults/commonmark.yml \
		--resource-path=$(dir $<) \
		--output=$@
