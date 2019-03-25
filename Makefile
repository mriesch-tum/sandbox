#
# qclsip: The Quantum Cascade Laser Stock Image Project.
#
# Copyright (c) 2019, Computational Photonics Group, Technical University of
# Munich.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

SRC_DIR = src
OUT_DIR = fig
OUT_ZIP = fig.zip
DPI = 600

# SVG input files
SVG_SOURCES = $(wildcard $(SRC_DIR)/*/*.svg)
# SVG output files
SVG2PDF = $(SVG_SOURCES:$(SRC_DIR)/%.svg=$(OUT_DIR)/%.pdf)
SVG2PNG = $(SVG_SOURCES:$(SRC_DIR)/%.svg=$(OUT_DIR)/%.png)

# TikZ input files
TIK_SOURCES = $(wildcard $(SRC_DIR)/*/*.tikz)
# TikZ output files
TIK2PDF = $(TIK_SOURCES:$(SRC_DIR)/%.tikz=$(OUT_DIR)/%.pdf)
TIK2PNG = $(TIK_SOURCES:$(SRC_DIR)/%.tikz=$(OUT_DIR)/%.png)

# TikZ auxiliary TeX files
TIK2TEXPDF = $(TIK_SOURCES:$(SRC_DIR)/%.tikz=$(OUT_DIR)/%.tex)
TIK2TEXPNG = $(TIK_SOURCES:$(SRC_DIR)/%.tikz=$(OUT_DIR)/%.png.tex)

# phony targets
all: $(TIK2PDF) $(TIK2PNG) #  $(SVG2PNG)

install: $(TIK2PDF) $(SVG2PNG)
	rm ./$(OUT_ZIP)
	zip $(OUT_ZIP) $(TIK2PDF) $(SV2PNG)

clean:
	@rm -rf ./$(OUT_DIR) ./$(OUT_ZIP)

distclean: clean
	@rm -f *~ *#

.PHONY: all install clean distclean

# PNG generation from SVG files
# TODO check whether inkscape is available? -> separate target?
$(SVG2PNG): $(OUT_DIR)/%.png: $(SRC_DIR)/%.svg
	@mkdir -p $(dir $@)
	@inkscape --export-dpi=$(DPI) --export-area-drawing \
		--export-png=$@ $<

# Auxiliary TeX file generation for TikZ->PDF
$(TIK2TEXPDF): $(OUT_DIR)/%.tex: templates/standalone.tex
	@mkdir -p $(dir $@)
	cat templates/standalone.tex | \
	sed s+TIKZ_FILENAME+../../$(@:$(OUT_DIR)/%.tex=$(SRC_DIR)/%.tikz)+ > $@

# Auxiliary TeX file generation for TikZ->PNG
$(TIK2TEXPNG): $(OUT_DIR)/%.png.tex: templates/standalone.tex
	@mkdir -p $(dir $@)
	echo "\\begin{document}" > $@


#	cat templates/standalone.tex | \
#	sed s+TIKZ_FILENAME+../../$(@:$(OUT_DIR)/%.png.tex=$(SRC_DIR)/%.tikz)+ \
#	sed s+documentclass{standalone}+documentclass[convert={density=$(DPI),size=1080x800,outext=.png}]{standalone}+ > $@



# PDF generation from TikZ files
# TODO check whether LaTeX is available? -> separate target?
$(TIK2PDF): $(OUT_DIR)/%.pdf: $(OUT_DIR)/%.tex $(SRC_DIR)/%.tikz
	@latexmk -quiet -outdir=$(dir $@) -pdf -interaction=nonstopmode $<

# PNG generation from TikZ files
# TODO check whether LaTeX is available? -> separate target?
$(TIK2PNG): $(OUT_DIR)/%.png: $(OUT_DIR)/%.png.tex $(SRC_DIR)/%.tikz
	@latexmk -quiet -outdir=$(dir $@) -pdf -interaction=nonstopmode $<
